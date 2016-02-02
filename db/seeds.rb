require File.join(Rails.root, 'db', 'common_seeds.rb')

require File.join(Rails.root, 'db', Oneclick::Application.config.brand.to_s + '/' + Oneclick::Application.config.brand.to_s + '_seeds.rb')

