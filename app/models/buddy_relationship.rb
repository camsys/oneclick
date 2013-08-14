class BuddyRelationship < ActiveRecord::Base

  before_save :check_for_user
  after_create :send_buddy_request_email

  validates :email_address, presence: true
  validates :email_address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }
  validates :email_address, uniqueness: {scope: :traveler_id, message: "You've already asked them to be a buddy." }
  validates_each :email_address do |record, attr, value|
    record.errors.add(attr, "You can't be your own buddy.") if value == record.traveler.email
  end
  attr_accessible :buddy_id, :status, :traveler_id, :email_address, :email_sent
  belongs_to :buddy, class_name: User
  belongs_to :traveler, class_name: User

  scope :pending, where(status: 'pending')
  scope :confirmed, where(status: 'confirmed')
  scope :not_declined, where("status != 'declined'")

  def pending?
    status == 'pending'
  end

  def confirmed?
    status == 'confirmed'
  end

  def accept
    self.update_attribute(:status, 'confirmed')
  end

  def decline
    self.update_attribute(:status, 'declined')
  end

  def associate_buddy user
    self.update_attribute(:buddy, user)  
  end

  private

  def check_for_user
    u = User.find_by_email(email_address)
    self.buddy = u unless u.nil?
  end

  def send_buddy_request_email
    UserMailer.buddy_request_email(email_address, traveler.email).deliver
    self.update_attribute(:email_sent, Time.now)
  end

end
