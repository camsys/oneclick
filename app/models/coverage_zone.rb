class CoverageZone < ActiveRecord::Base

  has_one :service


  def to_array
    myArray = []
    self.geom.each do |polygon|
      polygon_array = []
      ring_array  = []
      polygon.exterior_ring.points.each do |point|
        ring_array << [point.y, point.x]
      end
      polygon_array << ring_array

      polygon.interior_rings.each do |ring|
        ring_array = []
        ring.points.each do |point|
          ring_array << [point.y, point.x]
        end
        polygon_array << ring_array
      end
      myArray << polygon_array
    end
    myArray
  end
  
end
