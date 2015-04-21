class SidewalkObstruction < ActiveRecord::Base

  REJECTED= "rejected"
  PENDING= "pending"
  APPROVED = "approved"
  DELETED = "deleted"


  scope :approved, -> { where(status: SidewalkObstruction::APPROVED)}
  scope :pending, -> { where(status: SidewalkObstruction::PENDING)}
  scope :rejected, -> { where(status: SidewalkObstruction::REJECTED)}
  scope :deleted, -> { where(status: SidewalkObstruction::DELETED)}
  scope :non_deleted, -> { where.not(status: SidewalkObstruction::DELETED)}

  belongs_to :user

  # custom ransackers
  ransacker :user_name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
      [Arel::Nodes::NamedFunction.new('concat_ws',
        [' ', User.arel_table[:first_name], User.arel_table[:last_name]])])
  end

  ransacker :is_approved do
    Arel.sql("status = '#{APPROVED}'")
  end
  ransacker :is_rejected do
    Arel.sql("status = '#{REJECTED}'")
  end
  ransacker :is_deleted do
    Arel.sql("status = '#{DELETED}'")
  end
  ransacker :is_pending do
    Arel.sql("status = '#{PENDING}'")
  end

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