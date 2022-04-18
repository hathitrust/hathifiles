# frozen_string_literal: true

require "services"

# Builds a mapping of collection codes to sdr num prefixes based on the cdl contrib configs
class SdrNumPrefixes
  attr_reader :prefix_map

  def initialize
    # collection code => prefixes
    @prefix_map = Hash.new { |h, k| h[k] = [] }
    Dir.glob("config/hathitrust_contrib_configs/*.config").each do |confile|
      conf = parse_config(confile)
      if conf.has_key?("collection") && conf.has_key?("campus_code")
        conf["collection"].each do |coll|
          @prefix_map[coll] += conf["campus_code"]
          @prefix_map[coll].uniq!
        end
      end
    end
  end

  def [](collection_code)
    @prefix_map[collection_code]
  end

  def each
    return enum_for(:each) unless block_given?

    @prefix_map.each { |collection_code, prefixes| yield [collection_code, prefixes] }
  end

  private

  # converts the config to a hash
  def parse_config(fin)
    conf = {}
    File.open(fin).each do |line|
      left, right = line.chomp.split(" = ")
      next if right.nil?
      key = left.split(".").last.strip.downcase
      # some values are formatted as arrays # miu-multi.collection = [MIU,GWLA,UMLAW...]
      values = right.gsub(/[\[\]]/, "").split(",").map { |v| v.strip.downcase }
      conf[key] = values
    end
    conf
  end
end
