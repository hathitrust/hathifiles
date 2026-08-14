# frozen_string_literal: true

require "hathifiles_database"
require "spec_helper"
require_relative "../../bin/refresh_title_summary_table"

RSpec.describe "bin/refresh_title_summary_table" do
  let(:hfdb) { HathifilesDatabase.new.rawdb }

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
end
