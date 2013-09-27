require 'chronic'

class TripProxy < Proxy

  # General state variables
 
  # User object for the traveler
  attr_accessor :traveler
  # Type of operation. Defined in TripController. One of NEW, EDIT, REPEAT
  attr_accessor :mode
  # Id of the trip being re-planned, edited, etc. Null if mode is NEW
  attr_accessor :id
  
  # Form variables
  #
  # name or raw address of the end points selected by the user. The value could be the
  # name of an objecct (Place, POI), a previously used address (from TripPlace) or a string
  # entered into the control by the user (Raw Address)
  attr_accessor :from_place, :to_place
  # Trip time and date, purpose etc.
  attr_accessor :trip_date, :arrive_depart, :trip_time, :trip_purpose_id
  
  # Hidden form variables. These are set via javascript based on the UI interactions
  #
  # Stores the type of selection made by the user for an end point. Defined
  # in PlaceSearchingConteoller
  #  1 = POI
  #  2 = CACHED_ADDRESS from TripPlaces
  #  3 = PLACE fro MyPlaces
  #  4 = RAW ADDRESS typed in
  attr_accessor :from_place_selected_type, :to_place_selected_type
  # The Id of an end point. Value depends on the type of end point selected
  # if POI -- the id of the POI selected
  # if CACHED ADDRESS -- the id of the TripPlace selected
  # if PLACE -- the id of the Place selected
  # if RAW ADDRESS -- the index of the address in the geocoder cache for that end point 
  attr_accessor :from_place_selected, :to_place_selected
    
  # Other attributes that are used to cache trip data during edits and repeats
  #
  # geolocs
  attr_accessor :from_lat, :from_lon
  attr_accessor :to_lat, :to_lon
  # addresses as they could be different from the name for POIS and places
  attr_accessor :from_raw_address, :to_raw_address
  
  # Basic validations. Just checking that the form is complete
  validates :from_place, :presence => true 
  validates :to_place, :presence => true
  validates :trip_date, :presence => true
  validates :trip_time, :presence => true
  validates :trip_purpose_id, :presence => true
  
  # Custom validations
  
  # check date and time format and ensure trips are not being planned in the past
  validate :validate_date
  validate :validate_time
  validate :datetime_cannot_be_before_now
  
  # Make sure that the user made a selection for each end point.
  validate :validate_from_selection
  validate :validate_to_selection
  
  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  def trip_datetime
    begin
      return DateTime.strptime([trip_date, trip_time, DateTime.current.zone].join(' '), '%m/%d/%Y %H:%M %p %z')
    rescue Exception => e
      Rails.logger.warn "write_trip_datetime #{trip_date} #{trip_time}"
      Rails.logger.warn e.message
      return nil
    end
  end

protected
  
  # Validation. Check that there has been a selection for the from place
  def validate_from_selection
    if from_place_selected.blank? || from_place_selected_type.blank?
      errors.add(:from_place, I18n.translate(:nothing_found))
      return false      
    end
  end
  
  # Validation. Check that there has been a selection for the to place
  def validate_to_selection
    if to_place_selected.blank? || to_place_selected_type.blank?
      errors.add(:to_place, I18n.translate(:nothing_found))
      return false      
    end
  end
  
  # Validation. Ensure that the user is planning a trip for the future. 
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

  # Validation. Check that the date is well formatted and can be coerced into a date        
  def validate_date
    begin
      # if the parse fails it will return nil and the to_date will throw an exception
      d = Chronic.parse(@trip_date).to_date
    rescue Exception => e
      errors.add(:trip_date, I18n.translate(:date_wrong_format))
    end
  end

  # Validation. Check that the trip time is well formatted and can be coerced into a time        
  def validate_time
    begin
      Time.strptime(@trip_time, "%H:%M %p")
    rescue Exception => e
      errors.add(:trip_time, I18n.translate(:time_wrong_format))
    end
  end
              
end
