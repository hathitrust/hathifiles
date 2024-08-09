# frozen_string_literal: true

require "spec_helper"
require "hathifile_writer"

RSpec.describe HathifileWriter do
  describe "#batch_extract_rights" do
    it "extracts rights_timestamp and access_profile" do
      rights = described_class.new(hathifile: "no_such_file").batch_extract_rights(["test.pd_google"])
      expect(rights).to be_a(Hash)
      expect(rights["test.pd_google"]).not_to be_nil
      expect(rights["test.pd_google"][:rights_timestamp]).to be_a(Time)
      expect(rights["test.pd_google"][:access_profile]).to be_a(String)
    end
  end
end
