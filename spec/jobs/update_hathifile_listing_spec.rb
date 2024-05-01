# frozen_string_literal: true

require "faraday"
require "spec_helper"
require_relative "../../jobs/update_hathifile_listing"

RSpec.describe HathifileListing do
  shared_context :uses_temp_dirs do
    around do |example|
      Dir.mktmpdir(Settings.hathifiles_dir) do |dir|
        @tmp_hathifiles_dir = dir
        # generate update files
        thisday = Date.today
        while thisday > Date.today - 90
          FileUtils.touch(@tmp_hathifiles_dir +
            "/hathi_upd_#{thisday.strftime("%Y%m%d")}.txt.gz")
          thisday -= 1
        end
        # generate full files
        FileUtils.touch(@tmp_hathifiles_dir +
          "/hathi_full_#{Date.today.strftime("%Y%m01")}.txt.gz")
        FileUtils.touch(@tmp_hathifiles_dir +
          "/hathi_full_#{Date.today.prev_month.strftime("%Y%m01")}.txt.gz")
        FileUtils.touch(@tmp_hathifiles_dir +
          "/hathi_full_#{Date.today.prev_month.prev_month.strftime("%Y%m01")}.txt.gz")

        Dir.mktmpdir(Settings.hathifiles_web_path) do |dir|
          @tmp_web_dir = dir
          example.run
          Dir.glob(@tmp_web_dir + "/*").each { |file| File.delete(file) }
        end
      end
    end
  end

  describe "#initialize" do
    it "uses the environment defaults" do
      expect(described_class.new.hathifile_dir).to eq("/usr/src/app/tmp_hathifiles_archive/")
      expect(described_class.new.hathifile_web_dir).to eq("/usr/src/app/tmp_web_hathifiles/")
    end
  end

  describe "#run" do
    include_context :uses_temp_dirs

    let(:hflist) { described_class.new(@tmp_hathifiles_dir + "/", @tmp_web_dir + "/") }

    it "should have a full hathifile archive tmp dir" do
      expect(Dir.glob(@tmp_hathifiles_dir + "/*").count).to eq(93)
    end

    it "should have an empty hathifile web tmp dir" do
      expect(Dir.glob(@tmp_web_dir + "/*").count).to eq(0)
    end

    it "copies 70 update files to the web dir" do
      hflist.run
      expect(Dir.glob(@tmp_web_dir + "/*upd*").count).to eq(70)
    end

    it "copies 2 or 3 full files to the web dir" do
      hflist.run
      expect(Dir.glob(@tmp_web_dir + "/*full*").count).to be_between(2, 3)
    end

    it "writes a json file list" do
      hflist.run
      list = JSON.parse(File.read(@tmp_web_dir + "/hathi_file_list.json"))
      expect(list.count).to be_between(72, 73)
    end

    it "sorts the json file list" do
      hflist.run
      list = JSON.parse(File.read(@tmp_web_dir + "/hathi_file_list.json"))
      filenames = list.map { |hf| hf["filename"] }
      sorted = filenames.sort
      expect(filenames).to eq(sorted)
    end

    it "maintains the original creation dates" do
      hflist.run
      arch_file = Dir.glob(@tmp_hathifiles_dir + "/*").last
      web_file = Dir.glob(@tmp_web_dir + "/*").last
      expect(File.mtime(arch_file).to_i).to eq(File.mtime(web_file).to_i)
    end

    it "pushes expected metrics to pushgateway" do
      pm_endpoint = ENV["PUSHGATEWAY"]
      Faraday.delete("#{pm_endpoint}/metrics/job/update_hathifile_listing")

      hflist.run
      metrics = Faraday.get("#{pm_endpoint}/metrics").body

      expect(metrics).to match(/^job_last_success\S*job="update_hathifile_listing"\S* \S+/m)
        .and match(/^job_records_processed\S*job="update_hathifile_listing"\S* [^0]\d*$/m)
    end

    it "removes existing files that are too old" do
      # Make some files that are about half a year old
      old_files = []
      5.times do |i|
        old_file = File.join(@tmp_web_dir, "/hathi_upd_#{(Date.today - (180 + i)).strftime("%Y%m%d")}.txt.gz")
        FileUtils.touch(old_file)
        old_files << old_file
      end
      hflist.run
      old_files.each do |old_file|
        expect(File.exist?(old_file)).to eq(false)
      end
    end
  end
end
