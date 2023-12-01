# frozen_string_literal: true

require "date"
require "spec_helper"
require "zephir_file"

TEST_ZEPHIR_FILE = "zephir_test_20090101.json.gz"
TEST_ZEPHIR_PATH = "/app/#{TEST_ZEPHIR_FILE}"
TEST_ZEPHIR_DATE = "2009-01-01"
TEST_ZEPHIR_HATHIFILE = "hathi_test_20090102.txt.gz"

RSpec.describe ZephirFile do
  let(:zephir_file) { described_class.new(TEST_ZEPHIR_PATH) }

  describe "#initialize" do
    context "with a bare filename" do
      it "uses the passed filename" do
        zf = described_class.new(TEST_ZEPHIR_FILE)
        expect(zf.filename).to eq(TEST_ZEPHIR_FILE)
      end
    end

    context "with a path" do
      it "parses the filename from the passed path" do
        zf = described_class.new(TEST_ZEPHIR_PATH)
        expect(zf.filename).to eq(TEST_ZEPHIR_FILE)
      end
    end
  end

  describe "#type" do
    it "parses the type from the filename" do
      expect(zephir_file.type).to eq("test")
    end
  end

  describe "#date" do
    it "parses the date from the filename" do
      expect(zephir_file.date).to eq(Date.parse(TEST_ZEPHIR_DATE))
    end
  end

  describe "#hathifile" do
    it "returns the filled-in Hathifile template" do
      expect(zephir_file.hathifile).to eq(TEST_ZEPHIR_HATHIFILE)
    end
  end
end
