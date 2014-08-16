require File.join(Rails.root, 'db', 'common_seeds.rb')

require File.join(Rails.root, 'db', Oneclick::Application.config.brand.to_s + '/' + Oneclick::Application.config.brand.to_s + '_seeds.rb')

KioskLocation.create!([
  {"name"=>"machine1", "addr"=>"1230 Roosevelt Ave, York, PA 17404", "lat"=>39.975886, "lon"=>-76.756512, "address_type"=>6},
  {"name"=>"pd-841-vr-17404", "addr"=>"PA Career Link York 841 Vogelsong Road, York, PA 17404", "lat"=>39.983315, "lon"=>-76.753734, "address_type"=>6},
  {"name"=>"pd-2251-eb-17402", "addr"=>" York VA CBOC  2251 Eastern Blvd., York, PA 17402", "lat"=>39.972647, "lon"=>-76.682786, "address_type"=>6},
  {"name"=>"pd-100-wms-17401", "addr"=>" York County Veterans Affairs  100 W. Market Street, York, PA 17401", "lat"=>39.961397, "lon"=>-76.729968, "address_type"=>6},
  {"name"=>"pd-90-nns-17401", "addr"=>"YMCA York 90 N. Newberry Street, York, PA 17401", "lat"=>39.961025, "lon"=>-76.735569, "address_type"=>6},
  {"name"=>"pd-1001-sgs-17403", "addr"=>"WellSpan York Hospital  1001 S. George Street, York, PA, 17403", "lat"=>39.946036, "lon"=>-76.718838, "address_type"=>6},
  {"name"=>"pd-1700-sla-17042", "addr"=>"Lebanon VA Medical Center 1700 South Lincoln Avenue, Lebanon, PA, 17042", "lat"=>40.311569, "lon"=>-76.406464, "address_type"=>6},
  {"name"=>"penndot-kiosk-lab-1", "addr"=>"Lebanon VA Medical Center 1700 South Lincoln Avenue, Lebanon, PA, 17042", "lat"=>40.311569, "lon"=>-76.406464, "address_type"=>6}
])
