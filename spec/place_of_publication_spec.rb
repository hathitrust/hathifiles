# frozen_string_literal: true

require 'spec_helper'
require 'place_of_publication'

RSpec.describe PlaceOfPublication do
  let(:m) do 
    MARC::Record.new_from_hash(
      JSON.parse(File.open(File.dirname(__FILE__) + '/data/bib_rec.json').read)
    )
  end
  let(:pop) { described_class.new }

  describe "#initalize" do
    it "extracts raw_pub_place if given marc" do
      pop = described_class.new(m)
      expect(pop.raw_pub_place).to eq('dcu')
    end
  end

  describe "#raw_pub_place" do
    it "returns '' if there is no valid 008" do
      m.fields.delete(m['008'])
      pop = described_class.new(m)
      expect(pop.raw_pub_place).to eq('')
    end
  end

  describe "#place_code" do
    it "keeps a basic three letter code from the 008" do
      pop = described_class.new(m)
      expect(pop.place_code).to eq('dcu')
    end

    it "replaces unkown characters with spaces" do
      pop.raw_pub_place = "?|^"
      expect(pop.place_code).to eq('   ')
    end

    it "gives an empty string if there are non-alpha characters" do
      pop.raw_pub_place = "a1$"
      expect(pop.place_code).to eq('   ')
    end

    it "gives an empty string if there are less than 2 characters" do
      pop.raw_pub_place = "u"
      expect(pop.place_code).to eq('   ')
    end

    it "fixes Puerto Rico codes" do
      pop.raw_pub_place = "pr"
      expect(pop.place_code).to eq('pru')
    end

    it "fixes United States codes" do
      pop.raw_pub_place = "us"
      expect(pop.place_code).to eq('xxu')
    end
  end

  describe "#to_s" do
    it "returns the place_code" do
      pop.raw_pub_place = "us"
      expect(pop.to_s).to eq("xxu")
    end
  end
end  
