# frozen_string_literal: true

# Title-level summary table for hathifiles for use for analytics, dashboard, etc.
#  +---------------------+--------------+------+-----+---------+-------+
#  | Field               | Type         | Null | Key | Default | Extra |
#  +---------------------+--------------+------+-----+---------+-------+
#  | format              | varchar(128) | YES  |     | NULL    |       |
#  | language            | varchar(128) | YES  |     | NULL    |       |
#  | published_year      | int(11)      | YES  |     | NULL    |       |
#  | publication_place   | varchar(128) | YES  |     | NULL    |       |
#  | us_gov_doc_flag     | tinyint(4)   | YES  |     | NULL    |       |
#  | total_unique_titles | bigint(21)   | YES  |     | NULL    |       |
#  +---------------------+--------------+------+-----+---------+-------+
require "hathifiles_database"

class TitleSummaryTable
  TABLE_NAME = :hf_title_summary_expanded
  OLD_TABLE_NAME = :hf_title_summary_expanded_old
  TEMP_TABLE_NAME = :hf_title_summary_expanded_temp

  attr_reader :db, :logger

  def initialize(logger: nil)
    @connection = HathifilesDatabase.new
    @db = @connection.rawdb
    @logger = logger || @connection.logger
  end

  def create(temp: false)
    table_name = temp ? TEMP_TABLE_NAME : TABLE_NAME
    @db.run <<~SQL
      CREATE TABLE IF NOT EXISTS #{table_name} (
        format VARCHAR(128),
        language VARCHAR(128),
        published_year INT(11),
        publication_place VARCHAR(128),
        us_gov_doc_flag tinyint(4),
        total_unique_titles bigint(21)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    SQL
  end

  def dataset(temp: false)
    db[temp ? TEMP_TABLE_NAME : TABLE_NAME]
  end

  # Drop old
  # Rename current to old and temp to current
  # This duplicates some functionality in `hathifiles_database/exe/refresh_summary_table`
  # and perhaps this whole class should live there.
  # Also, `swap` could be moved to a utility module for use with any table.
  def swap
    logger.info("Dropping old title summary table")
    db.run <<~SQL
      DROP TABLE IF EXISTS #{OLD_TABLE_NAME};
    SQL

    logger.info("Swapping in new title summary table")
    # Rename will fail if these tables aren't present.
    # Will only create if not already in existence.
    create
    create(temp: true)
    db.run <<~SQL
      RENAME TABLE
       #{TABLE_NAME} TO #{OLD_TABLE_NAME},
       #{TEMP_TABLE_NAME} TO #{TABLE_NAME}
    SQL
  end
end
