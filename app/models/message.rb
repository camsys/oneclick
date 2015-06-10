class Message < ActiveRecord::Base
  has_many :user_messages
  has_many :recipients, class_name: 'User', through: :user_messages
  belongs_to :sender, class_name: 'User'

  validates :sender, presence: true
  validates :body, presence: true
  validate :check_date_range

  private

  def check_date_range
    if from_date && to_date && from_date > to_date
      errors.add(:delivery_date_range, TranslationEngine.translate_text(:from_date_not_later_than_to_date))
    end
  end
end
