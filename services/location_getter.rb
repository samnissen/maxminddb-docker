class LocationGetter
  LOCALITY_TYPES = {
    country: 'country'.freeze,
    region:  'region'.freeze,
    city:    'city'.freeze
  }

  def self.call(*args)
    new(*args).perform
  end

  attr_reader :ip_param, :country_param, :region_param, :city_param, :location

  def initialize(params:)
    @ip_param      = params.fetch(:ip, '').strip
    @country_param = params.dig(:location, :country)&.strip || ''
    @region_param  = params.dig(:location, :region)&.strip  || ''
    @city_param    = params.dig(:location, :city)&.strip    || ''
  end

  def perform
    find_network || find_city || find_region || find_country

    location.blank? ? {} : location
  end

  private

  def find_network
    return false if ip_param.blank?
    @location = MaxMindDB.new('db/maxminddb/GeoLite2-City.mmdb').lookup(ip_param).to_hash
  end

  def find_city
    return false if city_param.blank? || cities.empty? || !is_unique_city?
    @location = city_location(cities.first.city, LOCALITY_TYPES[:city])
  end

  def find_region
    return false if region_param.blank? || regions.empty? || !is_unique_region?
    @location = city_location(regions.first.city, LOCALITY_TYPES[:region])
  end

  def find_country
    return false if country_param.blank? || countries.empty?
    @location = city_location(countries.first.city, LOCALITY_TYPES[:country])
  end

  def countries
    @countries ||= Translation.by_country(country_param)
  end

  def regions
    @regions ||=
      countries.any? ? countries.by_region(region_param) : Translation.by_region(region_param)
  end

  def cities
    @cities ||=
      if regions.any?
        regions.by_city_name(city_param)
      else
        countries.by_city_name(city_param).presence || Translation.by_city_name(city_param)
      end
  end

  def is_unique_city?
    cities.pluck(:country_alpha2, :region_iso_code).uniq.count.eql?(1)
  end

  def is_unique_region?
    regions.pluck(:country_alpha2).uniq.count.eql?(1)
  end

  def city_location(city, locality_type)
    return if city.blank?

    {
      ip: city.network.ip,
      location: {
        latitude: city.location.latitude,
        longitude: city.location.longitude,
        locality_type: locality_type
      }
    }
  end
end
