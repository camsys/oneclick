class Trip < ActiveRecord::Base
    
  attr_accessor :name

  # Associations
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :trip_places
  has_many :planned_trips
  
  # Scopes
  scope :created_between, lambda {|from_day, to_day| where("created_at > ? AND created_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
  
  def to_s
    if trip_places.count > 0
      "From %s to %s" % [trip_places.first, trip_places.last]
    else
      "Uninitialized" 
    end  
  end
  
  def from_place
    trip_places.first
  end
  
  def to_place
    trip_places.last
  end
  
end
