# use as Rails.application.config.brand
Oneclick::Application.config.brand = ENV['BRAND'] || 'arc'

case ENV['BRAND'] || 'arc'
when 'arc'
  Oneclick::Application.config.geocoder_components = 'administrative_area:GA|country:US'
  Oneclick::Application.config.geocoder_bounds = [[33.737147,-84.406634], [33.764125,-84.370361]]
when 'broward'  
  Oneclick::Application.config.geocoder_components = 'administrative_area:FL|country:US'
  Oneclick::Application.config.geocoder_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
when 'yata'  
  Oneclick::Application.config.geocoder_components = 'administrative_area:PA|country:US'
  Oneclick::Application.config.geocoder_bounds = [[41.970622, -80.461542], [39.734653, -75.007294]]
end
