# frozen_string_literal: true

require "spec_helper"
require "zlib"
require_relative "../../jobs/generate_hathifile"

RSpec.describe GenerateHathifile do
  around(:each) do |example|
    @old_hf_dir = Settings.hathifiles_dir
    @old_z_dir = Settings.zephir_dir

    Dir.mktmpdir("hathifiles") do |hf_dir|
      Settings.hathifiles_dir = hf_dir
      Dir.mktmpdir("zephir") do |z_dir|
        Settings.zephir_dir = z_dir
        example.run
      end
    end

    Settings.hathifiles_dir = @old_hf_dir
    Settings.zephir_dir = @old_z_dir
  end

  it "generates the expected output" do
    # One particular UC record from a day in August 2022
    system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_test_20220807.json")

    GenerateHathifile.new("test").run

    outfile = "#{Settings.hathifiles_dir}/hathi_test_20220808.txt.gz"
    generated = Zlib::GzipReader.open(outfile).read
    # The items as they were output on that day
    expected = File.read("#{__dir__}/../data/000018677-20220808.tsv")
    expect(generated).to eq(expected)
  end
end
