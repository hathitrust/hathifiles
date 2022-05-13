#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "settings"

class HathifileListing
  attr_accessor :url_base, :file_list, :cutoff, :hathifile_dir, :hathifile_web_dir, :hathifile_listing, :days_retro

  def initialize(hathifile_dir = nil, hathifile_web_dir = nil, days_retro = 70)
    @hathifile_dir = (hathifile_dir || Settings.hathifiles_dir)
    @hathifile_web_dir = (hathifile_web_dir || Settings.hathifiles_web_path)
    @hathifile_listing = @hathifile_web_dir + "hathi_file_list.json"
    @days_retro = days_retro
  end

  def run
    url_base = "https://www.hathitrust.org/sites/www.hathitrust.org/files/hathifiles/"
    file_list = []
    cutoff = Date.today - days_retro

    Dir.glob("#{hathifile_dir}hathi_*.txt.gz").each do |hfile|
      hfile_date = Date.parse(File.basename(hfile, ".txt.gz").split("_")[2])

      # if less than days_retro days old, make sure we have it in the web dir
      if hfile_date > cutoff && !File.exist?(hathifile_web_dir + hfile)
        FileUtils.cp(hfile, hathifile_web_dir, preserve: true)
      end
    end

    Dir.glob("#{hathifile_web_dir}hathi_*.txt.gz").each do |hfile|
      hfile_date = Date.parse(File.basename(hfile, ".txt.gz").split("_")[2])
      # remove it if it's too old
      if hfile_date < cutoff
        FileUtils.rm(hfile)
      else
        # add it to the listing
        file = {"filename" => File.basename(hfile),
                "full" => File.basename(hfile).match?(/_full_/),
                "size" => File.size(hfile),
                "created" => File.ctime(hathifile_dir + File.basename(hfile)).to_s,
                "modified" => File.mtime(hathifile_dir + File.basename(hfile)).to_s,
                "url" => url_base + File.basename(hfile)}
        file_list << file
      end
    end

    file_list_file = File.open(hathifile_listing, "w")
    file_list_file.puts file_list.to_json
  end
end

HathifileListing.new(ARGV.shift, ARGV.shift).run if __FILE__ == $PROGRAM_NAME
