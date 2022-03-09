# frozen_string_literal: true


module USFedDoc
  require "filter"
  require "filter/blacklist"

  def exception?
    oclc_num&.any? { |o| Blacklist.oclcs.include? o}
  end

  def nist_nsrds?
    Traject::MarcExtractor.cached('400:410:411:440:490:800:810:811:830')
      .extract(marc) =~ /(nsrds|national standard reference data series)/i
  end

  def ntis?
      imprint =~ /ntis|national technical information service/i
  end

  def armed_forces_communications_association?
    Traject::MarcExtractor.cached('260:264:110:710')
      .extract(marc) =~ /armed forces communications (association|communications and electronics association)/i
  end

  def national_research_council?
    auth = Traject::MarcExtractor.cached('260:264:110:710').extract(marc)
    auth =~ /national research council/i && auth !~ /canada/i
  end

  def smithsonian?
    Traject::MarcExtractor.cached('260:264:110:130:710')
      .extract(marc) =~ /smithsonian/i
  end

  def national_gallery_of_art?
    Traject::MarcExtractor.cached('260:264:110:710')
      .extract(marc) =~ /national gallery of art/i
  end

  def federal_reserve?
    Traject::MarcExtractor.cached('100:110:111:700:710:711')
      .extract(marc) =~ /federal reserve/i
  end

end

