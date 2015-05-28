class TripPartSerializer < ActiveModel::Serializer
  include CsHelpers
  include TripsHelper

  attributes :id, :description, :description_without_direction, :start_time, :end_time
  attribute :is_depart, key: :is_depart_at
  has_many :itineraries
  attr_accessor :debug, :asynch

  def initialize(object, options={})
    super(TripPartDecorator.new(object), options)
    @debug = options[:debug]
    @asynch = options[:asynch]
  end

  def itineraries
    if @debug
      return object.itineraries
    end
    return [] if @asynch
    
    itineraries = object.itineraries.valid.visible
    return filter_itineraries_by_max_offset_time(itineraries, object.is_depart, object.trip_time)
  end

  def round_trip trip
    trip.is_return_trip ? TranslationEngine.translate_text(:round_trip) : TranslationEngine.translate_text(:one_way)
  end

  def start_time
    object.is_depart ? object.trip_time : nil
  end

  def end_time
    object.is_depart ? nil : object.trip_time
  end

end
