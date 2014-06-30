require 'active_support/concern'

module Rateable
  extend ActiveSupport::Concern

  included do
    has_many :ratings, as: :rateable
    accepts_nested_attributes_for :ratings
  end

  def get_avg_rating # if we need to build out a caching column, impose it here.
    calculate_rating
  end

  # Average rating for rateable.  Returns 0 if unrated
  def calculate_rating
    if self.ratings.approved.blank? # Short circuit out if rateable is unrated
      return 0
    end
    total = self.ratings.approved.pluck(:value).inject(:+)
    len = self.ratings.approved.length
    average = total.to_f / len # to_f so we don't get an integer result
  end

  def rate(user, value, comments=nil)
    Rails.logger.info "User: #{user.id}, rateable: #{self.class}-##{self.id}"
    rate = ratings.build.tap do |r|
      r.user = user # user creating the rating.  Can be traveler or agent
      r.value = value
      r.comments = comments
    end
    rate.save
    rate
  end
end