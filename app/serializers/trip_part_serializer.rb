class TripPartSerializer < ActiveModel::Serializer
  include CsHelpers

  attributes :id, :description, :description_without_direction, :start_time, :end_time
  attribute :is_depart, key: :is_depart_at
  has_many :itineraries

  def initialize(object, options={})
    super(TripPartDecorator.new(object), options)
  end

  def round_trip trip
    trip.is_return_trip ? I18n.t(:round_trip) : I18n.t(:one_way)
  end

  def start_time
    object.is_depart ? object.trip_time : nil
  end

  def end_time
    object.is_depart ? nil : object.trip_time
  end

end
