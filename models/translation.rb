class Translation  < ActiveRecord::Base
  belongs_to :city

  scope :by_country_alpha2,  ->(alpha2)          { where(country_alpha2: alpha2.upcase) }
  scope :by_country_alpha3,  ->(alpha3)          { where(country_alpha3: alpha3.upcase) }
  scope :by_country_name,    ->(country_name)    { where('lower(country_name) = ?', country_name.downcase) }
  scope :by_region_iso_code, ->(region_iso_code) { where(region_iso_code: region_iso_code.upcase) }
  scope :by_region_name,     ->(region_name)     { where('lower(region_name) = ?', region_name.downcase) }
  scope :by_city_name,       ->(city_name)       { where('lower(name) = ?', city_name.downcase) }

  scope :by_country, ->(country_param) do
    by_country_alpha2(country_param)
      .or(by_country_alpha3(country_param))
      .or(by_country_name(country_param))
  end

  scope :by_region, ->(region_param) do
    by_region_iso_code(region_param)
      .or(by_region_name(region_param))
  end
end
