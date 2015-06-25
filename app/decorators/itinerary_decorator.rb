class ItineraryDecorator < Draper::Decorator
  include Draper::LazyHelpers
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
    FareHelper.new.get_itinerary_cost(object)[:cost_in_words]
  end

  def duration_in_words
    (duration ? h.duration_to_words(duration) + " (est.)" : '')
  end

  def date_in_words
    itinerary_start_time = get_itinerary_start_time(object)
    itinerary_end_time = get_itinerary_end_time(object)
    return format_date(itinerary_start_time + (itinerary_end_time - itinerary_start_time) / 2) if (itinerary_start_time && itinerary_end_time)
    return format_date(itinerary_start_time) if (itinerary_start_time)
    return format_date(itinerary_end_time) if (itinerary_end_time)
    return TranslationEngine.translate_text(:not_available)
  end

  def time_range_in_words
    case mode.code
    when 'mode_taxi'
      itinerary_start_time =get_itinerary_start_time(object)
      itinerary_end_time = get_itinerary_end_time(object)
      return format_time(itinerary_start_time) + ' ' + TranslationEngine.translate_text(:to) + ' ' + format_time(itinerary_end_time) if (itinerary_start_time && itinerary_end_time)
      return TranslationEngine.translate_text(:not_available)
    else
      return format_time(start_time) + ' ' + TranslationEngine.translate_text(:to) + ' ' + format_time(end_time) if (start_time && end_time)
      return TranslationEngine.translate_text(:not_available)
    end
  end

  def notes
    case mode.code
    when 'mode_transit', 'mode_car', 'mode_bicycle', 'mode_walk'
      TranslationEngine.translate_text(:no_str)
    when 'mode_taxi'
      TranslationEngine.translate_text(:yes_str)
    when 'mode_paratransit'
      # h.duration_to_words(service.advanced_notice_minutes*60, suppress_minutes: true, days_only: true)
      h.day_range_to_words(service.advanced_notice_minutes*60, service.max_advanced_book_minutes*60)
    when 'mode_rideshare'
      TranslationEngine.translate_text(:possible_rideshares, count: ride_count) + ' ' + TranslationEngine.translate_text(:view_details)
    else
      'None'
    end
  end

  def notes_label
    case mode.code
    when 'mode_rideshare'
      TranslationEngine.translate_text(:note)
    when 'mode_transit', 'mode_taxi', 'mode_paratransit', 'mode_car', 'mode_bicycle', 'mode_walk'
      TranslationEngine.translate_text(:book_ahead)
    else
      TranslationEngine.translate_text(:note)
    end
  end

  def walking_time
    h.duration_to_words(walk_time)
  end

  def transfers_in_words
    transfers || TranslationEngine.translate_text(:none)
  end


end
