require File.join(Rails.root, 'db', 'common_seeds.rb')

case Oneclick::Application.config.brand
when 'pa'
  require File.join(Rails.root, 'db', 'pa/pa_seeds.rb')
when 'arc'
  require File.join(Rails.root, 'db', 'arc/arc_seeds.rb')
when 'broward'
  require File.join(Rails.root, 'db', 'broward/broward_seeds.rb')
else
  raise "Brand #{Oneclick::Application.config.brand} not handled" 
end