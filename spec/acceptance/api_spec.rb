require 'spec_helper'

resource "Get Location by IP address" do
  let(:ip) { '1.2.3.4' }
  let(:expected_reault) { {"accuracy_radius"=>1000, "latitude"=>37.751, "longitude"=>-97.822} }

  before do
    allow(MaxMindDB).to receive_message_chain(:new, :lookup).and_return(location: expected_reault)
  end

  get '/api' do
    parameter :ip, 'IP address', type: 'String'

    example 'returns location' do
      do_request(ip: ip)

      expect(status).to eq 200
      expect(parsed_body.fetch('location')).to eq expected_reault
    end
  end
end

resource "Get Location by Country, Region, City" do
  let(:location) { {country: 'MX', region: 'Chiapas', city: 'Tapachula'} }
  let(:ip) { '177.224.158.0/23' }
  let(:latitude) { "14.8743" }
  let(:longitude) { "-92.2825" }

  let(:expected_reault) do
    {
      "ip"=>ip,
      "location"=> {
        "latitude"=>latitude,
        "longitude"=>longitude,
        "locality_type"=>"city"
      }
    }
  end

  get '/api' do
    parameter :location, 'Location', type: Hash
    parameter :country,  'Country name, iso code, alternative iso code', type: 'String', scope: :location
    parameter :region,   'Region name, iso code', type: 'String', scope: :location
    parameter :city,     'City name', type: 'String', scope: :location

    before do
      city = create(:city,
        network: create(:network, ip: ip),
        location: create(:location, latitude: latitude, longitude: longitude))
      translation = { region_iso_code: 'CHP', region_name: 'Chiapas', name: 'Tapachula' }
      create :translation, :en, :mex, city: city, **translation
    end

    example 'returns location' do
      do_request(location: location)

      expect(status).to eq 200
      expect(parsed_body).to eq expected_reault
    end
  end
end
