class UserMailer < ActionMailer::Base
  default from: "donotreply@julianjray.com"
  helper :application
  
  def user_trip_email(addresses, trip, subject, from)
    @trip = trip
    @from = from
    
    mail(to: addresses, subject: subject, from: @from)
  end

  def buddy_request_email(to_email, from_email)
    @to_email = to_email
    @from_email = from_email
    
    mail(to: @to_email, subject: t(:one_click_buddy_request_from_from_email, from_email: from_email))
  end

end
