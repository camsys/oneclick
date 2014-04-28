class TripPartSerializer < ActiveModel::Serializer
  include CsHelpers

  attributes :id, :description
  attribute :is_depart, key: :is_depart_at
  attribute :scheduled_time, key: :start_time
  attribute :end_time
  has_many :itineraries

  def description
    # "Outbound - 40 Courtland Street NE Atlanta, GA to Atlanta VA Medical Center"
    # Return
    # out = trip_parts.first
    trip = object.trip
    "%s - %s %s %s" % [
      direction, object.from_trip_place.name2, I18n.t(:to).downcase, 
      object.to_trip_place.name2
    ]
    # s = [round_trip(trip),
    # I18n.t(:from).downcase,
    # trip.from_place.name,
    # I18n.t(:to).downcase,
    # trip.to_place.name,
    # depart_arrive.downcase,
    # format_date(object.trip_time),
    # I18n.t(:at),
    # format_time(object.trip_time),
    # ].join ' '
  end

  def round_trip trip
    trip.is_return_trip ? I18n.t(:round_trip) : I18n.t(:one_way)
  end

  def direction
    object.is_return_trip? ? I18n.t(:return) : I18n.t(:outbound)
  end

  def depart_arrive 
    object.is_depart ? I18n.t(:departing_at) : I18n.t(:arriving_by)
  end

  def end_time
    "end time"
  end

end
