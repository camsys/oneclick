class TripPartSerializer < ActiveModel::Serializer
  attributes :id, :description
  # , :start_time, :end_time
  attribute :is_depart, key: :is_depart_at

  def description
    # out = trip_parts.first
    trip = object.trip
    s = [round_trip(trip),
    I18n.t(:from).downcase,
    trip.from_place.name,
    I18n.t(:to).downcase,
    trip.to_place.name,
    depart_arrive.downcase,
    format_date(object.trip_time),
    I18n.t(:at),
    format_time(object.trip_time),
    ].join ' '
  end

  def round_trip trip
    trip.is_return_trip ? I18n.t(:round_trip) : I18n.t(:one_way)
  end

  def depart_arrive 
    object.is_depart ? I18n.t(:departing_at) : I18n.t(:arriving_by)
  end

end
