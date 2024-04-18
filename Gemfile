# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "canister"
gem "date_named_file"
gem "dotenv"
gem "ettin"
gem "httpclient"
gem "marc"
gem "milemarker"
gem "mysql2"
gem "sequel"
gem "traject"
gem "zinzout"

gem "push_metrics", git: "https://github.com/hathitrust/push_metrics.git", tag: "v0.9.1"
gem "filter", git: "https://github.com/hathitrust/feddocs_filter.git", branch: "main"
gem "hathifiles_database", git: "https://github.com/hathitrust/hathifiles_database.git", branch: "DEV-1087_argo_monthly"

group :development, :test do
  gem "factory_bot"
  gem "faraday"
  gem "pry"
  gem "rspec"
  gem "simplecov"
  gem "simplecov-lcov"
  gem "standardrb"
end
