# frozen_string_literal: true

require "ettin"

environment = ENV["HATHIFILE_ENV"] || "test"
Settings = Ettin.for(Ettin.settings_files("config", environment))
Settings.environment = environment
