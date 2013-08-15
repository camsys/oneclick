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
    @delegate_relationship = UserRelationship.new
    @delegate_relationship.traveler = current_user
    @delegate_relationship.relationship_status = RelationshipStatus.find_by_name('pending')    
    @traveler_relationship = UserRelationship.new
    @traveler_relationship.delegate = current_user
    @traveler_relationship.relationship_status = RelationshipStatus.find_by_name('pending')    
    super    
  end

end 