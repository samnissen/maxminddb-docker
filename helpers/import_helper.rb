require 'csv'

module ImportHelper
  FOLDER_PATH = Settings.maxmind.csv.folder_path
  CITY_IPV4_FILENAME = Settings.maxmind.csv.city_ipv4_filename
  CITY_LOCALE_FILENAME_TEMPLATE = Settings.maxmind.csv.city_locale_filename_template
  LOCALES = Settings.maxmind.csv.locales

  def calc_file_lines(path)
    `wc -l #{path} | awk '{print $1}'`.to_i
  end

  def import_cities_networks_and_locations
    puts "Start import_cities_networks_and_locations\n\n"

    file_path       = FOLDER_PATH + CITY_IPV4_FILENAME
    total_rows      = calc_file_lines(file_path)
    processed_rows  = 0
    networks_before = Network.count

    import_csv_file(file_path) do |row|
      if row['geoname_id'] == row['registered_country_geoname_id']
        processed_rows += 1
        print_progress(processed_rows, total_rows)
        next
      end

      city = City.find_or_create_by(city_id: row['geoname_id'])
      city.create_network!(ip: row['network']) unless city.network.present?

      unless city.location.present?
        city.create_location!(
            latitude:        row['latitude'],
            longitude:       row['longitude'],
            accuracy_radius: row['accuracy_radius']
        )
      end

      processed_rows += 1
      print_progress(processed_rows, total_rows)
    end
  ensure
    puts "#{Network.count - networks_before} networks were imported!\n\n\n\n"
  end

  def import_translations
    puts "Start import_translations\n\n"

    country_iso_codes   = {}
    files               = LOCALES.map { |l| FOLDER_PATH + CITY_LOCALE_FILENAME_TEMPLATE.gsub('%{locale}', l) }
    transactions_before = Translation.count
    total_rows          = files.sum { |f| calc_file_lines(f) }
    processed_rows      = 0

    files.each do |file|
      import_csv_file(file) do |row|
        if row['city_name'].blank?
          processed_rows += 1
          print_progress(processed_rows, total_rows)
          next
        end

        city = City.find_by(city_id: row['geoname_id'])
        unless city
          processed_rows += 1
          print_progress(processed_rows, total_rows)
          next
        end

        city.translations.create!(
          locale_code:     row['locale_code'],
          country_alpha2:  row['country_iso_code'],
          country_alpha3:  country_alpha3(row['country_iso_code'], country_iso_codes),
          country_name:    row['country_name'],
          region_iso_code: row['subdivision_1_iso_code'],
          region_name:     row['subdivision_1_name'],
          name:            row['city_name']
        )

        processed_rows += 1
        print_progress(processed_rows, total_rows)
      end
    end
  ensure
    puts "#{Translation.count - transactions_before} translations were imported!"
  end

  private

  def print_progress(processed, total)
    percent = ((processed / total.to_f) * 100).round(2)
    puts "Rows #{processed}/#{total - processed}/#{total} - #{percent}%"
  end

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
