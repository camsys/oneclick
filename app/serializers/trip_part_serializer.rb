class TripPartSerializer < ActiveModel::Serializer
  include CsHelpers

  attributes :id, :description, :start_time, :end_time
  attribute :is_depart, key: :is_depart_at
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

  def start_time
    puts "============="
    puts object.ai
    puts "============="
    object.is_depart ? object.trip_time : nil
  end

  def end_time
    object.is_depart ? nil : object.trip_time
  end

end
