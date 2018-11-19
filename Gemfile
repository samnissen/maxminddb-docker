source 'https://rubygems.org'

ruby '2.5.0'

gem 'sinatra', require: false
gem "sinatra-param", require: "sinatra/param"
gem 'sinatra-activerecord'
gem 'sqlite3', '~> 1.3', '>= 1.3.13'
gem 'countries'
gem 'settingslogic', '~> 2.0', '>= 2.0.9'
gem 'maxminddb', '~> 0.1.11'
gem 'rake'
gem 'rack', '>= 2.0.6'

group :test, :development do
  gem 'pry'
end

group :test do
  gem 'rack-test', '~> 0.6.3'
  gem 'rspec'
  gem 'factory_bot'
  gem 'faker', '~> 1.6', '>= 1.6.6'
  gem 'database_cleaner', '~> 1.7'
  gem 'rspec_api_documentation', '~> 4.7'
end
