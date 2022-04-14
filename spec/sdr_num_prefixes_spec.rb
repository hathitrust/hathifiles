# frozen_string_literal: true

require "spec_helper"
require "sdr_num_prefixes"
require "services"

RSpec.describe SdrNumPrefixes do
  describe "#initialize" do
    it "collects the mapping from the config files" do
      prefixes = described_class.new
      expect(prefixes["miu"]).to match_array(["miu"])
      expect(prefixes["yale"]).to match_array(["yale-loc", "yale"])
    end
  end
end
