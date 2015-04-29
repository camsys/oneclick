class ZoneFare < ActiveRecord::Base
  belongs_to :from_zone, :class_name => "FareZone"
  belongs_to :to_zone, :class_name => "FareZone"
  belongs_to :fare_structure

  validates :fare_structure, presence: true
end
