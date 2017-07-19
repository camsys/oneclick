class UserMessage < ActiveRecord::Base
  belongs_to :recipient, class_name: 'User'
  belongs_to :message

  validates :recipient, presence: true
  validates :message, presence: true

  def mark_as_read!
    update_attributes(read: true, read_at: DateTime.now)
  end

  def open
    update_attributes(last_displayed_at: DateTime.now)
  end
end
