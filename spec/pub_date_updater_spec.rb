require "spec_helper"
require "pub_date_updater"
require "bib_record"

RSpec.describe PubDateUpdater do
  # catalog record id: 011338539
  # date 2 from 008: 1976
  let(:bibrecord) { fixture_record('bib_rec') }

  before(:each) do
    Services.db[:hf_pub_date].delete
  end

  it "adds record to the pub date table" do
    described_class.new.update(bibrecord)

    expect(Services.db[:hf_pub_date].where(bib_num: "011338539").first[:pub_date]).to eq(1976)
  end

  it "updates pub date" do
    Services.db[:hf_pub_date].insert("011338539",1899)
    described_class.new.update(bibrecord)

    expect(Services.db[:hf_pub_date].where(bib_num: "011338539").first[:pub_date]).to eq(1976)
  end
end
