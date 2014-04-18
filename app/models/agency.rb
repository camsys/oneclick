class Agency < ActiveRecord::Base
  resourcify
  # include ActiveModel::Validations

  # # Validator(s)
  # class NoProviderHierarchyValidator < ActiveModel::EachValidator
  #   def validate_each(record, attribute, value)
  #     record.errors.add attribute, "provider organization cannot have parents" if record.provider? and !record.parent.nil?
  #   end
  # end
  # attr_accessible :parent
  # validates :parent, no_provider_hierarchy: true
  belongs_to :parent, class_name: 'Agency'
  has_many :sub_agencies, -> {order('name')}, class_name: 'Agency', foreign_key: :parent_id
  has_many :users
  has_many :agency_user_relationships
  has_many :customers, :class_name => 'User', :through => :agency_user_relationships, source: :user

  def unselected_users
    User.registered - self.users
  end

  def possible_parents
    Agency.all - [self]
  end

  def name_and_id
    [name, id]
  end

  def self.names_and_ids
    Agency.all.map(&:name_and_id)
  end

end
