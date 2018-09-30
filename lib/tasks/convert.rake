require './helpers/import_helper'
include ImportHelper

namespace :db do
  desc 'Convert MaxMind db into SQLite db'
  task convert: [:drop, :create, :migrate] do
    success_msg = "MaxMind db was successfully converted #{Time.now}"
    fail_msg    = 'MaxMind db was not successfully converted, something wrong.'

    puts import_cities_networks_and_locations && import_translations ? success_msg : fail_msg
  end
end
