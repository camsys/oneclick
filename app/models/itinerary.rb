class Itinerary < ActiveRecord::Base
  attr_accessible :duration, :cost, :end_time, :legs, :message, :start_time, :status, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time
  belongs_to :trip
end
