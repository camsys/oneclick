class ItineraryDecorator < Draper::Decorator
  delegate_all
  decorates_association :trip_part

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def service
    s = object.service
    return s if s
    return Service.new(name: get_trip_summary_name(object),
      service_type: ServiceType.new(name: 'Faked service type'),
      provider: Provider.new()
      )
  end

  def cost_in_words
    return h.number_to_currency(cost.round) + " (est)" if mode.code == 'mode_taxi'
    return I18n.t(:click_for_cost_details) if cost.nil?
    return I18n.t(:not_available) if cost.nil?
    (cost != 0 ? h.number_to_currency(cost) : I18n.t(:no_cost_for_service))
  end

  def duration_in_words
    # TODO should be t(:not_available)
    (duration ? h.duration_to_words(duration) + " (est.)" : I18n.t(:not_available))
  end

  def time_range_in_words

    return format_time(start_time) + ' ' + I18n.t(:to) + ' ' + format_time(end_time) if (start_time && end_time)
    return ''
  end

  def notes
    case mode.code
    when 'mode_transit'
      I18n.t(:no_str)
    when 'mode_taxi'
      I18n.t(:yes_str)
    when 'mode_paratransit'
      h.duration_to_words(service.advanced_notice_minutes*60, suppress_minutes: true, days_only: true)
    when 'mode_rideshare'
      h.t(:possible_rideshares, count: ride_count) + ' ' + h.t(:view_details)
    else
      'None'
    end
  end

  def notes_label
    case mode.code
    when 'mode_rideshare'
      I18n.t(:note)
    when 'mode_transit', 'mode_taxi', 'mode_paratransit'
      I18n.t(:book_ahead)
    else
      I18n.t(:note)
    end
  end

  def walking_time
    h.duration_to_words(walk_time)
  end

  def transfers_in_words
    transfers || I18n.t(:none)
    # I18n.translate(:transfer, count: i.transfers)
  end


end
