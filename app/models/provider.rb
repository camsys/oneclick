require 'carrierwave/orm/activerecord'

class Provider < ActiveRecord::Base
  include DisableCommented
  include Rateable
  include Commentable
  resourcify

  mount_uploader :logo, ProviderLogoUploader

  #Scopes
  scope :active, -> { where(active: true)}

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
    if include_all
      list = [[TranslationEngine.translate_text(:all), -1]]
    else
      list = []
    end
    inactive_label = " (#{TranslationEngine.translate_text(:inactive)})"
    relation.each do |r|
      name = TranslationEngine.translate_text(r.name) if TranslationEngine.translation_exists? r.name
      name ||= r.name
      name = name + inactive_label if !r.active
      list << [name, r.id]
    end
    list
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

  # Admin User virtual attribute
  def admin_user
    User.with_role( :provider_staff, self).first
  end

  def admin_user= user_email
    user = User.find_by_email(user_email)

    # Only update if valid email address was entered, if it's different from current user, and if that user is not already the provider somewhere
    if user && user != admin_user && !user.has_role?(:provider_staff, :any)

      # First, remove :provider_staff role from all users associated with this provider
      User.with_role(:provider_staff, self).each {|u| u.remove_role(:provider_staff, self)}

      # Then, give the user the provider_staff remove_role
      user.add_role(:provider_staff, self) if user
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
      TranslationEngine.translate_text(:id),
      TranslationEngine.translate_text(:name),
      TranslationEngine.translate_text(:status)
    ]
  end

  def to_csv
    [
      id,
      name,
      active ? '' : TranslationEngine.translate_text(:inactive)
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
