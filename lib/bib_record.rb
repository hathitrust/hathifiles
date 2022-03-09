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

  attr_accessor :marc, :ht_bib_key, :oclc_num, :isbn, :issn, :lccn, :lccns, :title, :imprint, :pub_place, :lang, :bib_fmt, :author, :us_gov_doc_flag

  def initialize(marc_in_json)
    @marc = MARC::Record.new_from_hash(JSON.parse(marc_in_json))
  end

  def ht_bib_key
    @ht_bib_key ||= Traject::MarcExtractor.cached('001').extract(marc).first
  end

  def oclc_num
    @oclc_num ||= Traject::MarcExtractor.cached('035a').extract(marc).collect! do |o|
      Traject::Macros::Marc21Semantics.oclcnum_extract(o)
    end.compact.reverse
  end

  def isbn
    @isbn ||= Traject::MarcExtractor.cached('020a').extract(marc)
  end

  def issn
    @issn ||= Traject::MarcExtractor.cached('022a').extract(marc)
  end

  def issns
    @issns ||= @issns.split(",")
  end

  def lccn
    @lccn ||= Traject::MarcExtractor.cached('010a').extract(marc)
  end

  def title
    @title ||= Traject::MarcExtractor.cached('245abcnp').extract(marc).first
  end

  def imprint
    @imprint ||= Traject::MarcExtractor.cached('260bc').extract(marc)
  end

  def u_and_f?
    /^.{17}u.{10}f/.match? marc['008']&.value
  end 

  def pub_place
    @pub_place ||= PlaceOfPublication.new(marc)
  end

  def bib_fmt
    return @bib_fmt unless @bib_fmt.nil?
    rec_type = marc.leader[6]
    bib_level = marc.leader[7]
    if ['a','t'].include?(rec_type) && ['a','c','d','m'].include?(bib_level)
      @bib_fmt = "BK"
    elsif rec_type == 'm' && ['a','c','d','m','s'].include?(bib_level)
      @bib_fmt = "CF"
    elsif ['g','k','o','r'].include?(rec_type) && ['a','c','d','m','s'].include?(bib_level)
      @bib_Fmt = "VM"
    elsif ['c','d','i','j'].include?(rec_type) && ['a','c','d','m','s'].include?(bib_level)
      @bib_fmt = "MU"
    elsif ['e','f'].include?(rec_type) && ['a','c','d','m','s'].include?(bib_level)
      @bib_fmt = "MP"
    elsif rec_type == "a" && ['b','s','i'].include?(bib_level)
      @bib_fmt = "SE"
    elsif ['b','p'].include?(rec_type) && ['a','c','d','m','s'].include?(bib_level)
      @bib_fmt = "MX"
    elsif bib_level == "s"
      @bib_fmt = "SE"
    else
      @bib_fmt = "XX"
    end
    @bib_fmt
  end

  def lang
    @lang ||= Traject::MarcExtractor.cached('008[35-37]').extract(marc).first
  end

  def author
    @author ||= [Traject::MarcExtractor.cached('100abcd').extract(marc),
                Traject::MarcExtractor.cached('110abcd').extract(marc),
                Traject::MarcExtractor.cached('111acd').extract(marc)].flatten
  end

  def us_gov_doc_flag
    return @us_gov_doc_flag unless @us_gov_doc_flag.nil?
    @us_gov_doc_flag = 0
    @us_gov_doc_flag = 1 if marc['008'].value[28] == "f" && pub_place.to_s[2] == 'u' &&
      !exception? && !nist_nsrds? && !ntis? &&
      !armed_forces_communications_association? && !national_research_council? &&
      !smithsonian? && !national_gallery_of_art? && !federal_reserve?
    @us_gov_doc_flag
  end

  def item_records
    return enum_for(:item_records) unless block_given?

    marc.each_by_tag('974') do |holding_field|
      yield ItemRecord.new(holding_field)
    end
  end

  def hathifile_records
    return enum_for(:hathifile_records) unless block_given?
    item_records.each do |ir|
      # merge bib and item level fields
      yield self.to_h.merge(ir.to_h)
    end
  end

  def to_h
    { oclc_num: oclc_num,
      isbn: isbn,
      issn: issn,
      lccn: lccn,
      title: title,
      imprint: imprint,
      ht_bib_key: ht_bib_key,
      pub_place: pub_place.to_s,
      lang: lang,
      bib_fmt: bib_fmt,
      us_gov_doc_flag: us_gov_doc_flag}
  end

  def sdr_nums
    return @sdr_nums unless @sdr_nums.nil?
    Traject::MarcExtractor.cached('035a').extract(marc).each do |sdr|
      next unless sdr =~ /^(sdr-|ia-)/
    end
  end

     
end

=begin
htid
access
rights

b ht_bib_key

description

source

source_bib_num

b oclc_num
b isbn
b issn
b lccn
b title
b imprint

rights_reason_code
rights_timestamp

#us_gov_doc_flag

rights_date_used

b pub_place
b lang
b bib_fmt

collection_code
content_provider_code
responsible_entity_code
digitization_agent_code
access_profile_code

b author
=end
