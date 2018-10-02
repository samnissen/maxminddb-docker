class CreateLocation < ActiveRecord::Migration[5.1]
  create_table 'locations', force: :cascade do |t|
    t.string     :latitude
    t.string     :longitude
    t.integer    :accuracy_radius
    t.references :city
  end
end
