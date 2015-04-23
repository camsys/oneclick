require 'carrierwave/orm/activerecord'

class Provider < ActiveRecord::Base
  include Rateable
  include Commentable
  extend LocaleHelpers
  resourcify

  mount_uploader :logo, ProviderLogoUploader

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

  def self.form_collection include_all=true, provider_id=false
    relation = provider_id ? where(id: provider_id).order(:name) : order(:name)
    form_collection_from_relation include_all, relation, false, true
  end
  
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
      I18n.t(:status)
    ]
  end

  def to_csv
    [
      id,
      name,
      active ? '' : I18n.t(:inactive)
    ].to_csv
  end

  def self.get_exported(rel, params = {})
    if params[:bIncludeInactive] != 'true'
      rel = rel.where(active: true)
    end

    if !params[:search].blank?
      rel = rel.ransack({
        :id_or_name_cont => params[:search]
        }).result(:district => true)
    end

    rel
  end

end
