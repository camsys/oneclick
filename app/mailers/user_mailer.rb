class UserMailer < ActionMailer::Base
  # Default sender account set in application.yml
  default from: ENV["SYSTEM_SEND_FROM_ADDRESS"]
  layout "user_mailer"
  helper :application, :trips, :services, :users, :map

  def user_trip_email(addresses, trip, subject, from, comments, current_user = nil)
    @trip = trip
    @from = from
    @comments = comments
    @user = current_user

    mail(to: addresses, subject: subject, from: @from, reply_to: @from)
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

  def user_itinerary_email(addresses, trip, itinerary, subject, from, comments, current_user = nil)
    @trip = trip
    @from = from
    @itinerary = itinerary
    @legs = @itinerary.get_legs
    @comments = comments
    @user = current_user

    mail(to: addresses, subject: subject, from: @from)
  end

  def buddy_request_email(to_email, from_traveler)
    @to_email = to_email
    @from_email = from_traveler.email
    @traveler = from_traveler
    mail(to: @to_email, subject: t(:one_click_buddy_request_from_from_email, from: @from_email))
  end

  def buddy_revoke_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, subject: t(:one_click_buddy_revoke_from_from_email, by: @from_email))
  end

  def traveler_confirmation_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, subject: t(:one_click_traveler_confirmation_from_from_email, by: @from_email))
  end

  def traveler_decline_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, subject: t(:one_click_traveler_decline_by_from_email, by: @from_email))
  end

  def traveler_revoke_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, subject: t(:one_click_traveler_revoke_by_from_email, by: @from_email))
  end

  def feedback_email(trip)
    @trip = trip
    # TODO localize
    mail(to: trip.user.email, subject: t(:rate_recent))
  end

  def agency_helping_email(to_email, from_email, agency)
    @agency = agency
    @to_email = to_email
    @from_email = from_email

    mail(to: @to_email, subject: t(:agency_now_assisting, agency: agency.name), from: @from_email)
  end

end
