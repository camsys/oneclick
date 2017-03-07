class UserMailer < ActionMailer::Base
  # Default sender account set in application.yml
  @@from = ENV["SYSTEM_SEND_FROM_ADDRESS"]
  include ItineraryHelper
  layout "user_mailer"
  helper :application, :trips, :services, :users, :map

  def user_trip_email(addresses, trip, comments, current_user = nil)
    @trip = trip
    @comments = comments
    @user = current_user
    subject = 'Your Trip Details'
    @itineraries = trip.selected_itineraries
    @itineraries.each do |itin|
      itin.map_image = create_static_map(itin)
      attachments.inline[itin.id.to_s + ".png"] = open(itin.map_image, 'rb').read
    end
    # Attach icons
    ["start.png", "stop.png"].each do |icon|
      attach_image(icon)
    end
    mail(to: addresses, subject: subject, from: @@from)
  end

  def ecolane_trip_email(addresses, traveler, trip_hash)
    @user = traveler
    @trip_hash = trip_hash
    subject = TranslationEngine.translate_text(
      :user_trip_email_subject,
      app_name: Oneclick::Application.config.name,
      trip_date: @trip_hash.first[:date]
    )
    mail(to: addresses, subject: subject, from: @@from)
  end

  def poi_upload_results(addresses, subject, messages)
    @messages = messages
    mail(to: addresses, subject: subject, from: @@from)
  end


  def booked_trip_update_email(addresses, trip, booking_service=nil)
    @trip = trip
    @booking_service = booking_service
    @itineraries = trip.selected_itineraries
    mail(to:addresses, subject: "User #{@trip.user.name} Booked a Trip in #{booking_service}", from: @@from)
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

  def user_itinerary_email(addresses, trip, itinerary, subject, comments, current_user = nil)
    @trip = trip
    @itinerary = itinerary
    @legs = @itinerary.get_legs
    @comments = comments
    @user = current_user

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

  private

  # Attaches an asset to the email based on its filename (including extension)
  def attach_image(filename)
    url = "#{Rails.root}/app/assets/images/#{filename}"
    puts "ATTACHING FILE: #{url}"
    attachments.inline[filename] = File.read(url)
  end

end
