# frozen_string_literal: true

require "dotenv"
Dotenv.load(".env")

require "delegate"
require "mysql2"
require "sequel"

# Backend for connection to MySQL database for production information about
# rights
class Database < SimpleDelegator
  attr_reader :rawdb
  attr_accessor :connection_string

  def initialize(connection_string = ENV["DB_CONNECTION_STRING"], **)
    @rawdb = self.class.connection(connection_string, **)
    super(@rawdb)
  end

  # #connection will take
  #  * a full connection string (passed here OR in the environment
  #    variable MYSQL_CONNECTION_STRING)
  #  * a set of named arguments, drawn from those passed in and the
  #    environment. Arguments are those supported by Sequel.
  #
  # Environment variables are mapped as follows:
  #
  #   user: DB_USER
  #   password: DB_PASSWORD
  #   host: DB_HOST
  #   port: DB_PORT
  #   database: DB_DATABASE
  #   adapter: DB_ADAPTER
  def self.connection(connection_string = ENV["DB_CONNECTION_STRING"],
    **kwargs)

    if connection_string.nil?
      db_args = gather_db_args(kwargs).merge(
        config_local_infile: true
      )
      Sequel.connect(**db_args, logger: Logger.new($stdout, level: Logger::WARN))
    else
      Sequel.connect(connection_string, logger: Logger.new($stdout, level: Logger::WARN))
    end
  end

  class << self
    private

    def gather_db_args(args)
      %i[user password host
        port database adapter].each do |db_arg|
        args[db_arg] ||= ENV["DB_#{db_arg.to_s.upcase}"]
      end

      args[:host] ||= "localhost"
      args[:adapter] ||= :mysql2
      args[:database] ||= "ht_rights"
      args
    end
  end
end
