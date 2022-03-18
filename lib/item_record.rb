# frozen_string_literal: true

require "marc"
require "services"

class ItemRecord
  attr_accessor :marc, :sdr_nums
  attr_writer :htid, :access, :description, :source, :source_bib_num, :rights, :rights_reason_code, :rights_timestamp, :rights_determination_note, :rights_date_used, :collection_code, :content_provider_code, :access_profile_code

  def initialize(marc = nil, sdr_nums = nil)
    unless marc.nil?
      @marc = marc
    end
    @sdr_nums = sdr_nums || {}
  end

  # Volume identifier
  def htid
    @htid ||= marc["u"]
  end

  def access
    return @access unless @access.nil?
    @access = if /^(pdus$|pd$|world|ic-world|cc|und-world)/.match?(rights)
      "allow"
    else
      "deny"
    end
  end

  # Enumeration / chronology from the 974z
  def description
    @description ||= (marc["z"] || "")
  end

  # In theory, it is the "Code identifying the source of the bibliographic record..."
  def source
    @source ||= (marc["b"] || "")
  end

  # In theory, it is "the Local bibliographic record number used in the catalog
  # of the library that contributed the item."
  # In practice it's the first matching record number for the contributing library,
  # as multiple catalog records from the same library can end up on a single Zephir
  # record. I think.
  def source_bib_num
    sdr_nums[collection_code.downcase] || ""
  end

  def rights
    @rights ||= marc["r"]
  end

  def rights_reason_code
    @rights_reason_code ||= marc["q"]
  end

  def rights_timestamp
    # @rights_timestamp ||= marc['d']
    @rights_timestamp = rights_from_db.time
  end

  def rights_determination_note
    @rights_determination_note ||= marc["t"]
  end

  # From the rights database
  def rights_date_used
    # Have to use bib rights to match current data but that's not worth it
    @rights_date_used ||= (marc["y"] || "9999")
  end

  def collection_code
    @collection_code ||= marc["c"]
  end

  def responsible_entity_code
    @responsible_entity_code ||= Services.ht_collections[collection_code].responsible_entity
  end

  def digitization_agent_code
    @digitization_agent_code ||= marc["s"]
  end

  # From the rights database
  def content_provider_code
    @content_provider_code ||= Services.ht_collections[collection_code].content_provider_cluster
  end

  # From the rights database
  def access_profile_code
    rights_from_db.access_profile
  end

  def access_profile
    # TODO: use the actual mapping table
    mapping = {1 => "open",
               2 => "google",
               3 => "page",
               4 => "page+lowres"}
    mapping[access_profile_code] || access_profile_code
  end

  def to_h
    {htid: htid,
     access: access,
     rights: rights,
     description: description,
     source: source,
     source_bib_num: source_bib_num,
     rights_reason_code: rights_reason_code,
     rights_timestamp: rights_timestamp,
     rights_date_used: rights_date_used,
     collection_code: collection_code,
     content_provider_code: content_provider_code,
     responsible_entity_code: responsible_entity_code,
     digitization_agent_code: digitization_agent_code,
     access_profile_code: access_profile_code,
     access_profile: access_profile}
  end

  private

  def rights_from_db
    @rights_from_db ||= Services.rights.new(item_id: htid)
  end
end
