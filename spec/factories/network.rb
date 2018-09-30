FactoryBot.define do
  factory :network do
    ip Faker::Internet.ip_v4_address
  end
end
