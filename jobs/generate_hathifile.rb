#!/usr/bin/env ruby
# frozen_string_literal: true

require "bib_record"
require "date"
require "settings"
require "services"
require "push_metrics"
require "zephir_files"

class GenerateHathifile
  attr_reader :tracker

  def initialize
    @tracker = PushMetrics.new(batch_size: 10_000, job_name: "generate_hathifiles")
  end

  def run
    Services[:logger].info "zephir_dir: #{Settings.zephir_dir}, hathifiles_dir: #{Settings.hathifiles_dir}"
    zephir_files = ZephirFiles.new(
      zephir_dir: Settings.zephir_dir,
      hathifiles_dir: Settings.hathifiles_dir
    )
    Services[:logger].info "Unprocessed Zephir files: #{zephir_files.unprocessed}"
    zephir_files.unprocessed.each do |zephir_file|
      run_file zephir_file
    end
    tracker.log_final_line
  end

  def run_file(zephir_file)
    infile = File.join(Settings.zephir_dir, zephir_file.filename)
    Services[:logger].info "Processing file: #{infile}"
    fin = if /\.gz$/.match?(infile)
      Zlib::GzipReader.open(infile)
    else
      File.open(infile)
    end

    outfile = File.join(Settings.hathifiles_dir, zephir_file.hathifile)
    Services[:logger].info "Outfile: #{outfile}"

    Tempfile.create("hathifiles") do |fout|
      Services[:logger].info "writing to tempfile #{fout.path}"
      fin.each_with_index do |line, i|
        if i % 100_000 == 0
          Services[:logger].info "writing line #{i}"
        end
        BibRecord.new(line).hathifile_records.each do |rec|
          fout.puts record_from_bib_record(rec).join("\t")
        end
        tracker.increment_and_log_batch_line
      end
      fout.flush
      Services[:logger].info "Gzipping: #{fout.path}"
      system("gzip #{fout.path}")
      gzfile = fout.path + ".gz"
      # Move tempfile into place
      Services[:logger].info "Moving tempfile #{gzfile} -> #{outfile}"
      FileUtils.mv(gzfile, outfile)
      Services[:logger].info "Setting 0644 permissions on #{outfile}"
      FileUtils.chmod(0o644, outfile)
    end
    fin.close
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

# Force logger to flush STDOUT on write so we can see what out Argo Workflows are doing.
$stdout.sync = true
GenerateHathifile.new.run if __FILE__ == $PROGRAM_NAME
