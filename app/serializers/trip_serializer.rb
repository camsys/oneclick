class TripSerializer < ActiveModel::Serializer
  self.root = false
  
  attributes :id, :status
  has_many :trip_parts

  def status
    0
  end
  
end
