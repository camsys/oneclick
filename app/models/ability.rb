class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role?(:admin) or user.has_role?(:system_administrator)
      # admin users can do almost anything, so it's simpler to enumerate what they can't do
      can :manage, :all

      # TODO Are these 2 redundant?
      can [:see], :admin_menu
      can :see, :staff_menu
      can [:index], :admin_home
      can [:access], :any
      can [:access], :staff_travelers
      can [:access], :admin_users
      
      cannot [:access], :admin_create_traveler
      cannot [:access], :staff_travelers
      cannot :access, :show_agency
      cannot :access, :show_provider
      cannot :travelers, Agency
      cannot :full_info, User
      cannot :assist, User # That permissions is restricted to agency staff
      cannot :rate, Trip # remove global permission to rate, sys admin will still be able to rate when it's their own trip
    end
    if user.has_role? :feedback_administrator
      can [:see], :admin_menu
      can :access, :admin_feedback
      can [:manage], Rating # feedback admin will always be able to read feedback
    end
    if User.with_role(:agency_administrator, :any).include?(user)
      # TODO Are these 2 redundant?
      can [:see], :staff_menu
      can [:index], :admin_home

      can [:access], :staff_travelers
      can :travelers, Agency, {id: user.agency.try(:id)}
      can :travelers, User #can find any user if they search
      can :show, User #can find any user if they search
      # can :edit, User, {user.approved_agencies.contains? }
      can [:access], :show_agency
      can [:access], :admin_create_traveler
      can [:access], :admin_trips
      can [:access], :admin_agencies
      can [:access], :admin_users
      can [:access], :admin_providers
      can [:access], :admin_services
      can [:access], :admin_reports
      can [:access], :admin_feedback

      can :manage, AgencyUserRelationship, agency_id: user.agency.try(:id)
      can :read, Agency # all agencies are viewable
      can :full_read, Agency # read gives access to only contact info.  full_read offers staff, internal contact, etc.
      can [:update, :destroy], Agency, id: user.agency.try(:id), active: true
      can [:update], Agency do |a|  # edit privilege over sub agencies
        user.agency.present? && user.agency.sub_agencies.include?(a)
      end
      can [:update, :full_info, :assist], User do |u|
        u.approved_agencies.include? user.try(:agency)
      end
      can :create, User
      can :read, [Provider, Service]
      can [:index, :show], Report
      can [:read, :update], User, agency_id: user.agency.try(:id)
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
      cannot [:access], :admin_reports
      can [:access], :admin_feedback
      can :manage, AgencyUserRelationship, agency_id: user.agency.try(:id)
      can :read, Agency
      can :full_read, Agency # read gives access to only contact info.  full_read offers staff, internal contact, etc.
      can [:create, :show], User #can find any user if they search, can create a user
      can [:update, :full_info, :assist], User do |u| # agents have extra privileges for users that have approved the agency
        u.approved_agencies.include? user.try(:agency)
      end
      can [:travelers], Agency, id: user.agency.try(:id)
      can [:read], Agency
      can [:index, :show], Report
      can [:index, :show], [Provider, Service] # Read-only access to providers and services
      #can [:read, :update], User, agency_id: user.agency.try(:id) #removing because there isn't extra information for an agent here
    end

    if User.with_role(:provider_staff, :any).include?(user)
      can [:see], :staff_menu
      can [:index], :admin_home

      can [:access], :admin_trips
      can [:access], :show_provider
      can [:access], :admin_reports
      can [:access], :admin_feedback

      can [:index, :show], Report
      can [:read, :full_read], Provider, id: user.try(:provider_id) # full read includes add'l information.  All users can read contact info
      can [:update, :destroy], Provider, id: user.try(:provider_id), active: true
      can [:update, :show, :full_read], Service do |s|
        user.provider.services.include?(s)
      end
      can :create, Service
    end

    ## All users have the following permissions, which logically OR with 'can' statements above
    can [:read, :create, :update, :destroy], [Trip, Place], :user_id => user.id 
    can [:read, :update, :full_info], User, :id => user.id
    can :geocode, :util
    can :show, Service # Will have view privileges for individual info purposes
    can :show, Provider # Will have view privileges for individual info purposes
    can :show, Agency # Will have view privileges for individual info purposes
    
    ## Rating Logic is configurable by deployment.  
    can :read, Rating if Oneclick::Application.config.public_read_feedback
    if Oneclick::Application.config.public_write_feedback
      can [:create, :update], Rating
      cannot :create, Rating do |r| 
        case r.rateable_type
        when "Trip" # cannot rate trips if I did not take them or plan them for another user
          r.rateable.user.id != user.id or r.rateable.creator.id != user.id
        when "Agency" # cannot rate Agency if I work for that agency
          r.rateable.id == user.agency_id
        end
      end
    end
  end

end

# :admin_find_traveler
# :admin_create_traveler
# :admin_trips
# :admin_agencies
# :admin_users
# :admin_providers
# :admin_services
# :admin_reports

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
