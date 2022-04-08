# frozen_string_literal: true

module USFedDoc
  require "filter"
  require "filter/rejected_list"

  def exception_to_rule?
    excluded_oclc_number? ||
      nist_nsrds? ||
      ntis? ||
      armed_forces_communications_association? ||
      national_research_council? ||
      smithsonian? ||
      national_gallery_of_art? ||
      federal_reserve?
  end

  def excluded_oclc_number?
    oclc_num&.any? { |o| RejectedList.oclcs.include? o.to_i }
  end

  def nist_nsrds?
    Traject::MarcExtractor.cached("400:410:411:440:490:800:810:811:830")
      .extract(marc).any?(/(nsrds|national standard reference data series)/i)
  end

  def ntis?
    Traject::MarcExtractor.cached("260:264")
      .extract(marc).any?(/ntis|national technical information service/i)
  end

  def armed_forces_communications_association?
    Traject::MarcExtractor.cached("260:264:110:710")
      .extract(marc).any?(/armed forces communications (association|communications and electronics association)/i)
  end

  def national_research_council?
    auth = Traject::MarcExtractor.cached("260:264:110:710").extract(marc)
    auth.any?(/national research council/i) && auth.none?(/canada/i)
  end

  def smithsonian?
    Traject::MarcExtractor.cached("260:264:110:130:710")
      .extract(marc).any?(/smithsonian/i)
  end

  def national_gallery_of_art?
    Traject::MarcExtractor.cached("260:264:110:710")
      .extract(marc).any?(/national gallery of art/i)
  end

  def federal_reserve?
    Traject::MarcExtractor.cached("100:110:111:700:710:711")
      .extract(marc).any?(/federal reserve/i)
  end
end
