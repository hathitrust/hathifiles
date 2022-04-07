# frozen_string_literal: true

require "spec_helper"

require "collections_database/collections"

RSpec.describe CollectionsDatabase::CollectionsDB do
  let(:connection_string) { "mysql2://ht_collections:ht_collections@mariadb/ht_collections" }
  let(:user) { "ht_collections" }
  let(:password) { "ht_collections" }
  let(:database) { "ht_collections" }
  let(:host) { "mariadb" }
  let(:connection) do
    described_class.new(user: user,
      password: password,
      database: database,
      host: host)
  end

  let(:opts) do
    {user: user,
     password: password,
     host: host,
     database: database,
     adapter: "mysql2"}
  end

  describe "Connecting" do
    it "connects with url" do
      c = described_class.connection(url: connection_string)
      expect(c.tables).to include(:reasons)
    end

    it "connects with opts" do
      c = described_class.connection(opts: opts)
      expect(c.tables).to include(:reasons)
    end
  end
end
