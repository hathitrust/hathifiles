# frozen_string_literal: true

require "factory_bot"
require "pry"
require "services"
require "simplecov"
require "simplecov-lcov"

SimpleCov.skip "spec"

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
end
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])
SimpleCov.start

$LOAD_PATH.unshift "../lib"
require "hathifiles"

FIXTURES_DIR = Pathname.new(__dir__).realdirpath + "fixtures"
def fixture(filename)
  File.join(FIXTURES_DIR, filename)
end

TEST_RECID = "000"
TEST_RECID_1 = "001"
TEST_BOGUS_RECID = "BOGUS"
TEST_HTID = "test.000"
TEST_HTID_1 = "test.001"
TEST_YYYYMM = 202301
TEST_EARLIER_YYYYMM = 202201
TEST_LATER_YYYYMM = 202401
TEST_VALID_HATHIFILE_NAME = "hathi_full_20230101.txt.gz"
TEST_NDJ_FILE = "test_dump.ndj.gz"
TEST_OLDER_SAMPLE_HATHIFILE_NAME = "sample_full_20220101.txt.gz"
TEST_SAMPLE_HATHIFILE_NAME = "sample_full_20230101.txt.gz"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods

  # Adapted from holdings-backend. Redirect the log output to a file.
  # This should catch most of the noise.
  config.before(:suite) do
    FileUtils.rm("test.log") if File.exist?("test.log")
    Services.register(:logger) do
      Logger.new("test.log").tap { |l| l.level = Logger::DEBUG }
    end
  end
end
