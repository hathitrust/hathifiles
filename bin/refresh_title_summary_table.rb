#!/usr/bin/env ruby

# Refresh summary tables for hathifiles for use for analytics, dashboard, etc.

require "dotenv"
require "hathifiles_database"
require "push_metrics"
require "yaml"

$LOAD_PATH.unshift "../lib"

require "services"
require "solr_pivot_facets"
require "title_summary_table"

class RefreshTitleSummaryTable
  # hathifiles_database slice size, seems a little low
  DB_BATCH_SIZE = 100

  attr_reader :facets, :solr_to_database_fields, :summary_table, :tracker
  def initialize
    # Do we need this?
    envfile = Pathname.new(__dir__).parent + ".env"
    Dotenv.load(envfile)
    @summary_table = TitleSummaryTable.new(logger: Services.logger)
    @facets = SolrPivotFacets.new
    @tracker = PushMetrics.new(
      job_name: ENV.fetch("HATHIFILES_DATABASE_JOB_NAME", "title_summary_table_refresh"),
      logger: Services.logger
    )
    @solr_to_database_fields = YAML.load_file("data/title_summary_table.yaml")["solr_to_database_fields"]
  end

  def insert_rows(rows)
    summary_table.dataset(temp: true).multi_insert(rows)
  end

  def count
    return 0 unless summary_table.db.table_exists?(TitleSummaryTable::TABLE_NAME)
    summary_table.dataset.count
  end

  def run
    Services.logger.info("Existing summary table count: #{count}")
    Services.logger.info("Creating temporary database table")
    summary_table.create(temp: true)
    # truncate in case it was already present
    summary_table.dataset(temp: true).truncate

    Services.logger.info("Getting summary data from Solr and collecting counts")
    rows = []
    facets.summarize do |row|
      # Map the Solr fields to our database columns
      row = row.map do |key, value|
        [solr_to_database_fields.fetch(key, key), value]
      end.to_h
      rows << row
      if rows.count >= DB_BATCH_SIZE
        insert_rows(rows)
        rows = []
      end
      tracker.increment_and_log_batch_line
    end
    # Insert leftovers
    insert_rows(rows)

    summary_table.swap
    tracker.log_final_line
    Services.logger.info("Summary table count now: " + summary_table.dataset.count.to_s)
  end
end

if $PROGRAM_NAME == __FILE__
  # Not covered because Simplecov doesn't instrument anything called w/ backticks or `open3`
  # and the integration test invokes this by class anyway.
  # Doing otherwise might involve brittle `$PROGRAM_NAME` shenanigans.
  # Note: when moving from SimpleCov 0.22.0 to 1.X replace the :nocov: directives with
  # simplecov:disable and simplecov:enable to avoid deprecation notices.
  # :nocov:
  RefreshTitleSummaryTable.new.run
  # :nocov:
end
