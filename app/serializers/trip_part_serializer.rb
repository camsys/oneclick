class TripPartSerializer < ActiveModel::Serializer
  include CsHelpers

  attributes :id, :description, :description_without_direction, :start_time, :end_time
  attribute :is_depart, key: :is_depart_at
  has_many :itineraries
  attr_accessor :debug

  def initialize(object, options={})
    super(TripPartDecorator.new(object), options)
    @debug = options[:debug]
  end

  def itineraries
    if @debug
      Rails.logger.info "Returning ALL itineraries (debug)"
      return object.itineraries
    end
    Rails.logger.info "Returning filtered itineraries (non-debug)"
    itineraries = object.itineraries.valid.visible
    return itineraries if Oneclick::Application.config.max_offset_from_desired.nil?
    latest_time = (start_time || end_time) + Oneclick::Application.config.max_offset_from_desired
    earliest_time = (start_time || end_time) - Oneclick::Application.config.max_offset_from_desired
    itineraries.select do |i|
      if object.is_depart
        i.start_time.nil? || ((i.start_time >= earliest_time) && (i.start_time <= latest_time))
      else
        i.end_time.nil? || ((i.end_time >= earliest_time) && (i.end_time <= latest_time))
      end
    end
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
