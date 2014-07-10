namespace :oneclick do
  desc "Add Sample Data for configured brand."
  task :add_sample_data => :environment do
    case Oneclick::Application.config.brand
      when 'arc'
        puts 'Getting ARC Sample Data...'
        require File.join(Rails.root, 'db', 'arc/arc_sample_data.rb')
      when 'pa'
        puts 'Getting PA Sample Data...'
        require File.join(Rails.root, 'db', 'pa/pa_sample_data.rb')
      when 'broward'
        puts 'Getting Broward Sample Data...'
        require File.join(Rails.root, 'db', 'broward/broward_sample_data.rb')
      else
        puts 'UNKNOWN BRAND: ' + Oneclick::Application.config.brand.to_s
        return
    end

    puts 'Running sample data common to all providers...'
    require File.join(Rails.root, 'db', 'common_sample_data.rb')
    puts 'Finished running sample data common to all providers.'

  end

  desc "Update Attributes Per Installation."
  task :update_attributes => :environment do
    require File.join(Rails.root, 'db', Oneclick::Application.config.brand + '/update_attributes.rb')
  end
end
