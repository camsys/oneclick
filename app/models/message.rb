class Message < ActiveRecord::Base
  has_many :user_messages
  has_many :recipients, class_name: 'User', through: :user_messages
  belongs_to :sender, class_name: 'User'

  validates :sender, presence: true
  validates :body, presence: true
end
