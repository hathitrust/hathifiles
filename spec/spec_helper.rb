# frozen_string_literal: true

require "pry"
require "simplecov"
require "fixtures/rights"
require "fixtures/collections"
require "factory_bot"
require "services"
SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
    mock_rights
  end

  config.before(:all) do
    # Ensure we don't try to use DB for tests by default and that we have
    # mock HT member data to use in tests
    Services.register(:ht_collections) { mock_collections }
  end
end
