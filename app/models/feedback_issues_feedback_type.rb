class FeedbackIssuesFeedbackType < ActiveRecord::Base
  belongs_to :feedback_type
  belongs_to :feedback_issue
end
