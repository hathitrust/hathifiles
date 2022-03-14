# frozen_string_literal: true

require "marc"

class PlaceOfPublication
  attr_accessor :marc, :raw_pub_place, :place_code

  def initialize(marc = nil)
    unless marc.nil?
      @marc = marc 
      raw_pub_place
    end
  end

  def raw_pub_place
    @raw_pub_place ||= (marc['008']&.value&.slice(15..17)&.downcase || '')
  end

  # Cleans up the raw_pub_place
  def place_code
    return @place_code unless @place_code.nil?
    @place_code = raw_pub_place.gsub(/[?|^]/, ' ')
    @place_code = '   ' unless @place_code =~ /^[a-z ]{2,3}/
    @place_code = 'pru' if @place_code =~ /^pr/
    @place_code = 'xxu' if @place_code =~ /^us/
    @place_code
  end

  def to_s
    place_code
  end
end
