# frozen_string_literal: true

require "hathifiles_database"
require "open3"
require "spec_helper"

RSpec.describe "bin/rights_change.sh" do
  let(:hfdb) { HathifilesDatabase.new.rawdb }

  it "populates the database" do
    # Make sure the table exists. It doesn't have to, but it's the typical scenario
    table = TitleSummaryTable.new
    table.create
    # Truncate the database
    cmd = [
      "bundle",
      "exec",
      "/usr/src/app/bin/refresh_title_summary_table"
    ]
    # Now do it.
    _stdout, _stderr, exit_status = Open3.capture3(*cmd)
    expect(exit_status.success?).to be true
    # Expect about 1800 entries from solr-sdr-sample, subject to change
    expect(table.dataset.count).to be_between(1500, 3000)
  end
end
