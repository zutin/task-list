source "https://rubygems.org"

ruby "3.4.5"

gem "bootsnap", require: false
gem "kamal", require: false
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rack-cors"
gem "rails", "~> 8.0.4"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "brakeman", require: false
  gem "rspec-rails", "~> 8.0.0"
  gem "rubocop-rails-omakase", require: false
  gem "simplecov", require: false
  gem "timecop", "~> 0.9.10"
end

gem "graphql", "~> 2.5"
