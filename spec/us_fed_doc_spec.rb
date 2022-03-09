# frozen_string_literal: true

require "spec_helper"
require "us_fed_doc"

RSpec.describe USFedDoc do

  let(:rec) { BibRecord.new(File.open(File.dirname(__FILE__) + '/data/bib_rec.json').read) }

  describe "#exception?" do
  end

  describe "#nist_nsrds?" do
  end

  describe "#ntis?" do
  end

  describe "#armed_forces_communications_association?" do
  end

  describe "#national_research_council?" do
  end

  describe "#smithsonian?" do
  end

  describe "#national_gallery_of_art?" do
  end

  describe "#federal_reserve?" do
  end
end




