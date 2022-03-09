# frozen_string_literal: true

require 'spec_helper'
require 'bib_record'

RSpec.describe BibRecord do
  let(:m) { File.open(File.dirname(__FILE__) + '/data/bib_rec.json').read }
  let(:br) { described_class.new(m) }

  describe "#initialize" do
    it "reads json into marc field" do
      expect(br.marc).to be_a MARC::Record
    end
  end

  describe "#ht_bib_key" do
    it "extracts the bib key" do
      expect(br.ht_bib_key).to eq("011338539")
    end
  end

  describe "#oclc_num" do
    it "extracts the OCLC numbers" do
      expect(br.oclc_num).to eq(["5971627","63970006"])
    end
  end

  describe "#isbn" do
    it "extracts the ISBN" do
      expect(br.isbn).to eq(["091072413X"])
    end
  end

  describe "#issn" do
    it "extracts the ISSN from the 022a" do
      expect(br.issn).to eq(["1474-0699","1356-1898","0041-977X"])
    end
  end

  describe "#lccn" do
    it "extracts the LCCN from the 010a" do
      expect(br.lccn).to eq(["70518371"])
    end
  end

  describe "#title" do
    it "extracts the title from the 245abcnp" do
      expect(br.title).to eq("Committee on Foreign Relations, United States--subcommittees / February 1976.")
    end
  end

  describe "#imprint" do
    it "extracts the imprint from the 260bc" do
      expect(br.imprint).to eq(["U.S. Govt. Print. Off., 1976."])
    end
  end

  describe "#u_and_f?" do
    # An item may override this if the rights don't match
    it "detects presence of the u and f in the 008" do
      expect(br.u_and_f?).to be true
    end

  end

  describe "#pub_place" do
    it "has a POP from the 008" do
      expect(br.pub_place.to_s).to eq("dcu")
    end
  end

  describe "#author" do
    it "extracts the author from the 100abcd, 110abcd, 111acd" do
      expect(br.author).to eq(["United States. Congress. Senate. Committee on Foreign Relations"])
    end
  end

  describe "#lang" do
    it "extracts the language code" do
      expect(br.lang).to eq("eng")
    end
  end

  describe "#bib_fmt" do
    it "extracts the bib_fmt" do
      expect(br.bib_fmt).to eq("BK")
    end
  end

  describe "#sdr_nums" do
    it "assembles a mapping of collection codes to bib numbers" do
    end
  end

  describe "Integration" do
    xit "can generate an entire hathifile" do
    end
  end 

  describe "#item_records" do
    it "generates a list of ItemRecords from the 974s" do
      binding.pry
      item_records = br.item_records.to_a
      expect(item_records.count).to eq(2)
    end 
  end
end
