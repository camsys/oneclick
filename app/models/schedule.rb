class Schedule < ActiveRecord::Base

  #associations
  belongs_to :service

  attr_accessible :service, :service_id, :start_time, :end_time, :day_of_week
end
