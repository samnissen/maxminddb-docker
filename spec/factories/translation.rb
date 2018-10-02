FactoryBot.define do
  factory :translation do
    trait :en do
      locale_code 'en'
    end

    trait :de do
      locale_code 'de'
    end

    trait :ja do
      locale_code 'ja'
    end

    trait :usa do
      country_alpha2 'US'
      country_alpha3 'USA'
      country_name   'United States'
    end

    trait :mex do
      country_alpha2 'MX'
      country_alpha3 'MEX'
      country_name   'Mexiko'
    end
  end
end
