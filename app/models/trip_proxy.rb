class TripProxy < Proxy
  # User object for the traveler
  attr_accessor :traveler
  # Type of operation. Defined in TripController. One of NEW, EDIT, REPEAT
  attr_accessor :mode
  # Id of the trip being re-planned, edited, etc. Null if mode is NEW
  attr_accessor :id, :map_center

  include Trip::From
  include Trip::PickupTime
  include Trip::Purpose
  include Trip::ReturnTime
  include Trip::To

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
end
