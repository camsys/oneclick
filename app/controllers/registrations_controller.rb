# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def create
    session[:location] = new_user_registration_path
    super
  end
  
  def update
    session[:location] = edit_user_registration_path
    super
  end

  def edit
    @user_relationship = UserRelationship.new
    super    
  end

end 