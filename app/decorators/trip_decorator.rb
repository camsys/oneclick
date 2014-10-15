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

  def initialize object, options={}
    super
    @elig_svc = EligibilityService.new
  end
  
  def created
    I18n.l created_at, format: :isoish
  end

  def trip_date
    I18n.l trip_datetime, format: :isoish
  end

  def user
    object.user.name if object.user
  end

  def assisted_by
    (object.user == object.creator) ? '' : creator
  end
  
  def creator
    object.creator.name if object.creator
  end

  def leaving_from
    from_place.name
  end

  def going_to
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
  
  def out_datetime
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
  
  def in_datetime
    if is_return_trip
      I18n.l return_part.scheduled_time, format: :isoish
    end
  end
  
  def round_trip
    is_return_trip ? I18n.t(:yes_str) : I18n.t(:no_str)
  end
  
  def booked
    is_booked? ? I18n.t(:yes_str) : I18n.t(:no_str)
  end

  def eligibility
    get_eligibility(outbound_part.selected_itinerary, object.user.user_profile)
  end
  
  def accommodations
    get_accomodations(outbound_part.selected_itinerary)
  end
  
  def outbound_itinerary_count
    outbound_part.itineraries.count
  end

  def outbound_itinerary_modes
    strings = []
    itinerary_modes outbound_part, strings
    strings.join(', ')
  end

  def return_itinerary_count
    if is_return_trip
      return_part.itineraries.count
    end
  end

  def return_itinerary_modes
    strings = []
    itinerary_modes(return_part, strings) if is_return_trip
    strings.join(', ')
  end

  def itinerary_modes part, strings
    part.itineraries.group(:mode_id).count.each do |key, val|
      key ||= Mode.walk.id
      key_name = I18n.t("#{Mode.unscoped.find(key).code}_name")
      strings << "#{key_name}: #{val}"
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
    I18n.t object.trip_purpose.name if object.trip_purpose
  end

  def modes
    I18n.t(desired_modes.map{|m| m.name}).join ', ' if desired_modes
  end

  def get_trip_summary itinerary
    summary = ''
    if itinerary.is_walk
      itinerary.get_legs(false).each do |leg|
        summary += "#{I18n.t(leg.mode.downcase)} #{I18n.t(:to)} #{leg.end_place.name};"
      end
    else
      if itinerary.mode.nil?
        code = 'skip'
        if itinerary.server_status == 500
          summary += itinerary.server_message
        elsif !itinerary.mode_id.nil?
          mode = Mode.unscoped.find(itinerary.mode_id)
          code = mode.code unless mode.nil?
        end
      else
        code = itinerary.mode.code
      end
      
      case code
      when 'mode_transit', 'mode_bus', 'mode_rail'
        itinerary.get_legs(false).each do |leg|
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
        if itinerary.service
          itinerary.service.get_contact_info_array.each do |a,b|
            summary += "#{I18n.t(:paratransit)} #{I18n.t(a)}: #{h.sanitize_nil_to_na b};"
          end
        end
        
      when 'mode_taxi'
        YAML.load(itinerary.server_message).each do |business|
          summary += "#{I18n.t(:taxi)} #{business['name']}: #{business['phone']};"
        end
      when 'mode_rideshare'
        if itinerary.server_message
          YAML.load(itinerary.server_message).each do |business|
            summary += "#{I18n.t(:rideshare)} #{business['name']}: #{business['phone']};"
          end
        else
          # TODO: this should be generalized here and in _rideshare_details.html.haml
          summary += 'Georgia Commute Options'
        end
      when 'skip'
        # do nothing
      else
        summary += "#{I18n.t(:unknown)} #{I18n.t(:mode)}"
      end
    end
    summary
  end

  def get_accomodations itinerary
    result = ''
    if itinerary && itinerary.service
      itinerary.service.accommodations.each do |a|
        result += "#{I18n.t(a.name)};"
      end
    end
    result
  end

  def get_eligibility(itinerary, user_profile)
    result = ''
    if itinerary && itinerary.service
      groups = itinerary.service.service_characteristics.pluck(:group).uniq rescue []
      groups.each do |group|
        itinerary.service.service_characteristics.where(group: group).each do |map|
          requirement = map.characteristic
          user_characteristic = UserCharacteristic.where(user_profile_id: user_profile.id,
                                                         characteristic_id: requirement.id)
          if user_characteristic.count > 0 &&
            user_characteristic.first.meets_requirement(map)
            result += "#{@elig_svc.translate_service_characteristic_map(map)};"
          end
        end
      end
    end
    result
  end
  
end

