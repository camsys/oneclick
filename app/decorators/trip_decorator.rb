class TripDecorator < Draper::Decorator
  decorates_association :itineraries  
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def created
    I18n.l created_at, format: :isoish
  end

  def trip_date
    I18n.l trip_datetime, format: :isoish
  end

  def user
    object.user.name
  end

  def assisted_by
    (object.user == object.creator) ? '' : object.creator.name
  end
  
  def creator
    object.creator.name
  end

  def from
    from_place.name
  end

  def to
    to_place.name
  end

  def from_lat
    from_place.lat
  end

  def from_lon
    from_place.lon
  end

  def out_arrive_or_depart
    outbound_part.is_depart ? I18n.t(:departing_at) : I18n.t(:arriving_by)
  end
  
  def from_datetime
    I18n.l outbound_part.scheduled_time, format: :isoish
  end
  
  def to_lat
    to_place.lat
  end
  
  def to_lon
    to_place.lon
  end

  def in_arrive_or_depart
    if is_return_trip
      return_part.is_depart ? I18n.t(:departing_at) : I18n.t(:arriving_by)
    end
  end
  
  def to_datetime
    if is_return_trip
      I18n.l return_part.scheduled_time, format: :isoish
    end
  end
  
  def round_trip
    is_return_trip ? I18n.t(:yes_str) : I18n.t(:no_str)
  end
  
  def eligibility
  end
  
  def accommodations
    
  end
  
  def outbound_itinerary_count
    outbound_part.itineraries.count
  end
  
  def return_itinerary_count
    if is_return_trip
      return_part.itineraries.count
    end
  end
  
  def outbound_selected_short
    get_trip_summary(outbound_part.selected_itinerary) if outbound_part.selected_itinerary
  end
  
  def return_selected
    if is_return_trip
      get_trip_summary(return_part.selected_itinerary) if return_part.selected_itinerary
    end
  end
  
  def status
  end
  
  def device
  end
  
  def location
  end
  
  def trip_purpose
    I18n.t object.trip_purpose.name
  end

  def modes
    I18n.t(desired_modes.map{|m| m.name}).join ', '
  end

  def get_trip_summary itinerary
    h.get_trip_summary_name(itinerary)

    summary = ''
    if itinerary.is_walk
      itinerary.get_legs.each do |leg|
        summary += "#{I18n.t(leg.mode.downcase)} #{I18n.t(:to)} #{leg.end_place.name};"
      end
    else
      case itinerary.mode.code
      when 'mode_transit', 'mode_bus', 'mode_rail'
        itinerary.get_legs.each do |leg|
          case leg.mode
          when Leg::TripLeg::WALK
            summary += "#{I18n.t(leg.mode.downcase)}"
          when Leg::TripLeg::CAR
            summary += "#{I18n.t(:drive)}/#{I18n.t(:taxi)}"
          else
            summary += "#{leg.agency_id} #{I18n.t(leg.mode.downcase)} #{leg.route}"
          end
          summary += " #{I18n.t(:to)} #{leg.end_place.name};"
        end
      when 'mode_paratransit'
        itinerary.service.get_contact_info_array.each do |a,b|
          summary += "#{I18n.t(:paratransit)} #{I18n.t(a)}: #{sanitize_nil_to_na b}"
        end
      when 'mode_taxi'
        YAML.load(itinerary.server_message).each do |business|
          summary += "#{I18n.t(:taxi)} #{business['name']}: #{business['phone']};"
        end
      when 'mode_rideshare'
        YAML.load(itinerary.server_message).each do |business|
          summary += "#{I18n.t(:rideshare)} #{business['name']}: #{business['phone']};"
        end
      else
        summary += "#{I18n.t(:unknown)} #{I18n.t(:mode)}"
      end
    end
    summary
  end
  
end
