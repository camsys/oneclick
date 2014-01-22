#encoding: utf-8
namespace :oneclick do
  namespace :read_esp do
    desc "Unpack ESP Data and load into OneClick DB"
    task :unpack => :environment do

      esp_reader = EspReader.new
      esp_reader.unpack

    end # task
  end
end
