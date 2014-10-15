class SidewalkObstruction < ActiveRecord::Base

  REJECTED= "rejected"
  PENDING= "pending"
  APPROVED = "approved"
  DELETED = "deleted"


  scope :approved, -> { where(status: SidewalkObstruction::APPROVED)}
  scope :pending, -> { where(status: SidewalkObstruction::PENDING)}
  scope :rejected, -> { where(status: SidewalkObstruction::REJECTED)}
  scope :deleted, -> { where(status: SidewalkObstruction::DELETED)}

  belongs_to :user

  def approved?
    status == APPROVED
  end
  def pending?
    status == PENDING
  end
  def rejected?
    status == REJECTED
  end
  def deleted?
    status == DELETED
  end
  def pending_and_active?
    status == PENDING and (removed_at.nil? or removed_at > Time.now)
  end

  def self.sidewalk_obstruction_on?
    Oneclick::Application.config.enable_sidewalk_obstruction
  end

end