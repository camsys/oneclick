class UserMailer < ActionMailer::Base
  default from: "donotreply@julianjray.com"
  helper :application
  
  def user_trip_email(user, trip, subject)
    @user = user
    @trip = trip
    
    mail(to: @user.email, subject: subject)
  end

end
