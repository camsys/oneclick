class ZoneFare < ActiveRecord::Base
  belongs_to :from_zone, :class_name => "FareZone"
  belongs_to :to_zone, :class_name => "FareZone"
  belongs_to :fare_structure
  belongs_to :characteristic
  belongs_to :trip_purpose

  validates :fare_structure, presence: true
end
