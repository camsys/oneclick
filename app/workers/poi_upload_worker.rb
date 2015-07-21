class PoiUploadWorker
  include Sidekiq::Worker

  def perform(filename)
    Rails.logger.info "PoiUploadWorker#perform, url=#{filename}"
    Poi.load_pois(filename)
    OneclickConfiguration.create_or_update(:poi_is_loading, false)
  end
end
