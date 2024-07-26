# frozen_string_literal: true

require "spec_helper"
require "zlib"
require "faraday"
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

  context "with a full file" do
    it "generates the expected output" do
      # One particular UC record from a day in August 2022
      system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_full_20220807.json")

      GenerateHathifile.new.run

      outfile = "#{Settings.hathifiles_dir}/hathi_full_20220808.txt.gz"
      generated = Zlib::GzipReader.open(outfile).read
      # The items as they were output on that day
      expected = File.read("#{__dir__}/../data/000018677-20220808.tsv")
      expect(generated).to eq(expected)
      expect(File.stat(outfile).mode.to_s(8)[-3, 3]).to eq("644")
    end

    it "generates the expected output from gzipped file" do
      # One particular UC record from a day in August 2022
      system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_full_20220807.json")
      system("gzip #{Settings.zephir_dir}/zephir_full_20220807.json")
      GenerateHathifile.new.run

      outfile = "#{Settings.hathifiles_dir}/hathi_full_20220808.txt.gz"
      generated = Zlib::GzipReader.open(outfile).read
      # The items as they were output on that day
      expected = File.read("#{__dir__}/../data/000018677-20220808.tsv")
      expect(generated).to eq(expected)
    end

    it "pushes expected metrics to pushgateway" do
      pm_endpoint = ENV["PUSHGATEWAY"]
      Faraday.delete("#{pm_endpoint}/metrics/job/generate_hathifile_test")

      # run as above
      # One particular UC record from a day in August 2022
      system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_full_20220807.json")
      GenerateHathifile.new.run
      metrics = Faraday.get("#{pm_endpoint}/metrics").body

      expect(metrics).to match(/^job_last_success\S*job="generate_hathifiles"\S* \S+/m)
        .and match(/^job_records_processed\S*job="generate_hathifiles"\S* 1$/m)
    end
  end

  context "with an update file" do
    it "generates the expected output" do
      # One particular UC record from a day in August 2022
      system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_upd_20220807.json")

      GenerateHathifile.new.run

      outfile = "#{Settings.hathifiles_dir}/hathi_upd_20220808.txt.gz"
      generated = Zlib::GzipReader.open(outfile).read
      # The items as they were output on that day
      expected = File.read("#{__dir__}/../data/000018677-20220808-upd.tsv")
      expect(generated).to eq(expected)
      expect(File.stat(outfile).mode.to_s(8)[-3, 3]).to eq("644")
    end

    it "generates the expected output from gzipped file" do
      # One particular UC record from a day in August 2022
      system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_upd_20220807.json")
      system("gzip #{Settings.zephir_dir}/zephir_upd_20220807.json")
      GenerateHathifile.new.run

      outfile = "#{Settings.hathifiles_dir}/hathi_upd_20220808.txt.gz"
      generated = Zlib::GzipReader.open(outfile).read
      # The items as they were output on that day
      expected = File.read("#{__dir__}/../data/000018677-20220808-upd.tsv")
      expect(generated).to eq(expected)
    end

    it "pushes expected metrics to pushgateway" do
      pm_endpoint = ENV["PUSHGATEWAY"]
      Faraday.delete("#{pm_endpoint}/metrics/job/generate_hathifile_test")

      # run as above
      # One particular UC record from a day in August 2022
      system("cp #{__dir__}/../data/000018677-20220807.json #{Settings.zephir_dir}/zephir_upd_20220807.json")
      GenerateHathifile.new.run
      metrics = Faraday.get("#{pm_endpoint}/metrics").body

      expect(metrics).to match(/^job_last_success\S*job="generate_hathifiles"\S* \S+/m)
        .and match(/^job_records_processed\S*job="generate_hathifiles"\S* 1$/m)
    end
  end

  describe "#batch_extract_rights" do
    it "extracts rights_timestamp and access_profile" do
      rights = GenerateHathifile.new.batch_extract_rights("test.pd_google")
      expect(rights).to be_a(Hash)
      expect(rights["test.pd_google"]).not_to be_nil
      expect(rights["test.pd_google"][:rights_timestamp]).to be_a(Time)
      expect(rights["test.pd_google"][:access_profile]).to be_a(String)
    end
  end
end
