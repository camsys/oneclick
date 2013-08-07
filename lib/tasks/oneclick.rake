#encoding: utf-8
namespace :oneclick do
  task :seed_data => :environment do
    throw Exception.new("*** Deprecated, just use db:seed task ***")
  end

  task version: :environment do
    version = `git describe`.chomp
    File.open('config/initializers/version.rb', 'w') do |f|
      f.puts "Oneclick::Application.config.version = '#{version}'"
    end
  end 
end
