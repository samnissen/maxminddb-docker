require 'csv'

module ImportHelper
  FOLDER_PATH = Settings.maxmindb.csv.folder_path
  CITY_IPV4_FILENAME = Settings.maxmindb.csv.city_ipv4_filename
  CITY_LOCALE_FILENAME_TEMPLATE = Settings.maxmindb.csv.city_locale_filename_template
  LOCALES = Settings.maxmindb.csv.locales

  def import_cities_networks_and_locations
    counter   = 0
    file_path = FOLDER_PATH + CITY_IPV4_FILENAME

    import_csv_file(file_path) do |row|
      next if row['geoname_id'] == row['registered_country_geoname_id']
      city = City.find_or_create_by(city_id: row['geoname_id'])
      next if city.network.present?

      city.create_network!(ip: row['network'])

      city.create_location!(
        latitude:        row['latitude'],
        longitude:       row['longitude'],
        accuracy_radius: row['accuracy_radius']
      )

      counter += 1
      puts "Cities, networks and locations: #{counter}"
    end

    return false if Network.count.zero?
    puts 'Networks and locations was successfully converted.'

    true
  end

  def import_translations
    country_iso_codes = {}

    LOCALES.each do |locale|
      counter   = 0
      file_path = FOLDER_PATH + CITY_LOCALE_FILENAME_TEMPLATE.gsub('%{locale}', locale)

      import_csv_file(file_path) do |row|
        next if row['city_name'].blank?
        city = City.find_by(city_id: row['geoname_id'])
        next unless city

        city.translations.create!(
          locale_code:     row['locale_code'],
          country_alpha2:  row['country_iso_code'],
          country_alpha3:  country_alpha3(row['country_iso_code'], country_iso_codes),
          country_name:    row['country_name'],
          region_iso_code: row['subdivision_1_iso_code'],
          region_name:     row['subdivision_1_name'],
          name:            row['city_name']
        )

        counter += 1
        puts "Translations #{locale}: #{counter}"
      end
    end

    return false if City.count.zero?
    puts 'Cities was successfully converted.'

    true
  end

  private

  def import_csv_file(file_path)
    return unless file_path

    options = { headers: :first_row }

    CSV.open( file_path, "r", options ) do |csv|
      csv.each { |row| yield(row) if block_given? }
    end
  end

  def country_alpha3(alpha2, country_iso_codes)
    return if alpha2.blank?

    alpha3 = country_iso_codes[alpha2]
    return alpha3 unless alpha3.blank?

    country = ISO3166::Country.find_country_by_alpha2(alpha2)
    return unless country

    alpha3 = country.alpha3

    country_iso_codes[alpha2] = alpha3
  end
end
