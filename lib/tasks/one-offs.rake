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
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'endpoint_area')
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'coverage_area')
          when "Cherokee Area Transportation System (CATS)"
            service = Service.find_by_external_id("32138199527497131111")
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'endpoint_area')
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'coverage_area')
          #when "Gwinnett County Transit (GCT)"
          #when "Metropolitan Atlanta Rapid Transit Authority"
        end
      end
    end

    task :add_manual_boundaries => :environment do
      z = Zipcode.find_by_zipcode('30309')
      s = Service.find(11)
      s.origin = z.geom
      s.save

      myArray = []
      z.geom.each do |polygon|
        polygon_array = []
        ring_array  = []
        polygon.exterior_ring.points.each do |point|
          ring_array << [point.y, point.x]
        end
        polygon_array < ring_array

        polygon.interior_rings.each do |ring|
          ring_array = []
          ring.each do |point|
            ring_array << [point.y, point.x]
          end
          polygon_array << ring_array
        end
        myArray << polygon_array
      end



    end


  end
end
