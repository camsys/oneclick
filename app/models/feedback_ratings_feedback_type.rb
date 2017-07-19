class FeedbackRatingsFeedbackType < ActiveRecord::Base
  belongs_to :feedback_type
  belongs_to :feedback_rating
end
