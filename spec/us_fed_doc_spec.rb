# frozen_string_literal: true

require "spec_helper"
require "us_fed_doc"
require "bib_record"

RSpec.describe USFedDoc do
  let(:rec) { BibRecord.new(File.read(File.dirname(__FILE__) + "/data/bib_rec.json")) }

  describe "#exception?" do
    it "is an exception if it has a reject oclc number " do
      rec.oclc_num << RejectedList.oclcs.first
      expect(rec.exception?).to be true
    end
  end

  describe "#nist_nsrds?" do
    it "detects an NSRDS record" do
      nsrds_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
        "/data/nsrds_bib_rec.json"))
      expect(nsrds_rec.nist_nsrds?).to be true
    end
  end

  describe "#ntis?" do
    it "detects an NTIS record" do
      ntis_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
         "/data/ntis_bib_rec.json"))
      expect(ntis_rec.ntis?).to be true
    end
  end

  describe "#armed_forces_communications_association?" do
    it "detects an Armed Forces Communications Association record" do
      afca_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
        "/data/afca_bib_rec.json"))
      expect(afca_rec.armed_forces_communications_association?).to be true
    end
  end

  describe "#national_research_council?" do
    it "detects an NRC record" do
      nrc_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
        "/data/nrc_bib_rec.json"))
      expect(nrc_rec.national_research_council?).to be true
    end
  end

  describe "#smithsonian?" do
    it "detects a smithsonian record" do
      smith_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
          "/data/smithsonian_bib_rec.json"))
      expect(smith_rec.smithsonian?).to be true
    end
  end

  describe "#national_gallery_of_art?" do
    it "detects an NGOA record" do
      ngoa_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
          "/data/ngoa_bib_rec.json"))
      expect(ngoa_rec.national_gallery_of_art?).to be true
    end
  end

  describe "#federal_reserve?" do
    it "detects a Federal Reserve record" do
      fr_rec = BibRecord.new(File.read(File.dirname(__FILE__) +
          "/data/federal_reserve_bib_rec.json"))
      expect(fr_rec.federal_reserve?).to be true
    end
  end
end
