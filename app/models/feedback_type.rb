class FeedbackType < ActiveRecord::Base
  has_one :feedback
  has_many :feedback_ratings_feedback_types
  has_many :feedback_ratings, through: :feedback_ratings_feedback_types
  has_many :feedback_issues_feedback_types
  has_many :feedback_issues, through: :feedback_issues_feedback_types
end
