class Rating < ActiveRecord::Base
  MAXRATING = 5

  scope :approved, -> { where(approved: true)}
  scope :unapproved, -> { where(approved: false)}
  belongs_to :rateable
  def self.options
    # [[5,5],[4,4],[3,3],[2,2],[1,1]] # Required for ratings/_form.html.haml
    options = []
    MAXRATING.downto(1).each do |n|
      options << [n, "#{n}-stars"]
    end
    options
  end

  belongs_to :user
  belongs_to :rateable, :polymorphic => true
  validates :value, :presence => true # What if we allow users to just enter commments/feedback.  Don't require value.  Needs schema change
  
  # attr_accessible :rate, :dimension
end
