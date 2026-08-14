# frozen_string_literal: true

require "hathifiles_database"
require "spec_helper"
require "title_summary_table"

RSpec.describe TitleSummaryTable do
  let(:hfdb) { HathifilesDatabase.new.rawdb }
  let(:table) { described_class.new(logger: Services.logger) }
  let(:table_name) { described_class::TABLE_NAME }
  let(:temp_table_name) { described_class::TEMP_TABLE_NAME }
  let(:old_table_name) { described_class::OLD_TABLE_NAME }

  # Create from scratch and populate with some junk
  def populate_table(name)
    name = name.to_sym
    hfdb.drop_table?(name)
    hfdb.create_table(name) do
      primary_key :id
      String :junk
      String :more_junk
    end
    hfdb[name].insert(junk: "junk 1", more_junk: "more junk 1")
    hfdb[name].insert(junk: "junk 2", more_junk: "more junk 2")
  end

  before(:each) do
    HathifilesDatabase.new.rawdb.tap do |db|
      if db.table_exists?(described_class::TABLE_NAME.to_sym)
        db[described_class::TABLE_NAME.to_sym].truncate
      end
    end
  end

  describe "#create" do
    context "non-temporary" do
      context "with no existing table" do
        it "creates it" do
          hfdb.drop_table?(table_name)
          table.create
          expect(hfdb.table_exists?(table_name)).to eq(true)
          expect(hfdb[table_name].count).to eq 0
        end
      end

      context "with existing table" do
        it "leaves it unchanged" do
          populate_table(table_name)
          table.create
          expect(hfdb.table_exists?(table_name)).to eq(true)
          expect(hfdb[table_name].count).to be > 0
        end
      end
    end

    context "temporary option" do
      context "with no existing table" do
        it "creates it" do
          hfdb.drop_table?(temp_table_name)
          table.create(temp: true)
          expect(hfdb.table_exists?(temp_table_name)).to eq(true)
          expect(hfdb[temp_table_name].count).to eq 0
        end
      end

      context "with existing table" do
        it "leaves it unchanged" do
          populate_table(temp_table_name)
          table.create(temp: true)
          expect(hfdb.table_exists?(temp_table_name)).to eq(true)
          expect(hfdb[temp_table_name].count).to be > 0
        end
      end
    end
  end

  describe "#dataset" do
    it "returns a dataset for the correct table" do
      hfdb.drop_table?(table_name)
      populate_table(temp_table_name)
      # Could be a Mysql2 or Trilogy dataset
      expect(table.dataset(temp: true).class.to_s).to match(/Dataset/)
      expect(table.dataset(temp: true).count).to be > 0
    end

    it "returns a dataset that can be used to insert rows" do
      populate_table(table_name)
      table.dataset.insert(junk: "junk 3", more_junk: "more junk 3")
      expect(hfdb[table_name].count).to eq 3
    end

    it "does not raise if table does not exist" do
      # But it will raise if you try to do anything with the dataset
      hfdb.drop_table?(table_name)
      expect { table.dataset }.not_to raise_error
    end
  end

  describe "#swap" do
    it "creates the current and temp databases if necessary" do
      hfdb.drop_table?(table_name)
      hfdb.drop_table?(temp_table_name)
      table.swap
    end

    it "renames the current database" do
      hfdb.drop_table?(old_table_name)
      populate_table(table_name)
      table.swap
      expect(hfdb.table_exists?(old_table_name)).to eq(true)
      expect(hfdb[old_table_name].count).to be > 0
    end

    it "renames the temp database" do
      populate_table(temp_table_name)
      hfdb.drop_table?(table_name)
      table.swap
      expect(hfdb.table_exists?(table_name)).to eq(true)
      expect(hfdb[table_name].count).to be > 0
    end
  end
end
