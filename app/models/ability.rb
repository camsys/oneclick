class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role?(:admin) or user.has_role?(:system_administrator)
      # admin users can do anything      
      can :manage, :all

      # TODO Are these 2 redundant?
      can [:see], :admin_menu
      can :see, :staff_menu
      can [:index], :admin_home

      can [:access], :any
      can [:access], :staff_travelers
      cannot [:access], :admin_create_traveler
      cannot [:access], :staff_travelers
      can [:access], :admin_users
      cannot :access, :show_agency
      cannot :access, :show_provider
      cannot :travelers, Agency
      return
    end
    if User.with_role(:agency_administrator, :any).include?(user)
      # TODO Are these 2 redundant?
      can [:see], :staff_menu
      can [:index], :admin_home

      can [:access], :staff_travelers
      can :travelers, Agency, {id: user.agency.try(:id)}
      can :travelers, User #can find any user if they search
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
      can [:read, :update], Agency, id: user.agency.try(:id)
      can :read, Agency
      can :perform, :assist_user
      can :create, User
      can :manage, [Provider, Service]
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
      can [:travelers], Agency, id: user.agency.try(:id)
      can [:read], Agency
      # can [:read, :update], User, {agency_id: user.agency.try(:id)}
      can [:index, :show], Report
      can [:index, :show], [Provider, Service]
      can :perform, :assist_user
      can :create, User
    end

    if User.with_role(:provider_staff, :any).include?(user)
      can [:see], :staff_menu
      can [:index], :admin_home

      can [:access], :admin_trips
      can [:access], :show_provider
      can [:access], :admin_reports
      can [:access], :admin_feedback

      can [:index, :show], Report
      can [:manage], Provider, id: user.try(:provider_id)
      can [:update, :show], Service do |s|
        user.provider.services.include?(s)
      end
    end

    can [:read, :create, :update, :destroy], [Trip, Place], :user_id => user.id 
    can [:read, :update], User, :id => user.id
    can :geocode, :util
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
