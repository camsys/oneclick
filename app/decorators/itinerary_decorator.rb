class ItineraryDecorator < Draper::Decorator
  delegate_all

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
    return 'Click for cost details' if cost.nil?
    return 'Not available' if cost.nil?
    (cost != 0 ? h.number_to_currency(cost) : "No cost for this service.")
  end

  def duration_in_words
    # TODO should be t(:not_available)
    (duration ? h.duration_to_words(duration) + " (est.)" : 'Not available')
  end

  def notes
    case mode.code
    when 'mode_transit'
      'No'
    when 'mode_taxi'
      'Yes'
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
      'Note'
    when 'mode_transit', 'mode_taxi', 'mode_paratransit'
      'Book ahead'
    else
      'Note'
    end
  end

  def walking_time
    h.duration_to_words(walk_time)
  end

  def transfers_in_words
    transfers || 'None'
    # I18n.translate(:transfer, count: i.transfers)
  end


end
