# frozen_string_literal: true

# Retrieve and analyze title level pivot data from Solr.

require "faraday"
require "json"

class SolrPivotFacets
  FIELD_NAMES = %w[format language country_of_pub_facet publishDate]

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
  #   `{"format" => "Book", "language" => "French", "country_of_pub_facet" => "France",
  #     "publishDate" => "2000", "total_unique_titles" => 1}`
  # suitable for insertion in DB after the Solr fields are translated into column names.
  #
  # The `data` parameter is for testing.
  def summarize(data = pivots, fields: {}, &block)
    data.each do |pivot|
      new_fields = fields.merge(pivot["field"] => pivot["value"])
      if pivot.has_key?("pivot")
        summarize(pivot["pivot"], fields: new_fields, &block)
      elsif block_given?
        row = FIELD_NAMES.map { |f| [f, new_fields[f]] }
          .to_h
          .merge("total_unique_titles" => pivot["count"])
        block.call(row)
      end
    end
  end

  private

  def solr_facets_url
    "#{ENV["SOLR_URL"]}/solr/catalog/select?q=*:*&facet.pivot=#{FIELD_NAMES.join(",")}&facet=true&rows=0&facet.pivot.mincount=1&wt=json"
  end
end
