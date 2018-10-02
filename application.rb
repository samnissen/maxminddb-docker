require 'sinatra'
require 'bundler'
require 'bundler/setup'

# Require gems
Bundler.require :default, (ENV['RACK_ENV'] || :development).to_sym

Dir.glob('./{models,services}/**/*.rb').each do |file|
  autoload File.basename(file, '.rb').camelize.to_sym, file
end

# Initiate Settings
class Settings < Settingslogic
  source './config/settings.yml'
end

set :bind, '0.0.0.0'
set :public_folder, 'public'

before do
  content_type 'application/json'
end

get '/api' do
  param :ip,       String
  param :location, Hash
  param :country,  String, scope: :location
  param :city,     String, scope: :location
  param :region,   String, scope: :location

  location = ByIpGetter.perform(params[:ip]) ||
             ByLocationGetter.perform(params[:location]) ||
             {}

  status(404) if location.empty?

  location.to_json
end

get '/doc' do
  redirect '/doc/index.html'
end
