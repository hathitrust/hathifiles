#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(Pathname.new("#{File.dirname(__FILE__)}/../lib"))

require "bib_record"
require "date"
require "settings"
require "services"
require "push_metrics"
require "sequel"
require "zephir_files"

class GenerateHathifile
  attr_reader :tracker

  # Number of lines/cids to process in each outer loop;
  # we end up doing a rights query for all HTIDs under these lines
  SLICE_SIZE = 20

  def initialize
    @tracker = PushMetrics.new(batch_size: 5_000, job_name: "generate_hathifiles",
      logger: Services["logger"])
    @access_profiles = Services.db[:access_profiles].as_hash(:id)
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
      fin.each_slice(SLICE_SIZE) do |lines|
        recs = []
        lines.each do |line|
          recs += BibRecord.new(line).hathifile_records.to_a
        end
        htids = recs.map { |rec| rec[:htid] }
        htids_to_rights = batch_extract_rights(htids)
        last_bib_key = nil
        recs.each do |rec|
          rights = htids_to_rights[rec[:htid]] || {}
          rec[:rights_timestamp] = rights[:rights_timestamp]
          rec[:access_profile] = rights[:access_profile]
          fout.puts record_from_bib_record(rec).join("\t")
          if last_bib_key != rec[:ht_bib_key]
            tracker.increment_and_log_batch_line
            last_bib_key = rec[:ht_bib_key]
          end
        end
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

  # Map htid -> rights for this batch
  def batch_extract_rights(htids)
    htids_to_rights = {}
    split_htids = htids.map { |htid| htid.split(".", 2) }
    Services.db[:rights_current]
      .select(:namespace, :id, :time, :access_profile)
      .where([:namespace, :id] => split_htids)
      .each do |record|
      htid = record[:namespace] + "." + record[:id]
      htids_to_rights[htid] = {
        rights_timestamp: record[:time],
        access_profile: @access_profiles[record[:access_profile]][:name]
      }
    end
    htids_to_rights
  end
end

# Force logger to flush STDOUT on write so we can see what out Argo Workflows are doing.
$stdout.sync = true
if __FILE__ == $PROGRAM_NAME
  GenerateHathifile.new.run
end
