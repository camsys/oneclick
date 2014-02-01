class Agency < Organization
  include ActiveModel::Validations

  # Validator(s)
  class NoProviderHierarchyValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute, "provider organization cannot have parents" if record.provider? and !record.parent.nil?
    end
  end
  attr_accessible :parent
  belongs_to :parent, class_name: 'Agency'
  has_many :sub_agencies, class_name: 'Agency', foreign_key: :parent_id
  validates :parent, no_provider_hierarchy: true

end
