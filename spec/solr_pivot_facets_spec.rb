# frozen_string_literal: true

require "json"
require "spec_helper"
require "solr_pivot_facets"

RSpec.describe SolrPivotFacets do
  let(:facets) { described_class.new }
  let(:sample_json_fixture) { fixture("solr_pivots.json") }
  let(:sample_json_data) { JSON.parse(File.read(sample_json_fixture)) }

  describe "#pivots" do
    it "returns an Array with multiple (format) values" do
      expect(facets.pivots).to be_a(Array)
      expect(facets.pivots.count).to be > 1
    end
  end

  describe "#summarize" do
    it "yields" do
      expect { |b| facets.summarize(&b) }.to yield_control
    end

    # Sample data is based on a subset (`author:smith`) of the Solr catalog sample.
    # The actual number is 26 but I am leaving some wiggle room.
    context "with sample data" do
      it "yields more than 20 rows" do
        rows = Set.new
        facets.summarize(sample_json_data) do |row|
          rows << row
        end
        expect(rows.count).to be_between(20, 30)
      end
    end

    # See above, but the Solr catalog sample may undergo multiple iterations.
    # The actual number is 1849 but I am leaving a fair amount of wiggle room.
    context "with Solr data" do
      it "yields WAY more than 20 rows" do
        rows = Set.new
        facets.summarize do |row|
          rows << row
        end
        expect(rows.count).to be_between(1500, 3000)
      end
    end
  end
end
