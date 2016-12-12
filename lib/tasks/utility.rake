namespace :utility do

  desc 'List all missing translation keys'
  task :find_missing_translation_keys => :environment do
    seed_file = File.join(Rails.root, 'lib', 'tasks', 'find_missing_translation_keys.rb')
    load(seed_file) if File.exist?(seed_file)
  end

end

namespace :cleanup do

  desc 'Destroys Orphaned Records'
  task :destroy_orphaned_records => :environment do
    user_services = UserService.where(["service_id NOT IN (?)", Service.pluck("id")]).destroy_all
    puts "Destroyed #{user_services.count} orphaned user_services..."

    ecolane_profiles = EcolaneProfile.where(["service_id NOT IN (?)", Service.pluck("id")]).destroy_all
    puts "Destroyed #{ecolane_profiles.count} orphaned ecolane_profiles..."
  end

end
