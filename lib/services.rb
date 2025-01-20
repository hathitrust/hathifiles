# frozen_string_literal: true

require "canister"
require "sequel"
require "collections_database/collections"
require "sdr_num_prefixes"
require "logger"

Services = Canister.new

Services.register(:db) do
  # Read-only connection to database for verifying rights DB vs .rights files
  # as well as hathifiles tables.
  Sequel.connect(
    adapter: "mysql2",
    user: ENV["MARIADB_HT_RO_USERNAME"],
    password: ENV["MARIADB_HT_RO_PASSWORD"],
    host: ENV["MARIADB_HT_RO_HOST"],
    database: ENV["MARIADB_HT_RO_DATABASE"],
    encoding: "utf8mb4"
  )
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
