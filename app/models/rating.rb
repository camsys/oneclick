class Rating < ActiveRecord::Base
  MAXRATING = 5
  REJECTED= "rejected"
  PENDING= "pending"
  APPROVED = "approved"


  scope :approved, -> { where(status: Rating::APPROVED)}
  scope :pending, -> { where(status: Rating::PENDING)}
  scope :rejected, -> { where(status: Rating::REJECTED)}

  belongs_to :user
  belongs_to :rateable, :polymorphic => true
  validates :value, :presence => true # What if we allow users to just enter commments/feedback.  Don't require value.  Needs schema change

  def self.options
    options = []
    MAXRATING.downto(1).each do |n|
      options << [n, "#{n}-stars"]
    end
    options
  end

  def rateable_desc
    if rateable.class.name.eql? "Trip"
      "Trip"
    else
      rateable.to_s
    end
  end

  def approved?
    status == APPROVED
  end
  def pending?
    status == PENDING
  end
  def rejected?
    status == REJECTED
  end

end
