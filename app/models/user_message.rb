class UserMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user, presence: true
  validates :message, presence: true
end
