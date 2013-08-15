class UserMailer < ActionMailer::Base
  default from: "donotreply@gmail.com"
  helper :application
  
  def user_trip_email(addresses, trip, subject, from)
    @trip = trip
    @from = from
    
    mail(to: addresses, subject: subject, from: @from)
  end

  def buddy_request_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    # TODO localize
    mail(to: @to_email, subject: "1-Click buddy request from #{@from_email}")
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

end
