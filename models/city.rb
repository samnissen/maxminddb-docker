class City < ActiveRecord::Base
  has_one :location
  has_one :network
  has_many :translations
end
