class TripPartSerializer < ActiveModel::Serializer
  include CsHelpers

  attributes :id, :description, :description_without_direction, :start_time, :end_time
  attribute :is_depart, key: :is_depart_at
  has_many :itineraries
  attr_accessor :debug

  def initialize(object, options={})
    super(TripPartDecorator.new(object), options)
    @debug = options[:debug]
    puts "initialize: #{@debug}"
  end

  def itineraries
    puts "itineraries: #{@debug}"
    if @debug
      return object.itineraries
    end
    itineraries = object.itineraries.valid.visible
    return itineraries if Oneclick::Application.config.max_delay_from_desired.nil?
    target_time = (start_time || end_time) + Oneclick::Application.config.max_delay_from_desired
    itineraries.select do |i|
      if object.is_depart
        i.start_time.nil? || (i.start_time <= target_time)
      else
        i.end_time.nil? || (i.end_time <= target_time)
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
