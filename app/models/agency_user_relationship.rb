class AgencyUserRelationship < ActiveRecord::Base
  include RelationshipsHelper
  
  belongs_to :relationship_status #should make this a state machine eventually...
  belongs_to :user
  belongs_to :agency
  
  def confirm
    self.relationship_status = RelationshipStatus.confirmed
  end

  # A traveler revokes a  request
  def traveler_revoke
   self.relationship_status = RelationshipStatus.revoked
  end

  # A traveler hides an agency request.
  def traveler_hide
    self.relationship_status = RelationshipStatus.hidden
  end

  ##TODO Talk with Denis about what he wants this to be
  def agency_revoke
    self.relationship_status = RelationshipStatus.revoked
  end
end
