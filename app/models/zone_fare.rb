class ZoneFare < ActiveRecord::Base
  belongs_to :from_zone, :class_name => "FareZone"
  belongs_to :to_zone, :class_name => "FareZone"
  belongs_to :fare_structure

  validates :to_zone, presence: true
end
