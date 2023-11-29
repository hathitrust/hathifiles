#!/usr/bin/env ruby
# frozen_string_literal: true

require "bib_record"
require "date"
require "settings"
require "push_metrics"
require "zephir_files"

class GenerateHathifile
  def run
    zephir_files = ZephirFiles.new(
      zephir_dir: Settings.zephir_dir,
      hathifiles_dir: Settings.hathifiles_dir
    )
    zephir_files.unprocessed.each do |zephir_file|
      run_file zephir_file
    end
  end

  def run_file(zephir_file)
    infile = File.join(Settings.zephir_dir, zephir_file.filename)
    tracker = PushMetrics.new(batch_size: 10_000, job_name: "generate_hathifile_#{zephir_file.type}")

    fin = if /\.gz$/.match?(infile)
      Zlib::GzipReader.open(infile)
    else
      File.open(infile)
    end

    # we only want to write some of the items in the zephr records
    cutoff = if zephir_file.type == "upd"
      zephir_file.date.strftime("%Y%m%d").to_i
    else
      0
    end

    outfile = File.join(Settings.hathifiles_dir, zephir_file.hathifile)

    puts "Infile: #{infile}"
    puts "Outfile: #{outfile}"
    puts "Cutoff: #{cutoff}"

    Tempfile.create do |fout|
      fin.each do |line|
        BibRecord.new(line).hathifile_records.each do |rec|
          next unless rec[:update_date].to_i > cutoff.to_i
          fout.puts record_from_bib_record(rec).join("\t")
        end
        tracker.increment_and_log_batch_line
      end
      fout.flush
      system("gzip #{fout.path}")
      gzfile = fout.path + ".gz"
      # Move tempfile into place
      FileUtils.mv(gzfile, outfile)
    end
    fin.close
    tracker.log_final_line
  end

  def record_from_bib_record(rec)
    [
      rec[:htid],
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
      (rec[:author].join(", ") || "")
    ]
  end
end

GenerateHathifile.new.run if __FILE__ == $PROGRAM_NAME
