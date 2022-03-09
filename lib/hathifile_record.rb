# frozen_string_literal: true

require "marc"
require "traject"
require "json"

class ItemRecord

  attr_accessor :htid, :access, :rights, :description, :source_bib_num, :rights_reason_code,
    :rights_timestamp, :rights_date_used, :collection_code, :content_provider_code,
    :responsible_tentity_code, :digitization_agent_code, :access_profile_code
  
  def initialize(nine_seven_four)

