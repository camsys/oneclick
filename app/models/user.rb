class User < ActiveRecord::Base
  include DisableCommented
  include ActiveModel::Validations

  # enable roles for this model
  rolify

  # See https://github.com/gonzalo-bulnes/simple_token_authentication
  acts_as_token_authenticatable

  # devise configuration
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Updatable attributes
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :first_name, :last_name, :prefix, :suffix, :nickname
  # attr_accessible :role_ids

  # Associations
  has_many :places, -> {where active: true} # 0 or more places, only active places are available
  has_many :trips                   # 0 or more trips
  has_many :multi_o_d_trips
  has_many :trip_places, :through => :trips
  has_one  :user_profile            # 1 user profile
  has_many :user_mode_preferences   # 0 or more user mode preferences
  has_many :preferred_modes, through: :user_mode_preferences, class_name: 'Mode', source: :mode
  has_many :user_roles
  has_many :roles, :through => :user_roles # one or more user roles
  has_many :trip_parts, :through => :trips
  has_many :traveler_notes

  # relationships
  has_many :traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :confirmed_traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :travelers, :class_name => 'User', :through => :traveler_relationships
  has_many :confirmed_travelers, :class_name => 'User', :through => :confirmed_traveler_relationships

  has_many :delegate_relationships, :class_name => 'UserRelationship', :foreign_key => :user_id
  has_many :delegates, :class_name => 'User', :through => :delegate_relationships
  has_many :pending_and_confirmed_delegates, -> { where "user_relationships.relationship_status_id = ? OR user_relationships.relationship_status_id = ?", RelationshipStatus.confirmed, RelationshipStatus.pending },
    :class_name => 'User', :through => :delegate_relationships, :source => :delegate
  has_many :confirmed_delegates, -> { where "user_relationships.relationship_status_id = ?", RelationshipStatus.confirmed }, :class_name => 'User', :through => :delegate_relationships, :source => :delegate

  has_many :agency_user_relationships, foreign_key: :user_id
  accepts_nested_attributes_for :agency_user_relationships
  has_many :approved_agencies,-> { where "agency_user_relationships.relationship_status_id = ?", RelationshipStatus.confirmed }, class_name: 'Agency', :through => :agency_user_relationships, source: :agency #Scope to only include approved relationships
  accepts_nested_attributes_for :approved_agencies

  # All User Relationships, including revoked, pending, and confirmed.  #TODO Is this a dupe of delegate_relationships?
  has_many :buddy_relationships, class_name: 'UserRelationship', foreign_key: :user_id
  accepts_nested_attributes_for :buddy_relationships
  has_many :buddies, class_name: 'User', through: :buddy_relationships, source: :delegate

  has_many :user_characteristics, through: :user_profile
  accepts_nested_attributes_for :user_characteristics
  has_many :characteristics, through: :user_characteristics

  has_many :user_accommodations, through: :user_profile
  accepts_nested_attributes_for :user_accommodations
  has_many :accommodations, through: :user_accommodations

  has_many :received_messages, class_name: 'UserMessage', foreign_key: 'recipient_id'
  has_many :messages, through: :received_messages
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'

  belongs_to :agency
  belongs_to :provider
  belongs_to :walking_speed
  belongs_to :walking_maximum_distance
  has_and_belongs_to_many :services

  has_many :ratings # ratings created by the user, not ratings of the user

  scope :confirmed, -> {where('relationship_status_id = ?', RelationshipStatus::CONFIRMED)}
  scope :registered, -> {with_role(:registered_traveler)}
  scope :visitor, -> {without_role(:registered_traveler)}
  # scope :buddyable, -> User.where.not(id: User.with_role(:anonymous_traveler).pluck(users: :id))
  scope :any_role, -> {joins(:roles)}

  # find all users which do not have the role passed in.  Need uniq because user could have multiple roles, i.e. multiple rows in user_roles table
  scope :without_role, ->(role_name) { joins(:user_roles).joins(:roles).where.not(roles: {name: role_name}).uniq }

  scope :created_after, lambda {|from_day| where("users.created_at >= ?", from_day.at_beginning_of_day) }
  scope :created_before, lambda {|to_day| where("users.created_at <= ?", to_day.at_end_of_day) }
  scope :created_between, lambda {|from_day, to_day| created_after(from_day).created_before(to_day) }
  scope :active_between, lambda {|from_day, to_day| where("users.current_sign_in_at >= ? AND users.current_sign_in_at <= ?", from_day.at_beginning_of_day, to_day.at_end_of_day) }

  # Validations
  validates :email, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :maximum_wait_time, :numericality => { :greater_than_or_equal_to => 0}, if: :maximum_wait_time?

  before_create :make_user_profile

  def self.agent_form_collection include_all=true, agency=:any
    relation = with_role(:agent, agency).order(:first_name)
    if include_all
      list = [[TranslationEngine.translate_text(:all), -1]]
    else
      list = []
    end
    relation.each do |r|
      name = TranslationEngine.translate_text(r.name) if TranslationEngine.translation_exists? r.name
      name ||= r.name
      list << [name, r.id]
    end
    list
  end

  def make_user_profile
    create_user_profile
  end

  def to_s
    name
  end

  def name
    elems = []
    elems << prefix unless prefix.blank?
    elems << first_name unless first_name.blank?
    elems << last_name unless last_name.blank?
    elems << suffix unless suffix.blank?
    elems.compact.join(' ')
  end

  def welcome
    return nickname unless nickname.blank?
    return first_name unless first_name.blank?
    email
  end

  def has_disability?
    disabled = Characteristic.find_by_code('disabled')
    return false if disabled.nil?
    disability_status = self.user_profile.user_characteristics.where(characteristic_id: disabled.id)
    disability_status.count > 0 and disability_status.first.value == 'true'
  end

  def requires_wheelchair_access?
    wheelchair_accoms = user_profile.user_accommodations
        .includes(:accommodation).references(:accommodation)
        .where(
          accommodations:
            { code: ['folding_wheelchair_accessible', 'motorized_wheelchair_accessible'] },
          value: 'true')

    !wheelchair_accoms.empty?
  end

  def has_vehicle?
    has_trans = Characteristic.find_by(code: 'no_trans')
    return false if has_trans.nil?
    status = self.user_profile.user_characteristics.where(characteristic: has_trans)
    status.count > 0 and status.first.value == 'true'
  end

  def home
    self.places.where(home: true).first
  end

  def clear_home
    old_homes = self.places.where(home: true)
    old_homes.each do |old_home|
      old_home.home = false
      old_home.save()
    end
  end

  # TODO Should be in decorator
  def email_and_agency
    agency.nil? ? email : "#{email} (#{agency.name})"
  end

  def is_visitor?
    has_role? :anonymous_traveler
  end

  def is_api_guest?
    self == User.find_by(api_guest: true)
  end

  def is_registered?
    !is_visitor?
  end

  def can_book?
    unless self.user_profile.services.empty?
      return true
    end
    false
  end

  def associate_service(service, external_user_id, external_user_password)
    return service.associate_user(self, external_user_id, external_user_password)
  end

  def is_staff? #If this user has any role beyond traveler, then return true
    if self.roles.where.not(name: ["registered_traveler", "anonymous_traveler"]).count > 0
      return true
    else
      return false
    end
  end

  def max_wait_time
    if !maximum_wait_time
      default_max_wait_time = Oneclick::Application.config.default_max_wait_time
      return default_max_wait_time if default_max_wait_time
    end

    maximum_wait_time
  end

  # Union to get unique users with any relationship to current user
  def related_users
    delegates | travelers
  end

  def can_assist_target?(user)
    self.travelers.include? user
  end

  def can_be_assisted_by_target?(user)
    self.confirmed_delegates.include? user
  end

  #List of users who can be assigned to staff for an agency or provider
  def self.staff_assignable
    User.without_role(:anonymous_traveler).where(deleted_at: nil).order(first_name: :asc)
  end

  def update_relationships id_hash
    if id_hash
      id_hash.each do |rel_id, rel_status|
        UserRelationship.find(rel_id).update_attributes(relationship_status_id: rel_status)
      end
    end
  end

  def add_buddies emails
    unless emails.nil?
      request_message = create_buddy_request_message
      emails.each do |email|
        rel = UserRelationship.find_or_create_by(user_id: self.id, delegate_id: User.find_by(email: email).id) do |ur|
          ur.relationship_status_id = RelationshipStatus::PENDING
        end
        request_message.recipients << rel.delegate
      UserMailer.buddy_request_email(rel.delegate.email, rel.traveler).deliver
      end
      request_message.save rescue nil
    end
  end

  def create_buddy_request_message
    Message.create(sender: self, body: TranslationEngine.translate_text(:buddy_request_message, requester: name || email))
  end

  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def active_for_authentication?
    super && !deleted_at
  end

  def undelete
    update_attribute(:deleted_at, nil)
  end

  def unread_received_messages
    received_messages.where(read: false)
      .joins(:message).where('messages.from_date is ? or messages.from_date <= ?',nil,DateTime.now)
      .where('messages.to_date is ? or messages.to_date >= ?',nil,DateTime.now)
  end

  def future_trips
    bs = BookingServices.new

    # If this is an ecolane user, get trips from Ecolane, otherwise, get all the trips from 1-Click
    if self.ecolane_user?

      #Get Paratransit Trips that have Been Booked
      # This gets all trips, even thouse that were not booked through 1-click
      trips_array = bs.future_trips self
      trips_array = bs.group_trips trips_array

      #Get all future NON-Paratransit Trips that have been booked/selected
      self.trips.future_not_paratransit.each do |trip|
        trips_array << bs.build_api_trip_hash_from_non_paratransit_trip(trip)
      end

      #Sort all of these trips by date
      return trips_array.sort_by{ |trip| trip[0][:departure]}
    else
      trips_array  = []
      #Get all future NON-Paratransit Trips that have been booked/selected
      self.trips.future.selected.each do |trip|
        trips_array << bs.build_api_trip_hash_from_non_paratransit_trip(trip)
      end

      #Sort all of these trips by date
      if trips_array.count > 0
        trips_array = trips_array.reject { |trip| trip.nil? }
        trips_array = trips_array.reject { |trip| trip[0].nil? }
        return trips_array.sort_by{ |trip| trip[0][:departure]}
      else
        return []
      end
    end

  end

  def past_trips max_results = 10
    bs = BookingServices.new

    if self.ecolane_user?

      #Get Paratransit Trips that have Been Booked
      # This gets all trips, even thouse that were not booked through 1-click
      trips_array = bs.past_trips(self, max_results)

      trips_array = bs.group_trips trips_array
      #Get past NON-Paratransit Trips that have been booked/selected

      self.trips.during_not_paratransit.each do |trip|
        trips_array << bs.build_api_trip_hash_from_non_paratransit_trip(trip)
      end

      #Sort all of these trips by date
      if trips_array.count > 0
        trips_array = trips_array.sort_by{ |trip| trip[0][:departure]}.reverse
        return trips_array[0..max_results-1]
      else
        return []
      end
    else

      trips_array = []

      self.trips.during.each do |trip|
        trips_array << bs.build_api_trip_hash_from_non_paratransit_trip(trip)
      end

      #Sort all of these trips by date
      if trips_array.count > 0
        trips_array = trips_array.reject { |trip| trip.nil? }
        trips_array = trips_array.reject { |trip| trip[0].nil? }
        trips_array = trips_array.sort_by{ |trip| trip[0][:departure]}.reverse
        return trips_array[0..max_results-1]
      else
        return []
      end
    end
  end

  def clear_stale_answers
    self.user_characteristics.each do |user_characteristic|
      if user_characteristic.characteristic.nil?
        user_characteristic.delete
      end
      unless user_characteristic.fresh?
        user_characteristic.delete
      end
    end
  end

  # Return 4 most recent trip places.
  def recent_places count=20
    self.trip_places.order(created_at: :desc).to_a.uniq(&:address1)[0..(count-1)]
  end

  # Used by API call to update characteristics and accommodations from a hash
  def update_profile params

    if params[:attributes]
      update_attributes params[:attributes]
    end

    if params[:characteristics]
      update_user_characteristics params[:characteristics]
    end

    if params[:accommodations]
      update_user_accommodations params[:accommodations]
    end

    if params[:preferred_modes]
      update_preferred_modes params[:preferred_modes]
    end

    if params[:lang]
      self.preferred_locale = params[:lang]
      self.save
    end

    if params[:password]
      self.password = params[:password]
      self.password_confirmation = params[:password_confirmation]
      self.save
    end

  end

  def update_attributes params
    params.each do |key, value|
      case key.to_sym
        when :first_name
          self.first_name = value
        when :last_name
          self.last_name = value
        when :email
          self.email = value
        when :walking_speed
          walking_speed = WalkingSpeed.find_by(code: walk_speed_to_code(value))
          self.walking_speed = walking_speed
        when :walking_distance
          walking_maximum_distance = WalkingMaximumDistance.find_by(value: value.to_f)
          self.walking_maximum_distance = walking_maximum_distance
        when :ecolane_id
          self.user_profile.user_services.each do |user_service|
            user_service.external_user_id = value.to_s
            user_service.save
          end
      end
    end

    self.save

  end

  def update_user_characteristics params
    params.each do |key,value|
      characteristic = Characteristic.find_by(code: key)
      if characteristic
        user_characteristic = self.user_characteristics.where(user_profile: self.user_profile, characteristic: characteristic).first_or_initialize
        user_characteristic.value = value
        user_characteristic.save
      end
    end
  end

  def update_user_accommodations params
    params.each do |key,value|
      accommodation = Accommodation.find_by(code: key)
      if accommodation
        user_accommodation = self.user_accommodations.where(user_profile: self.user_profile, accommodation: accommodation).first_or_initialize
        user_accommodation.value = value.to_s
        user_accommodation.save
      end
    end
  end

  def update_preferred_modes params
    self.user_mode_preferences.destroy_all
    params.each do |p|
      mode = Mode.unscoped.find_by(code: p)
      if mode.nil?
        next
      end
      UserModePreference.where(user: self, mode: mode).first_or_create!
    end
  end

  def characteristics_hash
    self.user_characteristics.collect{ |c| {name: TranslationEngine.translate_text(c.characteristic.name), code: c.characteristic.code, note: TranslationEngine.translate_text(c.characteristic.note), value: c.value}}
  end

  def accommodations_hash
    self.user_accommodations.collect{ |a| {name: TranslationEngine.translate_text(a.accommodation.name), code: a.accommodation.code, note: TranslationEngine.translate_text(a.accommodation.note), value: (a.value == "true")}}
  end

  def preferred_modes_hash
    self.preferred_modes.collect{ |m| m.code}
  end

  def walk_speed_to_code(walk_speed)
    walk_speed = walk_speed.downcase.strip.to_sym
    walk_speed_hash = {slow: "slow", average: "average", medium: "average", fast:"fast"}
    return walk_speed_hash[walk_speed]
  end

  def update_age(dob) #Takes DOB string in mm/dd/yyyy format

    dob = dob.split('/')
    unless dob.count == 3
      return nil
    end

    begin
      dob = (dob[1] + '/' + dob[0] + '/' + dob[2]).to_time
    rescue  ArgumentError
      return nil
    end

    now = Time.now

    self.age = (now.year - dob.year - (dob.to_date.change(:year => now.year) > now ? 1 : 0)).to_s
    self.save

  end

  def ecolane_user?
    self.user_profile.user_services.each do |us|
      if us.service.ecolane_profile
        return true
      end
    end
    return false
  end

  # Overwrites Devise Method
  def set_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  # Sends Rest Instructions for API Users
  def send_api_user_reset_password_instructions
    token = self.set_reset_password_token
    UserMailer.reset_api_user_password(self, token).deliver
    token
  end

end
