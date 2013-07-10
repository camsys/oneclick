class Trip < ActiveRecord::Base
  attr_accessor :trip_date, :trip_time
  attr_accessible :name, :owner, :from_place_id, :to_place_id, :trip_datetime, :trip_date, :trip_time, :arrive_depart
  belongs_to :owner, foreign_key: 'user_id', class_name: User
  belongs_to :from_place, foreign_key: 'from_place_id', class_name: Place
  belongs_to :to_place, foreign_key: 'to_place_id', class_name: Place
  has_many :itineraries

  before_save :write_trip_datetime

  def write_trip_datetime
    begin
      self.trip_datetime = DateTime.strptime(self.trip_date + ' ' + self.trip_time, '%m/%d/%Y %H:%M %p')
    rescue ArgumentError
      #TODO: Handle this error
      self.trip_datetime = DateTime.now
    end
  end

  def create_itineraries
    tp = TripPlanner.new
    result, response = tp.get_fixed_itineraries([self.to_place.lat, self.to_place.lon],[self.from_place.lat, self.from_place.lon], self.trip_datetime)
    if result
      tp.convert_itineraries(response).each do |itinerary|
        self.itineraries << Itinerary.new(itinerary)
      end
    else
      self.itineraries << Itinerary.new('status'=>response['id'], 'message'=>response['msg'])
    end
    self.save
  end

end
