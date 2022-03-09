# frozen_string_literal: true

require "marc"

class ItemRecord

  attr_accessor :marc, :htid, :description, :source, :rights, :rights_reason_code, :rights_timestamp, :rights_determination_note, :rights_date_used, :collection_code, :content_provider_code, :access, :source_bib_num, :responsible_entity_code, :access_profile_code

  def initialize(marc=nil)
    unless marc.nil?
      @marc = marc
    end
  end

  def htid
    @htid ||= marc['u']
  end

  def description
    @description ||= (marc['z'] || '')
  end

  def source
  end

  def rights
    @rights ||= marc['r']
  end

  def rights_reason_code
    @rights_reason_code ||= marc['q']
  end

  def rights_timestamp
    @rights_timestamp ||= marc['d']
  end

  def rights_determination_note
    @rights_determination_note ||= marc['t']
  end

  def rights_date_used
    @rights_date_used ||= marc['y']
  end

  def collection_code
    @collection_Code ||= marc['c']
  end

  def digitization_agent_code
    @digitization_agent_code ||= marc['s']
  end

  def content_provider_code
  end      

  def to_h
    { htid: htid,
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
      access_profile_code: access_profile_code
    }
  end    
end
