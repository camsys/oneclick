class Provider < ActiveRecord::Base
  include Rateable
  resourcify

  #associations
  has_many :users
  has_many :services
  has_many :ratings, through: :services

  has_many :cs_roles, -> {where(resource_type: 'Provider')}, class_name: 'Role',
        foreign_key: :resource_id
  has_many :staff, -> { where('roles.name=?', 'provider_staff') }, class_name: 'User',
        through: :cs_roles, source: :users
  
  include Validations
  before_validation :check_url_protocol
  validates :name, presence: true, length: { maximum: 128 }
  
  def internal_contact
    users.with_role( :internal_contact, self).first
  end

  def internal_contact= user
    former = internal_contact
    if !former.nil? && (user != former)
      former.remove_role :internal_contact, self
    end
    if !user.nil?
      users << user
      user.add_role :internal_contact, self
      self.save
    end
  end

  def get_attr(attribute_sym)
    return [attribute_sym, self.send(attribute_sym)]
  end

  def to_s
    name
  end

end
