# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "canister"
gem "dotenv"
gem "ettin"
gem "httpclient"
gem "sequel"
gem "mysql2"
gem "marc"
gem "traject"
gem "push_metrics", git: "https://github.com/hathitrust/push_metrics.git", tag: "v0.9.0"
gem "filter", git: "https://github.com/hathitrust/feddocs_filter.git", branch: "main"

group :development, :test do
  gem "pry"
  gem "standardrb"
  gem "rspec"
  gem "simplecov"
  gem "simplecov-lcov"
  gem "factory_bot"
  gem "faraday"
end
