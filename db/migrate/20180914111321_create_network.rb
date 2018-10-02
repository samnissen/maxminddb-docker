class CreateNetwork< ActiveRecord::Migration[5.1]
  create_table 'networks', force: :cascade do |t|
    t.references :city
    t.string :ip
  end
end
