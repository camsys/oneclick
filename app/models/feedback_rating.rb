class FeedbackRating < ActiveRecord::Base
  has_many :feedback_ratings_feedback_types
  has_many :feedback_types, through: :feedback_ratings_feedback_types
  has_many :feedback_ratings_feedbacks
  has_many :feedbacks, through: :feedback_ratings_feedbacks

  MAXRATING = 5

  def self.options
    options = []
    MAXRATING.downto(0).each do |n|
      options << [n, "#{n}-stars"]
    end
    options
  end
end
