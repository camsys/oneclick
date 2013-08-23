require 'chronic'

class Trip < ActiveRecord::Base
  attr_accessor :trip_date, :trip_time

  # mark this model as requiring roles
  resourcify

  validates_associated :from_place
  validates_associated :to_place
  validates_associated :places

  validate :validate_date_and_time
  validate :datetime_cannot_be_before_now
  attr_accessible :name, :owner, :trip_datetime, :trip_date, :trip_time, :arrive_depart, :places_attributes,
  :from_place_attributes, :to_place_attributes, :owner

  has_many :places, class_name: TripPlace
  has_one :from_place, class_name: TripPlace, conditions: "sequence=0"
  has_one :to_place, class_name: TripPlace, conditions: "sequence=1"

  belongs_to :owner, foreign_key: 'user_id', class_name: User
  has_many :itineraries
  has_many :valid_itineraries, conditions: 'status=200 AND hidden=false', class_name: 'Itinerary'
  has_many :hidden_itineraries, conditions: 'status=200 AND hidden=true', class_name: 'Itinerary'

  accepts_nested_attributes_for :places, :from_place, :to_place

  #scope :recent, lambda {|date| where('created_at > ?', date.beginning_of_day) unless date.nil? }
  
  scope :anonymous, where('user_id is NULL')
  scope :created_between, lambda {|from_day, to_day| where("created_at > ? AND created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
 
  def self.rejected
    joins(:itineraries).where('status=200 AND hidden=true').uniq
  end
    
  def self.failed
    ids = []
    Itinerary.failed_trip_ids.each do |row|
      ids << row[:trip_id]
    end
    where('id in (?)', ids)
  end

  def has_valid_itineraries?
    not valid_itineraries.empty?
  end

  def validate_date_and_time
    good_date = true
    good_time = true
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      d = Chronic.parse(@trip_date).to_date
      # bump to next year if they only spec'd day and month and we parsed it to be in the past
      d += 1.year if d.past? and @trip_date.split(%r{/}).size < 3
      @trip_date = d.strftime("%m/%d/%Y")
    rescue Exception => e
      Rails.logger.warn "parsing date #{@trip_date}"
      Rails.logger.warn e.ai
      errors.add(:trip_date, I18n.translate(:date_wrong_format))
      good_date = false
    end

    begin
      Time.strptime(@trip_time, "%H:%M %p")
    rescue Exception => e
      Rails.logger.warn "parsing time #{@trip_time}"
      Rails.logger.warn e.ai
      errors.add(:trip_time, I18n.translate(:time_wrong_format))
      good_time = false
    end

    return false unless good_date && good_time

    if !write_trip_datetime
      errors.add(:trip_date, I18n.translate(:date_wrong_format))
    end
    true
  end

  def write_trip_datetime
    begin
      self.trip_datetime = DateTime.strptime([@trip_date, @trip_time, DateTime.current.zone].join(' '),
        '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "write_trip_datetime #{@trip_date} #{@trip_time}"
      Rails.logger.warn e.message
      return false
    end
    true
  end

  def datetime_cannot_be_before_now
    return true if trip_datetime.nil?
    if trip_datetime < Date.today
      errors.add(:trip_date, I18n.translate(:trips_cannot_be_entered_for_days))
      return false
    elsif trip_datetime < Time.current
      errors.add(:trip_time, I18n.translate(:trips_cannot_be_entered_for_times))
      return false
    end
    true
  end

  def create_itineraries
    self.create_fixed_route_itineraries
    self.create_rideshare_itineraries
    self.create_paratransit_itineraries
    self.create_taxi_itineraries
  end

  # TODO refactor following 3 methods
  def create_fixed_route_itineraries
    tp = TripPlanner.new
    arrive_by = arrive_depart.index("arrive_by") ? "true" : "false"
    result, response = tp.get_fixed_itineraries([from_place.lat, from_place.lon],[to_place.lat, to_place.lon], trip_datetime.in_time_zone, arrive_by)
    if result
      tp.convert_itineraries(response).each do |itinerary|
        itineraries << Itinerary.new(itinerary)
      end
    else
      itineraries << Itinerary.new('status'=>response['id'], 'message'=>response['msg'])
    end
  end

  def create_taxi_itineraries
    tp = TripPlanner.new
    result, response = tp.get_taxi_itineraries([self.to_place.lat, self.to_place.lon],[self.from_place.lat, self.from_place.lon], self.trip_datetime.in_time_zone)
    if result
      itinerary = tp.convert_taxi_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('status'=>500, 'message'=>response)
    end
  end

  def create_paratransit_itineraries
    #TODO: This is just a place holder that currently returns demo data only.
    tp = TripPlanner.new
    result, response = tp.get_paratransit_itineraries([self.to_place.lat, self.to_place.lon],[self.from_place.lat, self.from_place.lon], self.trip_datetime.in_time_zone)
    if result
      itinerary = tp.convert_paratransit_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('status'=>500, 'message'=>response)
    end
  end

  def create_rideshare_itineraries
    tp = TripPlanner.new
    result, response = tp.get_rideshare_itineraries(self.from_place, self.to_place, self.trip_datetime.in_time_zone)
    if result
      itinerary = tp.convert_rideshare_itineraries(response)
      self.itineraries << Itinerary.new(itinerary)
    else
      self.itineraries << Itinerary.new('status'=>500, 'message'=>response)
    end
  end

end
