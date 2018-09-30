ENV['RACK_ENV'] = 'test'

require './application'
require 'rack/test'
require 'rspec'
require 'rspec_api_documentation/dsl'

Dir[File.join(File.dirname(__FILE__), '../spec/support/**/*.rb')].each { |f| require f }

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  RspecApiDocumentation.configure do |config|
    config.docs_dir = Pathname.new(Sinatra::Application.settings.public_folder).join('doc')
    config.format = :html
    config.app = Sinatra::Application
  end
end
