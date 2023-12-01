# frozen_string_literal: true

require "date"

class ZephirFile
  attr_reader :filename

  def initialize(filename)
    @filename = File.basename(filename)
  end

  def type
    @type ||= filename.split("_")[1]
  end

  def date
    @date ||= Date.parse(filename.split("_")[2].split(".").first)
  end

  # The corresponding hathifile
  # Date is one day later than the Zephir file
  def hathifile
    "hathi_#{type}_#{date.next.strftime("%Y%m%d")}.txt.gz"
  end
end
