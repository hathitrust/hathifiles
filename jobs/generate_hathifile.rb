#!/usr/bin/env ruby
# frozen_string_literal: true

require "bib_record"
require "date"
require "settings"
require "push_metrics"

class GenerateHathifile
  attr_reader :intype

  def initialize(intype)
    @intype = intype
  end

  def run
    tracker = PushMetrics.new(batch_size: 10_000, job_name: "generate_hathifile_#{intype}")
    infile = Dir.glob(File.join(Settings.zephir_dir, "zephir_#{intype}*")).max

    fin = if /\.gz$/.match?(infile)
      Zlib::GzipReader.open(infile)
    else
      File.open(infile)
    end

    # we only want to write some of the items in the zephr records
    indate = File.basename(infile).split("_")[2].split(".").first
    cutoff = if /upd/.match?(infile)
      # cutoff = Date.today.prev_day.strftime("%Y%m%d").to_i
      indate.to_i - 1
    else
      0
    end

    # Hathifiles date is one day later than the Zephir file
    outdate = Date.parse(indate).next_day.strftime("%Y%m%d")

    outfile = File.join(Settings.hathifiles_dir, "hathi_#{intype}_#{outdate}.txt")
    fout = File.open(outfile, "w")

    puts "Infile: #{infile}"
    puts "Outfile: #{outfile}"
    puts "Cutoff: #{cutoff}"

    fin.each do |line|
      BibRecord.new(line).hathifile_records.each do |rec|
        next unless rec[:update_date].to_i > cutoff.to_i
        outrec = [rec[:htid],
          rec[:access],
          rec[:rights],
          rec[:ht_bib_key],
          rec[:description],
          (rec[:source] || ""),
          (rec[:source_bib_num].join(",") || ""),
          rec[:oclc_num].join(","),
          rec[:isbn].join(","),
          rec[:issn].join(","),
          rec[:lccn].join(","),
          rec[:title].join(","),
          rec[:imprint].join(", "),
          (rec[:rights_reason_code] || ""),
          (rec[:rights_timestamp]&.strftime("%Y-%m-%d %H:%M:%S") || ""),
          rec[:us_gov_doc_flag],
          rec[:rights_date_used],
          rec[:pub_place],
          rec[:lang],
          rec[:bib_fmt],
          (rec[:collection_code] || ""),
          (rec[:content_provider_code] || ""),
          (rec[:responsible_entity_code] || ""),
          (rec[:digitization_agent_code] || ""),
          (rec[:access_profile] || ""),
          (rec[:author].join(", ") || "")]
        fout.puts outrec.join("\t")
      end
      tracker.increment_and_log_batch_line
    end

    fout.close
    system("gzip #{outfile}")

    tracker.log_final_line
  end
end

GenerateHathifile.new(ARGV.shift).run if __FILE__ == $PROGRAM_NAME
