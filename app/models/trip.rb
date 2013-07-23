class Trip < ActiveRecord::Base
  attr_accessor :trip_date, :trip_time

  before_validation :set_places
  validates :from_place_id, :to_place_id, :presence => {:message => 'Invalid location.'}
  validate :validate_date_and_time
  attr_accessible :name, :owner, :from_place_id, :to_place_id, :trip_datetime, :trip_date, :trip_time, :arrive_depart
  belongs_to :owner, foreign_key: 'user_id', class_name: User
  belongs_to :from_place, foreign_key: 'from_place_id', class_name: Place
  belongs_to :to_place, foreign_key: 'to_place_id', class_name: Place
  has_many :itineraries

  def validate_date_and_time
    good_date = true
    good_time = true
    begin
      @date = Date.strptime(self.trip_date, "%m/%d/%Y ")
    rescue
      errors.add(:trip_date, "Date must be in MM/DD/YYYY format.")
      good_date = false
    end

    if good_date && @date < Date.today
      errors.add(:trip_date, "Trips cannot be entered for days earlier than today.")
      good_date = false
    end

    if /^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9] [AaPp][Mm]$/.match(self.trip_time) == nil
      errors.add(:trip_time, "Time must be in hh:mm am/pm format.")
      good_time = false
    end

    if good_date && good_time
      if !write_trip_datetime
        errors.add(:trip_date, "Date must be in MM/DD/YYYY format.")
      end
    end
  end

  def write_trip_datetime
    begin
      self.trip_datetime = DateTime.strptime(self.trip_date + self.trip_time + DateTime.now.zone, '%m/%d/%Y%H:%M %p%z')
    rescue Exception
      return false
    end
    true
  end

  def create_itineraries
    tp = TripPlanner.new
    result, response = tp.get_fixed_itineraries([self.to_place.lat, self.to_place.lon],[self.from_place.lat, self.from_place.lon], self.trip_datetime.localtime)
    if result
      tp.convert_itineraries(response).each do |itinerary|
        self.itineraries << Itinerary.new(itinerary)
      end
    else
      self.itineraries << Itinerary.new('status'=>response['id'], 'message'=>response['msg'])
    end
  end

  def set_places
    #TODO:  These values need to come from the combobox field
    to_place_id = 5
    from_place_id = 5
    nongeocoded_address = "th dSsdtreet, Atasdflanta, aGfA"

    if to_place_id #Here is where we test that an ID is present.
      self.to_place_id = to_place_id
    else
      to_place = Place.new('nongeocoded_address'=>nongeocoded_address)
      to_place.name = nongeocoded_address
      to_place.owner = self.owner
      to_place.save()
      self.to_place_id = to_place.id
    end

    if from_place_id #Here is where we test that an ID is present.
      self.from_place_id = from_place_id
    else
      from_place = Place.new('nongeocoded_address'=>nongeocoded_address)
      from_place.name = nongeocoded_address
      from_place.owner = self.owner
      from_place.save()
      self.from_place_id = from_place.id
    end

  end
end
