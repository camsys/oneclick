class MileageFare < ActiveRecord::Base
  belongs_to :fare_structure

  validates :fare_structure, presence: true
end
