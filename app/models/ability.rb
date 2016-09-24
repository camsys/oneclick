class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role?(:admin) or user.has_role?(:system_administrator)
      # admin users can do almost anything, so it's simpler to enumerate what they can't do
      can :manage, :all

      cannot [:access], :admin_create_traveler
      cannot [:access], :staff_travelers
      cannot :access, :show_agency
      cannot :access, :show_provider
      cannot :travelers, Agency
      # cannot :full_read, User
      cannot :assist, User # That permissions is restricted to agency staff
      cannot :rate, Trip # remove global permission to rate, sys admin will still be able to rate when it's their own trip
      can :settings, :util
      can :load_pois, :pois
      can :update_callnride_boundary, :oneclick_configuration
      can :upload_application_logo, :util
      can :upload_favicon, :util
    else
      if I18n.locale == :tags
        return # no access to tags pages for non-admin users
      end
    end

    if user.has_role? :feedback_administrator
      can [:see], :admin_menu
      can :access, :admin_feedback
      can [:manage], SidewalkObstruction # feedback admin will always be able to read sidwalk feedback
      can :send_follow_up, Trip
    end

    if User.with_role(:agency_administrator, :any).include?(user)
      # TODO Are these 2 redundant?
      can [:see], :staff_menu
      can [:index], :admin_home

      can [:access], :staff_travelers
      can :travelers, Agency, {id: user.agency.try(:id)}
      can :travelers, User #can find any user if they search
      can :show, User #can find any user if they search
      #can :edit, User#, {user.approved_agencies.contains? }
      can [:access], :show_agency
      can [:access], :admin_create_traveler
      can [:access], :admin_trips
      can [:access], :admin_agencies
      can [:access], :admin_users
      can [:access], :admin_providers
      can [:access], :admin_services
      can [:access], :admin_reports
      can [:access], :admin_feedback
      can [:create], Message

      can :manage, AgencyUserRelationship, agency_id: user.agency.try(:id)
      can :read, Agency # all agencies are viewable
      can :full_read, Agency # read gives access to only contact info.  full_read offers staff, internal contact, etc.
      can [:update, :destroy], Agency, id: user.agency.try(:id), active: true
      can [:update], Agency do |a|  # edit privilege over sub agencies
        user.agency.present? && user.agency.sub_agencies.include?(a)
      end
      can [:full_read, :assist], User do |u|
        u.approved_agencies.include? user.try(:agency)
      end
      can :create, User
      can :read, [Provider, Service]
      can [:show, :results, :trips_datatable], Report
      can [:read, :update], User, agency_id: user.agency.try(:id)
      can :send_follow_up, Trip
    end

    if User.with_role(:agent, :any).include?(user)
      can [:see], :staff_menu
      can [:index], :admin_home
      can [:access], :show_agency
      can [:access], :staff_travelers
      can [:access], :admin_create_traveler
      can [:access], :admin_agencies
      can [:access], :admin_trips
      can [:access], :admin_providers
      can [:access], :admin_services
      can [:access], :admin_feedback
      can [:access], :admin_reports
      can [:access], :user_guide
      can [:access, :manage], MultiOriginDestTrip
      can :manage, AgencyUserRelationship, agency_id: user.agency.try(:id)
      can :read, Agency
      can :full_read, Agency # read gives access to only contact info.  full_read offers staff, internal contact, etc.
      can [:create, :show], User #can find any user if they search, can create a user
      can [:full_read, :assist], User do |u| # agents have extra privileges for users that have approved the agency
        u.approved_agencies.include? user.try(:agency)
      end
      can [:travelers], Agency, id: user.agency.try(:id)
      can [:read], Agency
      can [:show, :results, :trips_datatable], Report
      can [:index, :show], [Provider, Service] # Read-only access to providers and services
      can :send_follow_up, Trip
      can [:create], Message
    end

    if User.with_role(:provider_staff, :any).include?(user)
      can [:see], :staff_menu
      can [:index], :admin_home

      can [:access], :admin_trip_parts
      can [:access], :show_provider
      can [:access], :admin_reports
      can [:access], :admin_feedback

      can [:show, :results, :trips_datatable], Report
      can [:read, :full_read, :find_staff_by_email], Provider, id: user.try(:provider_id) # full read includes add'l information.  All users can read contact info
      can [:update, :destroy], Provider, id: user.try(:provider_id), active: true
      can [:update, :show, :full_read, :destroy, :manage], Service do |s|
        user.provider.services.include?(s)
      end
      can :create, Service
      can :send_follow_up, Trip
      can :create, FareZone
      can [:create], Message

    end

    ## All users have the following permissions, which logically OR with 'can' statements above
    can [:read, :create, :update, :destroy], [Trip, Place], :user_id => user.id
    can [:read, :full_read, :update, :add_booking_service, :initial_booking, :find_by_email], User, :id => user.id
    can [:assist], User do |traveler|
      user.confirmed_travelers.include? traveler
    end
    can :manage, UserRelationship do |ur|
      ur.delegate.eql? user or ur.traveler.eql? user
    end
    can :geocode, :util
    can :show, Service # Will have view privileges for individual info purposes
    can :show, Provider # Will have view privileges for individual info purposes
    can :show, Agency # Will have view privileges for individual info purposes

  end

end
