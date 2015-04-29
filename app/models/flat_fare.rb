class FlatFare < ActiveRecord::Base
  belongs_to :fare_structure
  belongs_to :characteristic
  belongs_to :trip_purpose
  
  validates :fare_structure, presence: true
end
