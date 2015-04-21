class Rating < ActiveRecord::Base
  MAXRATING = 5
  DID_NOT_TAKE = -1
  REJECTED= "rejected"
  PENDING= "pending"
  APPROVED = "approved"


  scope :approved, -> { where(status: Rating::APPROVED)}
  scope :pending, -> { where(status: Rating::PENDING)}
  scope :rejected, -> { where(status: Rating::REJECTED)}

  belongs_to :user
  belongs_to :rateable, :polymorphic => true
  validates :value, :presence => true # What if we allow users to just enter commments/feedback.  Don't require value.  Needs schema change

  # custom ransackers
  ransacker :id do
    Arel.sql(
      "regexp_replace(
        to_char(\"#{table_name}\".\"id\", '9999999'), ' ', '', 'g')"
    )
  end
  
  ransacker :user_name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
      [Arel::Nodes::NamedFunction.new('concat_ws',
        [' ', User.arel_table[:first_name], User.arel_table[:last_name]])])
  end

  ransacker :is_approved do
    Arel.sql("status = '#{APPROVED}'")
  end
  ransacker :is_rejected do
    Arel.sql("status = '#{REJECTED}'")
  end
  ransacker :is_pending do
    Arel.sql("status = '#{PENDING}'")
  end

  def self.feedback_on?
    Oneclick::Application.config.enable_feedback
  end
  def self.agent_read_feedback?
    Oneclick::Application.config.agent_read_feedback
  end
  def self.provider_read_feedback?
    Oneclick::Application.config.provider_read_all_feedback
  end
  def self.traveler_read_all_organization_feedback?
    Oneclick::Application.config.traveler_read_all_organization_feedback
  end
  def self.tripless_feedback?
    Oneclick::Application.config.tripless_feedback
  end

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

  def context

  end

end
