class Feedback < ActiveRecord::Base
  include RatingsHelper

  belongs_to :user
  belongs_to :trip
  belongs_to :feedback_type
  belongs_to :feedback_status

  has_many :feedback_ratings_feedbacks
  has_many :feedback_ratings, through: :feedback_ratings_feedbacks
  has_many :feedback_issues_feedbacks
  has_many :feedback_issues, through: :feedback_issues_feedbacks

  validates :feedback_type, presence: true

  def ratings
    feedback_ratings_feedbacks
  end

  def rating_types
    feedback_ratings
  end

  def issues
    feedback_issues_feedbacks
  end

  def issue_types
    feedback_issues
  end

  def type
    feedback_type
  end

  def status
    feedback_status
  end
end
