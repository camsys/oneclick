class FareHelper
  include ActionView::Helpers::NumberHelper

  #Check to see if we should calculate the fare locally or use a third-party service.
  def calculate_fare(itinerary)
    #Check to see if this user is registered to book directly with this service
    service = Service.find(itinerary['service_id'])
    up = UserService.where(user_profile: itinerary.trip_part.trip.user.user_profile, service: itinerary.service)

    if up.count > 0 and Oneclick::Application.config.get_fares_from_ecolane
        Rails.logger.info("Getting fare from Ecolane")
      return query_fare(itinerary)
    elsif not service.fare_user.nil? and Oneclick::Application.config.get_fares_from_ecolane
      Rails.logger.info("Getting fare from Ecolane for guest user.")
      return query_guest_fare(itinerary)
    else
      Rails.logger.info("Calculating fare.")
      return calculate_paratransit_fare itinerary
    end
  end


  #Get the fare from a third-party source (e.g., a booking agent.)
  def query_fare(itinerary)
    case itinerary.service.booking_service_code
    when 'ecolane'
      eh = EcolaneHelpers.new
      result, my_fare =  eh.query_fare(itinerary)
      if result
        itinerary.cost = my_fare
      end

      itinerary.save
    end
  end

  def query_guest_fare(itinerary)

    #Get the official fare for this itinerary
    eh = EcolaneHelpers.new
    itinerary.cost = nil

    #Get an array of potential discounts
    itinerary.discounts = eh.build_discount_array(itinerary).to_json

    itinerary.save
  end


  #Allows a global multiplier for fixed-route fare if a travler's age is greater than config.discount_fare_age AND config.discount_fare_active is true
  def calculate_fixed_route_fare(trip_part, itinerary)

    #Check for multipliers
    if Oneclick::Application.config.discount_fare_active and trip_part.trip.user.age and trip_part.trip.user.age > Oneclick::Application.config.discount_fare_age
      if itinerary.cost
        itinerary.cost *= Oneclick::Application.config.discount_fare_multiplier
        itinerary.save
      end
    end

    #Check for comments.
    begin
      base_fare_structure = itinerary.service.fare_structures.first rescue nil
      if base_fare_structure
        itinerary.cost_comments = base_fare_structure.public_comments.for_locale.try(:comment)
        itinerary.save
      end
    rescue
      return
    end

  end

  # if itinerary belongs to a service that has cost comments, then get it
  # otherwise, use Itinerary#cost_comments
  def get_itinerary_cost_comments itinerary
    base_fare_structure = itinerary.service.fare_structures.first rescue nil
    if base_fare_structure
      base_fare_structure.public_comments.for_locale.try(:comment)
    else
      itinerary.cost_comments
    end
  end

  def calculate_paratransit_fare(itinerary, skip_calculation = false)

    estimated = false
    price_formatted = nil
    cost_in_words = ''
    comments = ''
    fare = nil

    fare = itinerary.cost
    fare_structure = itinerary.service.fare_structures.first rescue nil
    trip_part = itinerary.trip_part

    if fare_structure
      case fare_structure.fare_type
      when FareStructure::FLAT
        flat_fare = fare_structure.flat_fare
        if !skip_calculation
          fare = fare_structure.flat_fare_number
        end

        if fare
          fare = fare.to_f
          price_formatted = number_to_currency(fare)
          cost_in_words = price_formatted

          if flat_fare.round_trip_rate
            price_formatted +=  '*'
            comments = "#{TranslationEngine.translate_text(:one_way_rate)}: #{number_to_currency(flat_fare.one_way_rate)}; #{TranslationEngine.translate_text(:round_trip_rate)}: #{number_to_currency(flat_fare.round_trip_rate)}"
          end
        end

      when FareStructure::MILEAGE
        mileage_fare = fare_structure.mileage_fare
        estimated = true
        if !skip_calculation
          fare = fare_structure.mileage_fare_number(trip_part)
        end

        if fare
          if mileage_fare.mileage_rate
            comments = "#{TranslationEngine.translate_text(:base_rate)}: #{number_to_currency(mileage_fare.base_rate)}; #{number_to_currency(mileage_fare.mileage_rate)}/mile - " + TranslationEngine.translate_text(:cost_estimated)
          else
            comments = TranslationEngine.translate_text(:mileage_rate_unavailable)
          end

          price_formatted = "#{number_to_currency(fare.ceil)}*"
          cost_in_words = "#{number_to_currency(fare.ceil)} #{TranslationEngine.translate_text(:est)}"
        end
      when FareStructure::ZONE
        if !skip_calculation
          fare = fare_structure.zone_fare_number(trip_part)
          price_formatted = number_to_currency(fare) if fare 
        end
      end
    end

    if price_formatted.nil? && fare.nil?
      estimated = true
      price_formatted = '*'
      comments = TranslationEngine.translate_text(:see_details_for_cost)
      cost_in_words = TranslationEngine.translate_text(:unknown)
    else
      if !skip_calculation
        itinerary.cost = fare
      end
    end

    {
      estimated: estimated,
      fare: fare,
      price_formatted: price_formatted,
      cost_in_words: cost_in_words,
      comments: comments
    }
  end

  def get_itinerary_cost itinerary
    estimated = false
    fare =  itinerary.cost || (itinerary.service.fare_structures.first rescue nil)
    price_formatted = nil
    cost_in_words = ''
    comments = ''
    is_paratransit = itinerary.service.is_paratransit? rescue false

    if is_paratransit
      para_fare = calculate_paratransit_fare itinerary, itinerary.cost
      if para_fare
        estimated = para_fare[:estimated]
        fare = para_fare[:fare]
        price_formatted = para_fare[:price_formatted]
        cost_in_words = para_fare[:cost_in_words]
        comments = para_fare[:comments]
      end
    else
      if fare.respond_to? :fare_type
        case fare.fare_type
        when FareStructure::FLAT
          if fare.base and fare.rate
            estimated = true
            comments = "+#{number_to_currency(fare.rate)}/mile - " + TranslationEngine.translate_text(:cost_estimated)
            fare = fare.base.to_f
            price_formatted = number_to_currency(fare.ceil) + '*'
            cost_in_words = number_to_currency(fare.ceil) + TranslationEngine.translate_text(:est)
          elsif fare.base
            fare = fare.base.to_f
            price_formatted = number_to_currency(fare)
            cost_in_words = price_formatted
          else
            fare = nil
          end
        when FareStructure::MILEAGE
            if fare.base
              estimated = true
              comments = "+#{number_to_currency(fare.rate)}/mile - " + TranslationEngine.translate_text(:cost_estimated)
              fare = fare.base.to_f
              price_formatted = number_to_currency(fare.ceil) + '*'
              cost_in_words = number_to_currency(fare.ceil) + TranslationEngine.translate_text(:est)
            else
              fare = nil
            end
        when FareStructure::COMPLEX
          fare = nil
          estimated = true
          price_formatted = '*'
          comments = TranslationEngine.translate_text(:see_details_for_cost)
          cost_in_words = TranslationEngine.translate_text(:see_below)
        end
      else
        if itinerary.is_walk or itinerary.is_bicycle #TODO: walk, bicycle currently are put in transit category
          Rails.logger.info 'is walk or bicycle, so no charge'
          fare = 0
          price_formatted = TranslationEngine.translate_text(:no_charge)
          cost_in_words = price_formatted
        else
          case itinerary.mode
          when Mode.taxi
            if fare
              fare = fare.ceil
              estimated = true
              price_formatted = number_to_currency(fare) + '*'
              comments = TranslationEngine.translate_text(:cost_estimated)
              cost_in_words = number_to_currency(fare) + TranslationEngine.translate_text(:est)
            end
          when Mode.rideshare
            fare = nil
            estimated = true
            price_formatted = '*'
            comments = TranslationEngine.translate_text(:see_details_for_cost)
            cost_in_words = TranslationEngine.translate_text(:see_below)
          end
        end
      end
    end

    if price_formatted.nil?
      unless fare.nil?
        fare = fare.to_f
        if fare == 0
          Rails.logger.info 'no charge as fare is 0'
          price_formatted = TranslationEngine.translate_text(:no_charge)
          cost_in_words = price_formatted
        else
          price_formatted = number_to_currency(fare)
          cost_in_words = number_to_currency(fare)
        end
      else
        estimated = true
        price_formatted = '*'
        comments = TranslationEngine.translate_text(:see_details_for_cost)
        cost_in_words = TranslationEngine.translate_text(:unknown)
      end
    end

    # save calculated fare
    if !estimated && fare && itinerary.cost != fare
      itinerary.update_attributes(cost: fare)
    end

    return {price: fare, comments: comments, price_formatted: price_formatted, estimated: estimated, cost_in_words: cost_in_words}
  end
end