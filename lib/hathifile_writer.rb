# frozen_string_literal: true

require "date"

require "bib_record"
require "services"
require "settings"

class HathifileWriter
  attr_reader :tempfile, :queue
  QUEUE_LIMIT = 10_000

  def initialize()
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
  end

  # Convert all of the records in the queue to tab-delimited entries,
  # fill in the rights information, and export to file.
  def export_queue(force: false)
    if @queue.size >= QUEUE_LIMIT || force
      binding.irb
      htids = @queue.map { |rec| rec[:htid] }
      @queue.each do |rec|
        STDOUT.puts record_from_bib_record(rec).join("\t")
      end
      @queue.clear
    end
  end

  def record_from_bib_record(rec)
    [
      rec[:ht_bib_key],
      rec[:us_gov_doc_flag],
      rec[:pub_place],
      rec[:lang],
      rec[:bib_fmt],
      rec[:publish_date]
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
