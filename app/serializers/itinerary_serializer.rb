class ItinerarySerializer < ActiveModel::Serializer
  include CsHelpers
  include ActionView::Helpers::NumberHelper

  attributes :id, :missing_information, :mode, :mode_name, :service_name, :provider_name, :contact_information,
    :cost, :duration, :transfers, :start_time, :end_time, :legs, :service_window, :duration_estimated, :selected
  attributes :server_status, :server_message, :failed, :hidden, :logo_url
  attr_accessor :debug

  def initialize(object, options={})
    super(object, options)
    @debug = options[:debug]
  end

  def filter(keys)
    unless @debug
      keys
    else
      keys - [:server_status, :server_message, :failed, :hidden]
    end
  end


  def mode
    object.mode.code rescue nil
  end

  def mode_name
    get_trip_summary_title(object)
  end

  def provider_name
    object.service.provider.name rescue nil
  end

  def logo_url
    logo_url_helper(object)
  end

  def missing_information
    es = EligibilityService.new
    es.get_service_itinerary(object.service, object.trip_part.trip.user.user_profile, object.trip_part, :missing_info)
  end

  def contact_information
    case object.mode
    when Mode.taxi
      {
        text: (YAML.load(object.server_message).collect{|k| k['name'] + ': ' + k['phone']}.join(", ") rescue nil)
      }
    else
      object.service.contact_information rescue nil
    end
  end

  def start_time
    tp = object.trip_part
    case object.mode
    when Mode.taxi
      tp.is_depart ? tp.trip_time : (tp.trip_time - object.duration.seconds)
    else
      object.start_time
    end
  end

  def end_time
    tp = object.trip_part
    case object.mode
    when Mode.taxi
      tp.is_depart ? (tp.trip_time + object.duration.seconds) : tp.trip_time
    else
      object.end_time
    end
  end

  def cost
    estimated = false
    fare = object.cost || (object.service.fare_structures.first rescue nil)
    # if fare.nil?
    #   {price: nil, comments: 'Unknown', price_formatted: '?'} # TODO I18n
    if fare.respond_to? :fare_type
      case fare.fare_type
      when FareStructure::FLAT
        {price: fare.base.to_f, comments: '', estimated: false, price_formatted: number_to_currency(fare.base)}
      when FareStructure::MILEAGE
        {price: fare.base.to_f, comments: "+#{number_to_currency(fare.rate)}/mile - " + I18n.t(:cost_estimated), estimated: true,
         price_formatted: number_to_currency(fare.base.ceil) + '*'}
      when FareStructure::COMPLEX
        {price: nil, comments: I18n.t(:see_details_for_cost), estimated: true, price_formatted: '*'}
      end
    else
      price_formatted = number_to_currency(fare)
      comments = ''
      fare = fare.to_f
      case object.mode
      when Mode.taxi
        fare = fare.ceil
        estimated = true
        price_formatted = number_to_currency(fare) + '*'
        comments = I18n.t(:cost_estimated)
      when Mode.rideshare
        fare = nil
        estimated = true
        price_formatted = '*'
        comments = I18n.t(:see_details_for_cost)
      end
      {price: fare, comments: comments, price_formatted: price_formatted, estimated: estimated}
    end

  end

  def legs
    legs = object.get_legs

    last_leg = nil
    legs.inject([]) do |m, leg|
      if !last_leg.nil? && (leg.start_time > (last_leg.end_time + 1.second))
        m <<        {
          type: 'WAIT',
          description: I18n.t(:wait_at) + ' '+ last_leg.end_place.name,
          start_time: (last_leg.end_time + 1.second).iso8601,
          end_time: (leg.start_time - 1.second).iso8601,
          start_place: "#{last_leg.end_place.lat},#{last_leg.end_place.lon}",
          end_place: "#{leg.start_place.lat},#{leg.start_place.lon}",
        }
      end
      m <<        {
        type: leg.mode,
        description: leg.short_description,
        start_time: leg.start_time.iso8601,
        end_time: leg.end_time.iso8601,
        start_place: "#{leg.start_place.lat},#{leg.start_place.lon}",
        end_place: "#{leg.end_place.lat},#{leg.end_place.lon}",
      }
      last_leg = leg
      m
    end
  end

  def duration
    {
      # TODO I18n
      # omitting for now per discussion w/ Xudong
      # external_duration: , #": "String Opt", // (seconds) Textural description of duration, for display to users
      sortable_duration: object.duration || (object.end_time - object.start_time), #": "Number Opt", // (seconds) For filtering purposes, not display
      total_walk_time: object.walk_time, #": "Number Opt", // (seconds)
      total_walk_dist: object.walk_distance, #": "Number Opt", // (feet?)
      total_transit_time: object.transit_time, #": "Number Opt", // (seconds)
      total_wait_time: object.wait_time, #": "Number Opt", // (seconds)
    }
  end

  def service_window
    case object.mode
    when Mode.paratransit
      object.service.service_window || 0
    else
      0
    end
  end

  def selected
    object.selected
  end

end
