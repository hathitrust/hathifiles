# frozen_string_literal: true

require "canister"
require "sequel"
require "rights_database/rights_db"
require "rights_database/rights"
require "rights_database/rights_attributes"
require "rights_database/rights_reasons"
require "rights_database/access_profiles"
require "collections_database/collections_db"
require "collections_database/collections"
require "sdr_num_prefixes"
require "logger"

Services = Canister.new

Services.register(:rights_db) { RightsDatabase::RightsDB.new }
Services.register(:rights) { RightsDatabase::Rights }
Services.register(:rights_attributes) { RightsDatabase::RightsAttributes.new }
Services.register(:rights_reasons) { RightsDatabase::RightsReasons.new }
Services.register(:access_profiles) { RightsDatabase::AccessProfiles.new }
Services.register(:collections_db) { CollectionsDatabase::CollectionsDB.new }
Services.register(:collections) { CollectionsDatabase::Collections.new }

Services.register(:sdrnum_prefix_map) { SdrNumPrefixes.new }

Services.register(:logger) do
  Logger.new($stdout, level: ENV.fetch("HATHIFILE_LOGGER_LEVEL", Logger::INFO).to_i)
end
