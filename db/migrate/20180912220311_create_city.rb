class CreateCity < ActiveRecord::Migration[5.1]
  create_table 'cities', force: :cascade do |t|
    t.integer :city_id
  end
end
