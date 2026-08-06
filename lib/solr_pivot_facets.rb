# frozen_string_literal: true

# Retrieve and analyze title level pivot data from Solr.

require "faraday"
require "json"

class SolrPivotFacets
  FIELD_NAMES = %w[format language country_of_pub_facet publishDate]
  SOLR_TO_DB_FIELDS = {
    "format" => "format",
    "language" => "language",
    "country_of_pub_facet" => "publication_place",
    "publishDate" => "published_year",
    "gov_doc" => "us_gov_doc_flag"
  }.freeze

  # Retrieve pivots from Solr and parse.
  # Can be called before `run` if desired for more granular logging.
  def pivots
    return @pivots if @pivots

    data = JSON.parse(Faraday.get(solr_facets_url).body)
    @pivots = data["facet_counts"]["facet_pivot"][FIELD_NAMES.join(",")]
  end

  # Analyze pivots, fetching if necessaey, calling `block` for each leaf of the analysis.
  # Block is called with a Hash of the form {db_field => value ...}
  # e.g.,
  #   `{"format" => "Book", "language" => "French", "publication_place" => "France",
  #     "published_year" => "2000", "total_unique_titles" => 1}`
  # suitable for direct insertion in DB.
  #
  # The `data` parameter is for testing.
  def summarize(data = pivots, &block)
    gather_pivot_counts(data, &block)
  end

  private

  def solr_facets_url
    "#{ENV["SOLR_URL"]}/solr/catalog/select?q=*:*&facet.pivot=#{FIELD_NAMES.join(",")}&facet=true&rows=0&facet.pivot.mincount=1&wt=json"
  end

  # Collect field names, then output counts at the bottom level of the hierarchy
  def gather_pivot_counts(pivots, fields: {}, &block)
    pivots.each do |pivot|
      new_fields = fields.merge(pivot["field"] => pivot["value"])
      if pivot.has_key?("pivot")
        gather_pivot_counts(pivot["pivot"], fields: new_fields, &block)
      elsif block_given?
        row = FIELD_NAMES.map { |f| [SOLR_TO_DB_FIELDS[f], new_fields[f]] }
          .to_h
          .merge("total_unique_titles" => pivot["count"])
        block.call(row)
      end
    end
  end
end
