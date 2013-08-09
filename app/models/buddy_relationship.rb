class BuddyRelationship < ActiveRecord::Base

  before_save :check_for_user
  after_create :send_buddy_request_email

  attr_accessible :buddy_id, :status, :traveler_id, :email_address
  belongs_to :buddy, class_name: User
  belongs_to :traveler, class_name: User

  scope :pending, where(status: 'pending')
  scope :confirmed, where(status: 'confirmed')

  def pending?
    status == 'pending'
  end

  def confirmed?
    status == 'confirmed'
  end

  def accept
    self.status = 'confirmed'
    save  
  end

  private

  def check_for_user
    u = User.find_by_email(email_address)
    self.buddy = u unless u.nil?
  end

  def send_buddy_request_email
    UserMailer.buddy_request_email(email_address, traveler.email).deliver
  end

end
