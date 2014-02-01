class Organization < ActiveRecord::Base
  # include ActiveModel::Validations

  # # Validator(s)
  # class NoProviderHierarchyValidator < ActiveModel::EachValidator
  #   def validate_each(record, attribute, value)
  #     record.errors.add attribute, "provider organization cannot have parents" if record.provider? and !record.parent.nil?
  #   end
  # end
  # attr_accessible :parent
  # belongs_to :parent
  # validates :parent, no_provider_hierarchy: true

  TYPE_AGENCY = 0
  TYPE_PROVIDER = 1
  attr_accessible :name, :type

  validates :type, presence: true

  def agency?
    self.class == Agency
  end

  def provider?
    self.class == ProviderOrg
  end

end
