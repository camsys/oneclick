class TripSerializer < ActiveModel::Serializer
  attributes :id, :status
  has_many :trip_parts

  def status
    0
  end
  
end
