#encoding: utf-8
namespace :oneclick do
  namespace :one_offs do

    desc "Associate Shapefile Boundaries with Services"
    task :add_boundaries => :environment do
      #Delete all polygon-based boundaries
      gcs = GeoCoverage.where(coverage_type: 'polygon')
      gcs.each do |gc|
        gc.service_coverage_maps.destroy_all
        gc.delete
      end

      Boundary.all.each do |b|
        gc = GeoCoverage.new(value: b.agency, coverage_type: 'polygon', polygon: b)
        case b.agency
          when "Cobb Community Transit (CCT)"
            service = Service.find_by_external_id("54104859570670229999")
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'origin')
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'destination')
          when "Cherokee Area Transportation System (CATS)"
            service = Service.find_by_external_id("32138199527497131111")
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'origin')
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'destination')
          #when "Gwinnett County Transit (GCT)"
          #when "Metropolitan Atlanta Rapid Transit Authority"
        end
      end
    end


  end
end
