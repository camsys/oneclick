module RelationshipsHelper
  def revokable
    relationship_status_id == RelationshipStatus::CONFIRMED
  end
  def retractable
    relationship_status_id == RelationshipStatus::REQUESTED || relationship_status_id == RelationshipStatus::PENDING
  end
  def acceptable
    relationship_status_id == RelationshipStatus::PENDING
  end
  def declinable
    relationship_status_id == RelationshipStatus::PENDING
  end
  def hidable
    relationship_status_id == RelationshipStatus::REVOKED || relationship_status_id == RelationshipStatus::DENIED
  end

  def active?
    relationship_status_id != RelationshipStatus::DENIED && relationship_status_id != RelationshipStatus::REVOKED && relationship_status_id != RelationshipStatus::HIDDEN 
  end

  # Test whether the requested action is legal on this relationship
  def permissible_action?(target_status)
    case target_status.to_i
    when RelationshipStatus::CONFIRMED
      self.acceptable
    when RelationshipStatus::REVOKED
      self.revokable
    when RelationshipStatus::DENIED
      self.declinable
    else
      false
    end
  end
end