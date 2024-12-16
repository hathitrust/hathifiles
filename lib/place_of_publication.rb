# frozen_string_literal: true

require "marc"

class PlaceOfPublication
  attr_accessor :marc
  attr_writer :raw_pub_place, :place_code

  def initialize(marc = nil)
    unless marc.nil?
      @marc = marc
      raw_pub_place
    end
  end

  def raw_pub_place
    @raw_pub_place ||= marc["008"]&.value&.slice(15..17)&.downcase || ""
  end

  # Cleans up the raw_pub_place
  def place_code
    return @place_code unless @place_code.nil?
    @place_code = raw_pub_place.gsub(/[?|^]/, " ")
    @place_code = "   " unless /^[a-z ]{2,3}/.match?(@place_code)
    @place_code = "pru" if /^pr/.match?(@place_code)
    @place_code = "xxu" if /^us/.match?(@place_code)
    @place_code
  end

  def to_s
    place_code
  end
end
