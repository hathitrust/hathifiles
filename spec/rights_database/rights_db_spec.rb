# frozen_string_literal: true

require 'spec_helper'

require 'rights_database/rights'

RSpec.describe RightsDatabase::RightsDB do
  let(:connection_string) { 'mysql2://ht_rights:ht_rights@mariadb/ht_rights' }
  let(:user) { 'ht_rights' }
  let(:password) { 'ht_rights' }
  let(:database) { 'ht_rights' }
  let(:host) { 'mariadb' }
  let(:connection) do
    described_class.new(user: user,
                        password: password,
                        database: database,
                        host: host)
  end

  let(:opts) do
    { user: user,
      password: password,
      host: host,
      database: database,
      adapter: 'mysql2' }
  end

  describe 'Connecting' do
    it 'connects with url' do
      c = described_class.connection(url: connection_string)
      expect(c.tables).to include(:reasons)
    end

    it 'connects with opts' do
      c = described_class.connection(opts: opts)
      expect(c.tables).to include(:reasons)
    end
  end
end
