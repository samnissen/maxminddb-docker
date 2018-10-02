require_relative 'application'
require 'sinatra/activerecord/rake'

Dir.glob('lib/tasks/*.rake').each { |r| load r }

unless Sinatra::Application.settings.environment == :production
  require 'rspec_api_documentation'
  load 'tasks/docs.rake'
end
