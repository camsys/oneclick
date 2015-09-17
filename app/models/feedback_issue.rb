class FeedbackIssue < ActiveRecord::Base
  has_many :feedback_types, through: :feedback_issues_feedback_types
  has_many :feedbacks, through: :feedback_issues_feedbacks
end
