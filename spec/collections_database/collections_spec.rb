# frozen_string_literal: true

require "spec_helper"
require "collections_database/collections"

RSpec.describe CollectionsDatabase::Collections do
  describe "#new" do
    it "retrieves a collections hash" do
      coll = CollectionsDatabase::Collections.new
      expect(coll.collections).to be_a(Hash)
      expect(coll.collections.keys).to include("KEIO")
    end
  end

  describe "#[]" do
    it "retrieves a collection with a collection code" do
      collections = CollectionsDatabase::Collections.new.collections
      expect(collections["MIU"]).to be_a(CollectionsDatabase::Collection)
      expect(collections["MIU"].billing_entity).to eq("umich")
    end
  end
end
