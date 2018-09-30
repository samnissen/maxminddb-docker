require 'spec_helper'

RSpec.describe LocationGetter do

  subject { described_class.(params: params) }

  describe '#perorm' do
    let(:locality_country) { described_class::LOCALITY_TYPES[:country] }
    let(:locality_region) { described_class::LOCALITY_TYPES[:region] }
    let(:locality_city) { described_class::LOCALITY_TYPES[:city] }

    let(:not_existing_country_name) { 'Narnia' }
    let(:not_existing_region_name) { 'Shire' }
    let(:not_existing_city_name) { 'Consonno' }

    let(:location) { {country: country, region: region, city: city} }
    let(:params) { {location: location} }

    let(:expected_result) do
      {
        ip: ip,
        location: { latitude: latitude, longitude: longitude, locality_type: locality_type }
      }
    end

    let!(:usa_ohio_london) { create :city }
    let(:translation) { { region_iso_code: 'OH', region_name: 'Ohio', name: 'London' } }
    let!(:usa_ohio_london_en) { create :translation, :en, :usa, city: usa_ohio_london, **translation }
    let!(:usa_ohio_london_de) { create :translation, :de, :usa, city: usa_ohio_london, **translation }

    let(:expected_locality) { usa_ohio_london }

    shared_examples 'with expected result' do
      it 'returns valid result' do
        expect(subject).to eq(expected_result)
      end
    end

    shared_examples 'returns country' do |country, region, city|
      let(:location) { {country: country, region: region, city: city} }
      let(:ip) { expected_locality.network.ip }
      let(:latitude) { expected_locality.location.latitude }
      let(:longitude) { expected_locality.location.longitude }
      let(:locality_type) { locality_country }

      it_behaves_like 'with expected result'
    end

    shared_examples 'returns region' do |country, region, city|
      let(:location) { {country: country, region: region, city: city} }
      let(:ip) { expected_locality.network.ip }
      let(:latitude) { expected_locality.location.latitude }
      let(:longitude) { expected_locality.location.longitude }
      let(:locality_type) { locality_region }

      it_behaves_like 'with expected result'
    end

    shared_examples 'returns city' do |country, region, city|
      let(:location) { {country: country, region: region, city: city} }
      let(:ip) { expected_locality.network.ip }
      let(:latitude) { expected_locality.location.latitude }
      let(:longitude) { expected_locality.location.longitude }
      let(:locality_type) { locality_city }

      it_behaves_like 'with expected result'
    end

    shared_examples 'returns empty hash' do |country, region, city|
      let(:location) { {country: country, region: region, city: city} }

      it 'returns empty hash' do
        expect(subject).to eq({})
      end
    end

    not_existing_country_name = 'Narnia'
    not_existing_region_name  = 'Shire'
    not_existing_city_name    = 'Consonno'

    blank_params   = [nil, '']
    country_params = [not_existing_country_name, 'United States'] + blank_params
    region_params  = [not_existing_region_name, 'Ohio'] + blank_params
    city_params    = [not_existing_city_name, 'London'] + blank_params

    params_collection = country_params.product(region_params).product(city_params).map(&:flatten)

    shared_examples 'with unique cuontry, region and city' do
      params_collection.each do |params|
        country, region, city = params

        scenario =
          if city.present? && !city.eql?(not_existing_city_name)
            'returns city'
          elsif region.present? && !region.eql?(not_existing_region_name)
            'returns region'
          elsif country.present? && !country.eql?(not_existing_country_name)
            'returns country'
          else
            'returns empty hash'
          end

        it_behaves_like scenario, *params
      end
    end

    shared_examples 'with no unique city' do
      let!(:usa_alabama_london) { create :city }
      let(:usa_alabama_london_translation) { { region_iso_code: 'AL', region_name: 'Alabama', name: 'London' } }
      let!(:usa_alabama_london_en) { create :translation, :en, :usa, city: usa_alabama_london, **usa_alabama_london_translation }
      let!(:usa_alabama_london_de) { create :translation, :de, :usa, city: usa_alabama_london, **usa_alabama_london_translation }

      params_collection.each do |params|
        country, region, city = params

        city_present = city.present? && !city.eql?(not_existing_city_name)
        region_present = region.present? && !region.eql?(not_existing_region_name)
        country_present = country.present? && !country.eql?(not_existing_country_name)

        scenario =
          if city_present && region_present
            'returns city'
          elsif region_present
            'returns region'
          elsif country_present
            'returns country'
          else
            'returns empty hash'
          end

        it_behaves_like scenario, *params
      end
    end

    shared_examples 'with no unique region' do
      let!(:mex_ohio_tapachula) { create :city }
      let(:mex_ohio_tapachula_translation) { { region_iso_code: 'MOH', region_name: 'Ohio', name: 'Tapachula' } }
      let!(:mex_ohio_tapachula_en) { create :translation, :en, :mex, city: mex_ohio_tapachula, **mex_ohio_tapachula_translation }
      let!(:mex_ohio_tapachula_de) { create :translation, :de, :mex, city: mex_ohio_tapachula, **mex_ohio_tapachula_translation }

      params_collection.each do |params|
        country, region, city = params

        scenario =
          if city.present? && !city.eql?(not_existing_city_name)
            'returns city'
          elsif region.present? && !region.eql?(not_existing_region_name) &&
                country.present? && !country.eql?(not_existing_country_name)
            'returns region'
          elsif country.present? && !country.eql?(not_existing_country_name)
            'returns country'
          else
            'returns empty hash'
          end

        it_behaves_like scenario, *params
      end
    end

    shared_examples 'with no unique region and city' do
      let!(:mex_ohio_london) { create :city }
      let(:mex_ohio_london_translation) { { region_iso_code: 'MOH', region_name: 'Ohio', name: 'London' } }
      let!(:mex_ohio_london_en) { create :translation, :en, :mex, city: mex_ohio_london, **mex_ohio_london_translation }
      let!(:mex_ohio_london_de) { create :translation, :de, :mex, city: mex_ohio_london, **mex_ohio_london_translation }

      params_collection.each do |params|
        country, region, city = params

        scenario =
          if city.present? && !city.eql?(not_existing_city_name) &&
             country.present? && !country.eql?(not_existing_country_name)
            'returns city'
          elsif region.present? && !region.eql?(not_existing_region_name) &&
                country.present? && !country.eql?(not_existing_country_name)
            'returns region'
          elsif country.present? && !country.eql?(not_existing_country_name)
            'returns country'
          else
            'returns empty hash'
          end

        it_behaves_like scenario, *params
      end
    end

    it_behaves_like 'with unique cuontry, region and city'
    it_behaves_like 'with no unique city'
    it_behaves_like 'with no unique region'
    it_behaves_like 'with no unique region and city'


    context 'when searching by columns' do
      let(:usa_ohio_london_translation) { { country_name: 'ソマリア', region_iso_code: 'OH', region_name: 'イングランド', name: 'ロンドン' } }
      let!(:usa_ohio_london_ja) { create :translation, :ja, :usa, city: usa_ohio_london, **usa_ohio_london_translation }

      let(:country_alpha2) { usa_ohio_london_ja.country_alpha2 }
      let(:country_alpha3) { usa_ohio_london_ja.country_alpha3 }
      let(:region_iso_code) { usa_ohio_london_ja.region_iso_code }

      let(:region_locales) { {en: usa_ohio_london_en.region_name, ja: usa_ohio_london_ja.region_name} }
      let(:city_locales) { {en: usa_ohio_london_en.name,  ja: usa_ohio_london_ja.name} }

      let(:ip) { usa_ohio_london.network.ip }
      let(:latitude) { usa_ohio_london.location.latitude }
      let(:longitude) { usa_ohio_london.location.longitude }
      let(:locality_type) { locality_city }

      shared_examples 'with region param' do |locales|
        locales.each do |locale|
          context "when searching by city name, locale: #{locale}" do
            let(:city) { city_locales[locale] }
            it_behaves_like 'with expected result'
          end
        end
      end

      shared_examples 'with country param' do |locales|
        context 'when searching by region iso code' do
          let(:region) { region_iso_code }
          it_behaves_like 'with region param', locales
        end

        locales.each do |locale|
          context "when searching by region name, locale: #{locale}" do
            let(:region) { region_locales[locale] }
            it_behaves_like 'with region param', [locale]
          end
        end
      end

      context 'when searching by country alpha2' do
        it_behaves_like 'with country param', [:en, :ja] do
          let(:country) { country_alpha2 }
        end
      end

      context 'when searching by country alpha3' do
        it_behaves_like 'with country param', [:en, :ja]  do
          let(:country) { country_alpha3 }
        end
      end

      context 'when searching by country name, locale: en' do
        it_behaves_like 'with country param', [:en] do
          let(:country) { usa_ohio_london_en.country_name }
        end
      end

      context 'when searching by country name, locale: ja' do
        it_behaves_like 'with country param', [:ja] do
          let(:country) { usa_ohio_london_ja.country_name }
        end
      end
    end

    context 'when invalid input' do
      let(:ip)            { usa_ohio_london.network.ip }
      let(:latitude)      { usa_ohio_london.location.latitude }
      let(:longitude)     { usa_ohio_london.location.longitude }
      let(:locality_type) { locality_city }

      let(:country)       { 'uniTEd sTateS' }
      let(:region)        { 'OHIO' }
      let(:city)          { 'loNdON' }

      it_behaves_like 'with expected result'
    end
  end
end

