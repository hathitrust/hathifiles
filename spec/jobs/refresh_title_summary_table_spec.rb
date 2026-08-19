# frozen_string_literal: true

require "hathifiles_database"
require "title_summary_table"
require "spec_helper"
require_relative "../../bin/refresh_title_summary_table"

RSpec.describe "bin/refresh_title_summary_table" do
  let(:hfdb) { HathifilesDatabase.new.rawdb }
  let(:table_name) { TitleSummaryTable::TABLE_NAME }
  let(:temp_table_name) { TitleSummaryTable::TEMP_TABLE_NAME }
  let(:old_table_name) { TitleSummaryTable::OLD_TABLE_NAME }

  it "populates the database" do
    # Make sure the table exists. It doesn't have to, but it's the typical scenario
    table = TitleSummaryTable.new
    table.create
    # Truncate if there's any data there
    table.dataset.truncate
    # Now do it.
    RefreshTitleSummaryTable.new.run
    # Expect about 1800 entries from solr-sdr-sample, subject to change
    expect(table.dataset.count).to be_between(1500, 3000)
  end

  it "creates the table(s) if necessary" do
    # Make sure none of the tables exist
    hfdb.drop_table?(table_name)
    hfdb.drop_table?(temp_table_name)
    hfdb.drop_table?(old_table_name)
    RefreshTitleSummaryTable.new.run
    expect(TitleSummaryTable.new.dataset.count).to be_between(1500, 3000)
  end
end
