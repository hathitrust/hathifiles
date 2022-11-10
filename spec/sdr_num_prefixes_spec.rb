# frozen_string_literal: true

require "spec_helper"
require "sdr_num_prefixes"
require "services"

RSpec.describe SdrNumPrefixes do
  describe "#initialize" do
    let(:prefixes) { described_class.new }
    it "collects the mapping from the config files" do
      expect(prefixes["miu"]).to match_array(["miu"])
      expect(prefixes["yale"]).to match_array(["yale-loc", "yale"])
      expect(prefixes["iucla"]).to match_array(["ucla"])
    end

    it "falls back to identity mapping" do
      expect(prefixes["nonexistent"]).to match_array(["nonexistent"])
    end

    it "raises an error if there are no configs" do
      Dir.mktmpdir do |dir|
        expect { described_class.new(dir) }.to raise_error(RuntimeError, /config/)
      end
    end
  end
end
