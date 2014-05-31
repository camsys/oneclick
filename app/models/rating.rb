class Rating < ActiveRecord::Base

  MAXRATING =  5

  belongs_to :user
  belongs_to :rateable, :polymorphic => true
  validates :value, :presence => true # What if we allow users to just enter commments/feedback.  Don't require value.  Needs schema change
  
  # attr_accessible :rate, :dimension
end
