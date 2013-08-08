# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def create
    session[:location] = new_user_registration_path
    super
  end
  
end 