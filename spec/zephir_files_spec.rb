# frozen_string_literal: true

require "spec_helper"
require "zephir_files"

ZEPHIR_TEST_FIXTURES = [
  "zephir_full_20090101.json.gz",
  "zephir_upd_20090101.json.gz",
  "zephir_upd_20090102.json.gz",
  "zephir_upd_20090103.json.gz"
].shuffle.freeze

HATHIFILES_TEST_FIXTURES = [
  "hathi_full_20090102.txt.gz", # based on pre-shuffle ZEPHIR_TEST_FIXTURES[0]
  "hathi_upd_20090104.txt.gz"  # based on pre-shuffle ZEPHIR_TEST_FIXTURES[3]
].shuffle.freeze

ZEPHIR_UNPROCESSED_FIXTURES = [
  "zephir_upd_20090101.json.gz", # pre-shuffle ZEPHIR_TEST_FIXTURES[1]
  "zephir_upd_20090102.json.gz"  # pre-shuffle ZEPHIR_TEST_FIXTURES[2]
].shuffle.freeze

def with_zephir_files_test_fixtures
  Dir.mktmpdir("zephir") do |zephir_dir|
    Dir.mktmpdir("hathifiles") do |hathifiles_dir|
      ZEPHIR_TEST_FIXTURES.each do |fixture|
        `touch #{File.join(zephir_dir, fixture)}`
      end
      HATHIFILES_TEST_FIXTURES.each do |fixture|
        `touch #{File.join(hathifiles_dir, fixture)}`
      end
      yield zephir_dir: zephir_dir, hathifiles_dir: hathifiles_dir
    end
  end
end

RSpec.describe ZephirFiles do
  describe ".new" do
    let(:zephir_files) {
      described_class.new(zephir_dir: Settings.zephir_dir, hathifiles_dir: Settings.hathifiles_dir)
    }
    it "preserves zephir directory" do
      expect(zephir_files.zephir_dir).to eq(Settings.zephir_dir)
    end

    it "preserves hathifiles directory" do
      expect(zephir_files.hathifiles_dir).to eq(Settings.hathifiles_dir)
    end
  end

  describe "#all" do
    it "returns all of the zephir files in order" do
      with_zephir_files_test_fixtures do |zephir_dir:, hathifiles_dir:|
        @zf = described_class.new(zephir_dir: zephir_dir, hathifiles_dir: hathifiles_dir)
        expect(@zf.all.map { |zf| zf.filename }).to eq(ZEPHIR_TEST_FIXTURES.sort)
      end
    end
  end

  describe "#unprocessed" do
    it "returns all of the zephir files in order" do
      with_zephir_files_test_fixtures do |zephir_dir:, hathifiles_dir:|
        @zf = described_class.new(zephir_dir: zephir_dir, hathifiles_dir: hathifiles_dir)
        expect(@zf.unprocessed.map { |zf| zf.filename }).to eq(ZEPHIR_UNPROCESSED_FIXTURES.sort)
      end
    end
  end
end
