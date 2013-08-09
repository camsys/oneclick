class UserMailer < ActionMailer::Base
  default from: "donotreply@julianjray.com"
  helper :application
  
  def user_trip_email(user, trip, subject)
    @user = user
    @trip = trip
    
    mail(to: @user.email, subject: subject)
  end

  def buddy_request_email(to_email, from_email)
    puts "BEGIN buddy_request_email"
    @to_email = to_email
    @from_email = from_email
    
    # TODO localize
    m = mail(to: @to_email, subject: "1-Click buddy request from #{@from_email}")
    puts "END  buddy_request_email"
    m
  end

end
