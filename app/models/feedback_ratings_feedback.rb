class FeedbackRatingsFeedback < ActiveRecord::Base
  belongs_to :feedback
  belongs_to :feedback_rating
end
