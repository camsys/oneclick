require 'spec_helper'


AUTOCOMPLETE_DETAILS = {
  "address_components"=>[
    {
      "long_name"=>"730",
      "short_name"=>"730", 
      "types"=>["street_number"]
      }, 
      {
        "long_name"=>"Peachtree St NE", 
        "short_name"=>"Peachtree St NE", 
        "types"=>["route"]
        }, 
        {
          "long_name"=>"Midtown", 
          "short_name"=>"Midtown", 
          "types"=>["neighborhood", "political"]
          }, 
          {
            "long_name"=>"Atlanta", 
            "short_name"=>"Atlanta", 
            "types"=>["locality", "political"]
            }, 
            {
              "long_name"=>"Fulton County", 
              "short_name"=>"Fulton County", 
              "types"=>["administrative_area_level_2", "political"]
              },
              {
                "long_name"=>"Georgia", 
                "short_name"=>"GA", 
                "types"=>["administrative_area_level_1", "political"]
                }, 
                {
                  "long_name"=>"United States", 
                  "short_name"=>"US", 
                  "types"=>["country", "political"]
                  }, 
                  {
                    "long_name"=>"30308", 
                    "short_name"=>"30308", 
                    "types"=>["postal_code"]
                  }
                  ],
                  "adr_address"=>"<span class=\"street-address\">730 Peachtree St NE</span>, <span class=\"locality\">Atlanta</span>, <span class=\"region\">GA</span> <span class=\"postal-code\">30308</span>, <span class=\"country-name\">USA</span>",
                  "formatted_address"=>"730 Peachtree St NE, Atlanta, GA 30308, USA", 
                  "geometry"=>
                  {
                    "location"=>
                    {
                      "lat"=>33.774486,
                      "lng"=>-84.385448
                    }
                    },
                    "icon"=>"http://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png", "id"=>"442be253c5082958a292e62913d671415b66fdce", "name"=>"730 Peachtree St NE", "reference"=>"CpQBjwAAAIk7UeN_S_0jW4WueH-9ZTben-HNgetXwHoqbdhJroKdcJi72ZZRvOFK1TszigRWacI9jzi0bHI-XblGhrAeNqAVBmI1_agot2VeIHZ7e190SBsaixVkDlOHHE0lQcx8RW6IMYH8JgAa1qnGpoKwtNdw8w3W0y5d5av3CJxwJZpR-Q4kQDX7k339S8B0SDo98xIQXzlhyXKQ8IQlennOJ4W0MRoU6Rx4C8338Z_MQdfuyyPx1ZqcTS8", "types"=>["street_address"], "url"=>"https://maps.google.com/maps/place?q=730+Peachtree+St+NE,+Atlanta,+GA+30308,+USA&ftid=0x88f5046f5730dc11:0xbd892475c3dc5d8d", 
                    "vicinity"=>"Atlanta"
                  }

#
describe TripsSupport do
  subject(:ts) { Object.new.extend(TripsSupport) }

  it { should respond_to(:cleanup_google_details) }

  it 'does cleanup_google_details' do
    r = ts.cleanup_google_details(AUTOCOMPLETE_DETAILS)
    r.should_not be_nil
    r['address1'].should eq '730 Peachtree St NE'
    r['city'].should eq 'Atlanta'
    r['county'].should eq 'Fulton'
    r['state'].should eq 'GA'
    r['zip'].should eq '30308'
    r['lat'].should eq 33.774486
    r['lon'].should eq -84.385448
  end

end
