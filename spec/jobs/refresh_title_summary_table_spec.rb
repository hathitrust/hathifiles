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
    # Expect about 1300 entries from solr-sdr-sample, subject to change
    expect(table.dataset.count).to be_between(1000, 2000)
  end

  it "creates the table(s) if necessary" do
    # Make sure none of the tables exist
    hfdb.drop_table?(table_name)
    hfdb.drop_table?(temp_table_name)
    hfdb.drop_table?(old_table_name)
    RefreshTitleSummaryTable.new.run
    expect(TitleSummaryTable.new.dataset.count).to be_between(1000, 2000)
  end

  it "has rows for items missing language, pub year, or pub place" do
    RefreshTitleSummaryTable.new.run

    dataset = TitleSummaryTable.new.dataset

    expect(dataset.where(language: nil).count).to be > 0
    expect(dataset.where(published_year: nil).count).to be > 0
    expect(dataset.where(publication_place: nil).count).to be > 0
  end

  it "has the expected number of formats" do
    RefreshTitleSummaryTable.new.run

    # should match formats from title_summary_table.yaml; sample data won't
    # have all of them, but should have more than one, and not have a bunch of
    # extraneous formats
    dataset = TitleSummaryTable.new.dataset

    expect(dataset.distinct(:format).to_a.map(&:values).flatten).to include("Book", "Serial")
    expect(dataset.distinct(:format).count).to be < 8
  end
end
