# frozen_string_literal: true

require "spec_helper"
require "rights_database/rights"

RSpec.describe RightsDatabase::Rights do
  describe "#new" do
    it "retrieves a rights record for an item id" do
      item_rights = RightsDatabase::Rights.new(item_id: "test.cc-by-nc-nd-4.0_page")
      expect(item_rights.attribute.id).to eq(22)
      expect(item_rights.reason.id).to eq(1)
    end
  end
end
