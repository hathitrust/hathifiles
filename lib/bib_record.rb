# frozen_string_literal: true

require "marc"
require "traject"
require "traject/macros/marc21_semantics"
require "json"
require "place_of_publication"
require "us_fed_doc"
require "item_record"

class BibRecord
  include USFedDoc

  attr_accessor :marc
  attr_writer :ht_bib_key, :oclc_num, :isbn, :issn, :lccn, :title, :imprint, :pub_place, :bib_fmt, :lang, :author, :us_gov_doc_flag

  def initialize(marc_in_json)
    @marc = MARC::Record.new_from_hash(JSON.parse(marc_in_json))
  end

  def ht_bib_key
    @ht_bib_key ||= Traject::MarcExtractor.cached("001").extract(marc).first
  end

  def oclc_num
    @oclc_num ||= Traject::MarcExtractor.cached("035a").extract(marc).collect! do |o|
      # Preferred way to do it, but it doesn't match existing records
      # Traject::Macros::Marc21Semantics.oclcnum_extract(o)
      regexp = /(\(oco{0,1}lc\)|ocm|ocn)(\d+)/i
      match = regexp.match(o)
      match.nil? ? nil : match[2]
    end.compact
      .map { |o| o.to_i.to_s }.uniq.sort
  end

  def isbn
    @isbn ||= Traject::MarcExtractor.cached("020a").extract(marc).map { |isbn| isbn.strip }&.uniq
  end

  def issn
    @issn ||= Traject::MarcExtractor.cached("022a").extract(marc).map { |issn| issn.strip }&.uniq
  end

  def lccn
    @lccn ||= Traject::MarcExtractor.cached("010a").extract(marc).map { |lccn| lccn.strip }&.uniq
  end

  def title
    @title ||= Traject::MarcExtractor.cached("245abcnp").extract(marc).map { |title| title.strip }
  end

  def imprint
    return @imprint unless @imprint.nil?
    @imprint = Traject::MarcExtractor.cached("260bc").extract(marc).map { |imp| imp.strip }
    if @imprint.none?
      @imprint = Traject::MarcExtractor.cached("264|*1|bc").extract(marc).map { |imp| imp.strip }
    end
    @imprint
  end

  def u_and_f?
    /^.{17}u.{10}f/.match? marc["008"]&.value
  end

  def pub_place
    @pub_place ||= PlaceOfPublication.new(marc)
  end

  # TODO: This is a reimplementation of
  # https://github.com/mlibrary/traject_umich_format/blob/7d355a5be133dc86f8795954fdd2e01355758309/lib/traject/umich_format/bib_format.rb#L18
  def bib_fmt
    return @bib_fmt unless @bib_fmt.nil?
    rec_type = marc.leader[6]
    bib_level = marc.leader[7]
    @bib_fmt = if ["a", "t"].include?(rec_type) && ["a", "c", "d", "m"].include?(bib_level)
      "BK"
    elsif rec_type == "m" && ["a", "c", "d", "m", "s"].include?(bib_level)
      "CF"
    elsif ["g", "k", "o", "r"].include?(rec_type) && ["a", "b", "c", "d", "m", "s"].include?(bib_level)
      "VM"
    elsif ["c", "d", "i", "j"].include?(rec_type) && ["a", "b", "c", "d", "m", "s"].include?(bib_level)
      "MU"
    elsif ["e", "f"].include?(rec_type) && ["a", "b", "c", "d", "m", "s"].include?(bib_level)
      "MP"
    elsif rec_type == "a" && ["b", "s", "i"].include?(bib_level)
      "SE"
    elsif ["b", "p"].include?(rec_type) && ["a", "b", "c", "d", "m", "s"].include?(bib_level)
      "MX"
    elsif bib_level == "s"
      "SE"
    else
      "XX"
    end
    @bib_fmt
  end

  def lang
    @lang ||= (Traject::MarcExtractor.cached("008[35-37]").extract(marc).first || "   ")
  end

  def author
    @author ||= [Traject::MarcExtractor.cached("100abcd").extract(marc),
      Traject::MarcExtractor.cached("110abcd").extract(marc),
      Traject::MarcExtractor.cached("111acd").extract(marc)]
      .flatten.map { |a| a.strip }.uniq
  end

  def us_gov_doc_flag
    return @us_gov_doc_flag unless @us_gov_doc_flag.nil?
    @us_gov_doc_flag = 0
    @us_gov_doc_flag = 1 if marc["008"].value[28] == "f" && pub_place.to_s[2] == "u" &&
      !exception_to_rule?
    @us_gov_doc_flag
  end

  def item_records
    return enum_for(:item_records) unless block_given?

    marc.each_by_tag("974") do |holding_field|
      yield ItemRecord.new(holding_field, sdr_nums)
    end
  end

  def hathifile_records
    return enum_for(:hathifile_records) unless block_given?
    item_records.each do |ir|
      # merge bib and item level fields
      yield to_h.merge(ir.to_h)
    end
  end

  def to_h
    {oclc_num: oclc_num,
     isbn: isbn,
     issn: issn,
     lccn: lccn,
     title: title,
     imprint: imprint,
     ht_bib_key: ht_bib_key,
     pub_place: pub_place.to_s,
     lang: lang,
     bib_fmt: bib_fmt,
     us_gov_doc_flag: us_gov_doc_flag,
     author: author}
  end

  def sdr_nums
    return @sdr_nums unless @sdr_nums.nil?
    @sdr_nums = Hash.new { |h, coll| h[coll] = [] }
    Traject::MarcExtractor.cached("035a").extract(marc).each do |sdr|
      next unless /^sdr-/.match?(sdr)
      # remove leading sdr-
      sdr.gsub!(/^sdr-/, "")
      # remove leading ia-
      sdr.gsub!(/^ia-/, "")
      Services.sdrnum_prefix_map.each do |collection_code, prefixes|
        prefixes.each do |prefix|
          sdr_match = /^#{prefix}([.a-zA-Z0-9-]+)/.match(sdr)
          next if sdr_match.nil?
          @sdr_nums[collection_code] << sdr_match[1].gsub(/^-loc/, "")
        end
      end
    end
    @sdr_nums
  end
end
