class CreateTranslation < ActiveRecord::Migration[5.1]
  create_table 'translations', force: :cascade do |t|
    t.references :city
    t.string :locale_code
    t.string :country_alpha2, length: 2
    t.string :country_alpha3, length: 3
    t.string :country_name
    t.string :region_iso_code
    t.string :region_name
    t.string :name

    t.index [:country_alpha2, :country_alpha3, :country_name, :region_iso_code, :region_name, :name], name: 'index_city_name'
  end
end
