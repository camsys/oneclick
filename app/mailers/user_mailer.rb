class UserMailer < ActionMailer::Base
  # Default sender account set in application.yml
  layout "user_mailer"
  helper :application, :trips, :services, :users, :map

  @@from = Oneclick::Application.config.email_sender
  @@trip_link = Oneclick::Application.config.email_trip_planner_url

  def user_trip_email(addresses, trip, subject, comments, current_user=nil)
    @trip = trip
    @comments = comments
    @user = current_user.nil? ? trip.user : current_user
    @trip_link = @@trip_link

    mail(to: addresses, subject: subject, from: @@from)
  end

  def provider_trip_email(emails, trip, subject, from, comments)
    @trip = trip
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

    mail(to: addresses, subject: subject, from: @@from)
  end

  def user_itinerary_email(addresses, itineraries, subject, comments, current_user = nil)
    @itineraries = itineraries
    @comments = comments
    @user = current_user
    @trip_link = @@trip_link

    mail(to: addresses, subject: subject, from: @@from)
  end

  def buddy_request_email(to_email, from_traveler)
    @to_email = to_email
    @traveler = from_traveler
    mail(to: @to_email, from: @@from, subject: TranslationEngine.translate_text(:one_click_buddy_request_from_from_email))
  end

  def buddy_revoke_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, from: @@from, subject: TranslationEngine.translate_text(:one_click_buddy_revoke_from_from_email))
  end

  def traveler_confirmation_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, from: @@from, subject: TranslationEngine.translate_text(:one_click_traveler_confirmation_from_from_email))
  end

  def traveler_decline_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, from: @@from, subject: TranslationEngine.translate_text(:one_click_traveler_decline_by_from_email))
  end

  def traveler_revoke_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email

    # TODO localize
    mail(to: @to_email, from: @@from, subject: TranslationEngine.translate_text(:one_click_traveler_revoke_by_from_email))
  end

  def feedback_email(trip)
    @trip = trip
    # TODO localize
    mail(to: trip.user.email, from: @@from, subject: TranslationEngine.translate_text(:rate_recent))
  end

  def agency_helping_email(to_email, from_email, agency)
    @agency = agency
    @to_email = to_email
    @from_email = from_email

    mail(to: @to_email, from: @@from, subject: TranslationEngine.translate_text(:agency_now_assisting, agency: agency.name))
  end

  def landmarks_failed_email(emails, message, row)
    emails.each do |email|
      @message = message
      @row = row
      mail(to: email, from: @@from, subject: 'Landmarks Upload Failed')
    end
  end

  def landmarks_succeeded_email(emails, non_geocoded_pois)
    @non_geocoded_pois = non_geocoded_pois
    emails.each do |email|
      mail(to: email, from: @@from, subject: 'Landmarks Upload Succeeded')
    end
  end

  def stops_failed_email(emails)
    emails.each do |email|
      mail(to: email, from: @@from, subject: 'Stops Upload Failed')
    end
  end

  def stops_succeeded_email(emails, ungeocoded)
    @ungeocoded = ungeocoded
    emails.each do |email|
      mail(to: email, from: @@from, subject: 'Stops Upload Succeeded')
    end
  end

  def synonyms_failed_email(emails, message, row)
    emails.each do |email|
      @message = message
      @row = row
      mail(to: email, from: @@from, subject: 'Synonyms Upload Failed')
    end
  end

  def synonyms_succeeded_email(emails)
    emails.each do |email|
      mail(to: email, from: @@from, subject: 'Synonyms Upload Succeeded')
    end
  end

end
