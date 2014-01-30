class GeoCoverage < ActiveRecord::Base

  #associations
  has_many :service_coverage_maps
  has_many :services, through: :service_coverage_maps

  #coverage_type: zipcode, county_name, polygon
  attr_accessible :coverage_type, :value, :polygon

  def polygon_contains?(lon, lat)
    factory = RGeo::Geographic.simple_mercator_factory
    point = factory.point(lon.to_f, lat.to_f)
    return self.polygon.contains?(point)
  end

  def polygon_to_array
    geometry = []
    #Boundary.first.polygon.exterior_ring.points.each do |point|
    Boundary.find(4).geom.first.exterior_ring.points.each do |point|
      geometry << [point.y, point.x]
    end
    geometry
  end

end
