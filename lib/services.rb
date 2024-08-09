# frozen_string_literal: true

require "canister"
require "sequel"
require "database"
require "collections_database/collections"
require "sdr_num_prefixes"
require "logger"

Services = Canister.new

Services.register(:db) do
  Database.new
end

Services.register(:collections) do
  CollectionsDatabase::Collections.new
end

Services.register(:sdrnum_prefix_map) do
  SdrNumPrefixes.new
end

Services.register(:logger) do
  Logger.new($stdout, level: ENV.fetch("HATHIFILE_LOGGER_LEVEL", Logger::INFO).to_i)
end
