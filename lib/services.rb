# frozen_string_literal: true

require "dotenv"
Dotenv.load(".env")
require "canister"
require "sequel"
require "rights_database/rights_db"
require "rights_database/rights"
require "rights_database/rights_attributes"
require "rights_database/rights_reasons"
require "ht_collections"
require "sdr_num_prefixes"

Services = Canister.new

Services.register(:rights_db) { RightsDatabase::RightsDB.new }
Services.register(:rights) { RightsDatabase::Rights }
Services.register(:rights_attributes) { RightsDatabase::RightsAttributes.new }
Services.register(:rights_reasons) { RightsDatabase::RightsReasons.new }

Services.register(:ht_collections) { HTCollections.new }

Services.register(:sdrnum_prefix_map) { SdrNumPrefixes.new }
