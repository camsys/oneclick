class FeedbackIssuesFeedback < ActiveRecord::Base
  belongs_to :feedback
  belongs_to :feedback_issue
end
