FactoryBot.define do
  factory :location do
    latitude Faker::Address.latitude
    longitude Faker::Address.longitude
  end
end
