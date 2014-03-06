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
end