case Oneclick::Application.config.brand
when 'pa'
  require File.join(Rails.root, 'db', 'pa_seeds.rb')
when 'arc'
  require File.join(Rails.root, 'db', 'atl_seeds.rb')
when 'broward'
  require File.join(Rails.root, 'db', 'broward_seeds.rb')
else
  raise "Brand #{Oneclick::Application.config.brand} not handled" 
end