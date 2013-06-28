class Trip < ActiveRecord::Base
  attr_accessible :name, :owner, :from, :to, :trip_datetime, :trip_date, :trip_time, :arrive_depart
  belongs_to :owner, foreign_key: 'user_id', class_name: User
  belongs_to :from, foreign_key: 'from_place_id', class_name: Place
  belongs_to :to, foreign_key: 'to_place_id', class_name: Place

  def trip_date

  end

  def trip_time

  end

end
