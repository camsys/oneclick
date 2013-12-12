class UserMailer < ActionMailer::Base
  
  # Default sender account set in application.yml
  default from: ENV["SYSTEM_SEND_FROM_ADDRESS"]
  
  helper :application, :trips
  
  def user_trip_email(addresses, trip, subject, from)
    @trip = trip
    @from = from

    mail(to: addresses, subject: subject, from: @from)
  end

  def provider_trip_email(emails, trip, subject, from, comments)
    @trip = trip
    @from = from
    @comments = comments
    @type = "One Way Trip"
    @return = nil
    if @trip.outbound_part.selected_itinerary.service
      @service = @trip.outbound_part.selected_itinerary.service
      @provider = @service.provider
      @itinerary = @trip.outbound_part.selected_itinerary
      @trip_part = @trip.outbound_part
      if @trip.is_return_trip and @trip.return_part.selected_itinerary
        if @trip.return_part.selected_itinerary.service == @service
          @type = "Round Trip"
          @return = @trip.return_part.trip_time
        end
      end
    else
      @provider = @trip.return_part.selected_itinerary.service.provider
      @itinerary = @trip.return_part.selected_itinerary
      @trip_part = @trip.return_part
    end
    @traveler = trip.user
    addresses = [@provider.email]
    addresses << emails

    mail(to: addresses, subject: subject, from: @from)
  end

  def user_itinerary_email(addresses, trip, itinerary, subject, from)
    @trip = trip
    @from = from
    @itinerary = itinerary
    @legs = @itinerary.get_legs

    mail(to: addresses, subject: subject, from: @from)
  end

  def buddy_request_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    mail(to: @to_email, subject: t(:one_click_buddy_request_from_from_email, from_email: from_email))
  end

  def buddy_revoke_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    # TODO localize
    mail(to: @to_email, subject: "1-Click buddy request from #{@from_email}")
  end

  def traveler_confirmation_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    # TODO localize
    mail(to: @to_email, subject: "1-Click buddy request from #{@from_email}")
  end

  def traveler_decline_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    # TODO localize
    mail(to: @to_email, subject: "1-Click buddy request from #{@from_email}")
  end

  def traveler_revoke_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    # TODO localize
    mail(to: @to_email, subject: "1-Click buddy request from #{@from_email}")
  end

  def feedback_email(to_email, trip, from_email)
    @to_email = to_email
    @from_email = from_email
    @trip = trip

    # TODO localize
    mail(to: @to_email, from: @from_email, subject: "1-Click Feedback")
  end

end
