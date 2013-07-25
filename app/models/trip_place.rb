class TripPlace < Place
  self.table_name = 'trip_places'
  belongs_to :trip
end
