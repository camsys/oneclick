class ItinerarySerializer < ActiveModel::Serializer
  include CsHelpers
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::JavaScriptHelper

  attributes :id, :missing_information, :mode, :mode_name, :service_name, :provider_name, :contact_information,
    :cost, :duration, :transfers, :start_time, :end_time, :legs, :service_window, :duration_estimated, :selected, :display_color
  attributes :server_status, :server_message, :failed, :hidden, :logo_url, :mode_logo_url, :accommodations
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
    # TODO This walk special case should really be done in the itinerary itself
    # if object.is_walk
    #  return Mode.walk.code
    # end
    #object.mode.code rescue nil

    object.returned_mode_code
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

  def mode_logo_url
    returned_mode = Mode.unscoped.where(code: object.returned_mode_code).first
    returned_mode.logo_url if returned_mode
  end

  def display_color
    object.service.display_color if object.service.present?
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
    get_itinerary_start_time(object)
  end

  def end_time
    get_itinerary_end_time(object)
  end

  def cost
    get_itinerary_cost(object)
  end

  def legs
    legs = object.get_legs(false)

    last_leg = nil
    legs.inject([]) do |m, leg|
      if !last_leg.nil? && (leg.start_time > (last_leg.end_time + 1.second))
        m <<        {
          type: 'WAIT',
          description: escape_javascript(I18n.t(:wait_at) + ' '+ last_leg.end_place.name),
          start_time: (last_leg.end_time + 1.second).iso8601,
          end_time: (leg.start_time - 1.second).iso8601,
          start_place: "#{last_leg.end_place.lat},#{last_leg.end_place.lon}",
          end_place: "#{leg.start_place.lat},#{leg.start_place.lon}",
        }
      end

      leg_mode_type = leg.mode.downcase if leg.mode
      leg_mode = Mode.unscoped.where(code: "mode_#{leg_mode_type}").first
      m <<        {
        type: leg.mode,
        logo_url: (leg_mode.logo_url if leg_mode),
        description: escape_javascript(leg.short_description),
        start_time: leg.start_time.iso8601,
        end_time: leg.end_time.iso8601,
        start_place: "#{leg.start_place.lat},#{leg.start_place.lon}",
        end_place: "#{leg.end_place.lat},#{leg.end_place.lon}",
        display_color: object.service ? (["BICYCLE","WALK","WAIT","CAR"].include?(leg.mode) ? "" : (object.service.display_color.nil? || object.service.display_color.blank? ? leg.display_color : object.service.display_color)) : leg.display_color
      }

      # if object.service
      #   unless ["BICYCLE","WALK","WAIT","CAR"].include?(leg.mode)
      #     if object.service.display_color.nil? || object.service.display_color.blank?
      #       m.first[:display_color] = leg.display_color
      #     else 
      #       m.first[:display_color] = object.service.display_color
      #     end
      #   end
      # else
      #   m.first[:display_color] = leg.display_color
      # end

      last_leg = leg
      m
    end
  end

  def duration
    service_window_duration = (object.service_window * 60 rescue 0)
    sortable_duration = object.duration || (end_time - start_time - service_window_duration) if start_time && end_time

    {
      # TODO I18n
      # omitting for now per discussion w/ Xudong
      # external_duration: , #": "String Opt", // (seconds) Textural description of duration, for display to users
      sortable_duration:  sortable_duration, #": "Number Opt", // (seconds) For filtering purposes, not display
      total_walk_time: object.walk_time, #": "Number Opt", // (seconds)
      total_walk_dist: object.walk_distance, #": "Number Opt", // (feet?)
      total_transit_time: object.transit_time, #": "Number Opt", // (seconds)
      total_wait_time: object.wait_time, #": "Number Opt", // (seconds)
      duration_in_words: (sortable_duration ? duration_to_words(sortable_duration) : I18n.t(:not_available))
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

  def accommodations
    case object.mode
    when Mode.paratransit
      accoms = object.service.accommodations.map{|a| I18n.t(a.name) }
    end
  end

end
