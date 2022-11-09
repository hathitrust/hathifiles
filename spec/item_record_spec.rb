# frozen_string_literal: true

require "spec_helper"
require "item_record"

RSpec.describe ItemRecord do
  let(:m) do
    MARC::Record.new_from_hash(
      JSON.parse(File.read(File.dirname(__FILE__) + "/data/bib_rec.json"))
    )
  end
  let(:item_marc) { m.fields("974").first }

  let(:ir) { described_class.new(item_marc) }

  context "when given MARC 974 at initialize" do
    it "extracts the htid" do
      expect(ir.htid).to eq("mdp.39015077958422")
    end

    it "extracts the access" do
      expect(ir.access).to eq("allow")
    end

    it "retrives the rights code" do
      expect(ir.rights).to eq("pd")
    end

    it "extracts the description" do
      expect(ir.description).to eq("v.1")
    end

    it "extracts the source" do
      expect(ir.source).to eq("MIU")
    end

    # TODO: test what happens where there is more than one SDR for the collection
    # Can have multiple bib nums from the same source on the same Zeph record
    it "extracts the source_bib_num" do
      ir.sdr_nums = {"miu" => "990058493500106381"}
      expect(ir.source_bib_num).to eq("990058493500106381")
    end

    it "extracts the rights_reason_code" do
      expect(ir.rights_reason_code).to eq("bib")
    end

    it "extracts the rights_timestamp" do
      ir.htid = "test.pd_google"
      expect(ir.rights_timestamp).to eq(DateTime.parse("2009-01-01 05:00:00").to_time)
    end

    it "extracts the update date from 974d" do
      expect(ir.update_date).to eq("20210912")
    end

    it "extracts the rights_determination_note" do
      expect(ir.rights_determination_note).to eq("US fed doc")
    end

    it "extracts the rights_date_used" do
      expect(ir.rights_date_used).to eq("1976")
    end

    it "extracts the collection_code" do
      expect(ir.collection_code).to eq("MIU")
    end

    it "extracts the content_provider_code" do
      expect(ir.content_provider_code).to eq("umich")
    end

    it "extracts the responsible_entity_code" do
      expect(ir.responsible_entity_code).to eq("umich")
    end

    it "extracts the digitization_agent_code" do
      expect(ir.digitization_agent_code).to eq("google")
    end
  end

  it "retrieves the access_profile_code" do
    ir.htid = "test.pd_google"
    expect(ir.access_profile_code).to eq(2)
  end

  it "retrieves the access_profile" do
    ir.htid = "test.pd_google"
    expect(ir.access_profile).to eq("google")
  end

  describe "#rights_date_used" do
    it "fills non-existent rdus with '9999'" do
      m = MARC::Record.new_from_hash(
        JSON.parse(File.read(File.dirname(__FILE__) + "/data/no_rights_date_used_rec.json"))
      )
      item_marc = m.fields("974").first
      ir = described_class.new(item_marc)
      expect(ir.rights_date_used).to eq("9999")
    end
  end

  # 902   $attr =~ /^(pdus$|pd$|world|ic-world|cc|und-world)/ and return 'allow';

  describe "#access" do
    it "is allow when rights is pd" do
      ir.rights = "pd"
      expect(ir.access).to eq("allow")
    end

    it "is allow when rights is pdus" do
      ir.rights = "pdus"
      expect(ir.access).to eq("allow")
    end

    it "is allow when rights starts with 'world'" do
      ir.rights = "world"
      expect(ir.access).to eq("allow")
    end

    it "is allow when rights starts with 'ic-world'" do
      ir.rights = "ic-world"
      expect(ir.access).to eq("allow")
    end

    it "is allow when rights starts with 'cc'" do
      ir.rights = "cc4somestuff"
      expect(ir.access).to eq("allow")
    end

    it "is allow when rights starts with 'und-world'" do
      ir.rights = "und-world"
      expect(ir.access).to eq("allow")
    end

    it "deny when it is anything else" do
      ir.rights = "pd but no"
      expect(ir.access).to eq("deny")
    end
  end
end
