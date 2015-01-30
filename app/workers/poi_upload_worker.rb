class PoiUploadWorker
  include Sidekiq::Worker

  def perform(filename)
    puts "PoiUploadWorker#perform uploading"
    Poi.load_pois(filename)
    OneclickConfiguration.create_or_update(:poi_is_loading, false)
  end
end
