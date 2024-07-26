# frozen_string_literal: true

require "date"

require "bib_record"
require "services"
require "settings"

class HathifileWriter
  attr_reader :hathifile, :tempfile, :queue
  QUEUE_LIMIT = 100

  def initialize(hathifile:)
    @hathifile = hathifile
    @tempfile = Tempfile.create("hathifiles")
    Services[:logger].info "writing to tempfile #{tempfile.path}"
    @queue = []
    @access_profiles = Services.db[:access_profiles].as_hash(:id)
  end

  def add(records = [])
    records.each do |record|
      @queue << record
      export_queue
    end
  end

  def finish
    export_queue(force: true)
    tempfile.close
    Services[:logger].info "Gzipping: #{tempfile.path}"
    system("gzip #{tempfile.path}")
    gzfile = tempfile.path + ".gz"
    # Move tempfile into place
    outfile = File.join(Settings.hathifiles_dir, hathifile)
    Services[:logger].info "Moving tempfile #{gzfile} -> #{outfile}"
    FileUtils.mv(gzfile, outfile)
    Services[:logger].info "Setting 0644 permissions on #{outfile}"
    FileUtils.chmod(0o644, outfile)
  end

  # Convert all of the records in the queue to tab-delimited entries,
  # fill in the rights information, and export to file.
  def export_queue(force: false)
    if @queue.size >= QUEUE_LIMIT || force
      htids = @queue.map { |rec| rec[:htid] }
      htids_to_rights = batch_extract_rights(htids)
      @queue.each do |rec|
        rights = htids_to_rights[rec[:htid]] || {}
        rec[:rights_timestamp] = rights[:rights_timestamp]
        rec[:access_profile] = rights[:access_profile]
        tempfile.puts record_from_bib_record(rec).join("\t")
      end
      @queue.clear
    end
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
