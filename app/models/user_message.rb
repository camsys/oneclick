class UserMessage < ActiveRecord::Base
  belongs_to :recipient, class_name: 'User'
  belongs_to :message

  validates :recipient, presence: true
  validates :message, presence: true

  def mark_as_read!
    update_attribute(:read, true)
  end
end
