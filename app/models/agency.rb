class Agency < ActiveRecord::Base
  include Rateable # mixin to handle all rating methods
  include Commentable
  extend LocaleHelpers
  resourcify

  belongs_to :parent, class_name: 'Agency'
  has_many :sub_agencies, -> {order('name')}, class_name: 'Agency', foreign_key: :parent_id
  has_many :users
  has_many :agency_user_relationships
  has_many :approved_agency_user_relationships,-> { where(relationship_status: RelationshipStatus.confirmed) }, class_name: 'AgencyUserRelationship'
  has_many :customers, :class_name => 'User', :through => :approved_agency_user_relationships, source: :user
  # has_many :cs_roles, -> {where(resource_type: 'Agency')}, class_name: 'Role'
  has_many :cs_roles, -> {where(resource_type: 'Agency')}, class_name: 'Role', foreign_key: :resource_id
  has_many :cs_users, class_name: 'User', through: :cs_roles, source: :users
  has_many :agents, -> {where('roles.name=?', 'agent')}, class_name: 'User', through: :cs_roles, source: :users
  has_many :administrators, -> {where('roles.name=?', 'agency_administrator')}, class_name: 'User', through: :cs_roles, source: :users
  has_many :traveler_notes

  accepts_nested_attributes_for :users

  scope :active, -> { where(active: true)}

  validates :name, :presence => true

  def self.form_collection include_all=true, agency_id=false
    relation = agency_id ? where(id: agency_id).order(:name) : order(:name)

    form_collection_from_relation include_all, relation, false, true
  end

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

  def internal_contact
    users.with_role( :internal_contact, self).first
  end

  def internal_contact=(user)
    self.internal_contact.remove_role( :internal_contact, self) if self.internal_contact.present?
    user.add_role(:internal_contact, self)
  end

  def agency_id
    id
  end

  def to_s
    name
  end

  # csv export
  ransacker :id do
    Arel.sql(
      "regexp_replace(
        to_char(\"#{table_name}\".\"id\", '9999999'), ' ', '', 'g')"
    )
  end

  def self.csv_headers
    [
      I18n.t(:id),
      I18n.t(:name),
      I18n.t(:parent_agency),
      I18n.t(:subagencies),
      I18n.t(:status)
    ]
  end

  def to_csv
    [
      id,
      name,
      parent ? parent.name : '',
      sub_agencies.pluck(:name).join(';'),
      active ? '' : I18n.t(:inactive)
    ].to_csv
  end

  def self.get_exported(rel, params = {})
    if params[:bIncludeInactive] != 'true'
      rel = rel.where(active: true)
    end

    if !params[:search].blank?
      rel = rel.ransack({
        :id_or_name_or_parent_name_or_sub_agencies_name_cont => params[:search]
        }).result(:district => true)
    end

    rel
  end

end
