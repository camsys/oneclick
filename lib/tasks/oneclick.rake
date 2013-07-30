#encoding: utf-8
namespace :oneclick do
  task :seed_data => :environment do
    throw Exception.new("*** Deprecated, just use db:seed task ***")
  end
end
