class User

  class UpdateAllUserProxies
    attr_reader :updated

    def self.call(user, params)
      new(user, params)
    end

    private

    def initialize(user, params)
      @user = user

      @user_characteristics_proxy = UserCharacteristicsProxy.new(@user) #we inflate a new proxy every time, but it's transient, just holds a bunch of characteristics
      @updated = false
      # prep for password validation in @user.update by removing the keys if neither one is set.  Otherwise, we want to catch with password validation in User.rb
      if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
        params[:user].except! :password, :password_confirmation
      end

      if @user.update(user_params_with_password) # .update is a Devise method, not the standard update_attributes from Rails
        params[:user][:roles].reject(&:blank?).empty? ? @user.remove_role(:system_administrator) : @user.add_role(:system_administrator)
        @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
        set_approved_agencies(params[:user][:approved_agency_ids])
        booking_alert = set_booking_services(@user, params[:user_service])
        @user.update_relationships(params[:user][:relationship])
        @user.add_buddies(params[:new_buddies])

        @updated = true
      end # end of initialize method

    def set_approved_agencies(ids)
      new_agency_ids = ids.reject!(&:empty?) # Simple form keeps adding a blank, so strip that out
      old_agency_ids = @user.approved_agencies.pluck(:id).map(&:to_s)  #hack.  Converting to strings for comparison to params hash

      new_relationships = new_agency_ids - old_agency_ids # Any agency set in the params but not the profile
      revoked_agencies = old_agency_ids - new_agency_ids # Any agency set in the profile but not the params
      new_relationships.each do |id| # Create new ones if they don't exist already
        rel = AgencyUserRelationship.find_or_create_by!(user_id: @user.id, agency_id: id) do |aur|
          aur.creator = current_user.id
        end
        #now that we have the relationship object, set it as active/confirmed
        rel.update_attributes(relationship_status: RelationshipStatus.confirmed)
        agency = Agency.find(id)
        UserMailer.agency_helping_email(@user.email, agency.email, agency)
      end
      revoked_agencies.each do |revoked_id|
        revoked = AgencyUserRelationship.find_by(agency_id: revoked_id, user_id: @user.id)
        revoked.update_attributes(relationship_status: RelationshipStatus.revoked)
      end
    end

    def set_booking_services(user, services)
      alert = false
      dob = services['dob']
      services.each do |id, user_id|
        unless id == 'dob'
          service = Service.find(id)

          eh = EcolaneHelpers.new
          unless user_id == ""
            unless eh.validate_passenger(user_id, dob)[0]
              alert = true
              next
            end
            user_service = UserService.where(user_profile: user.user_profile, service: service).first_or_initialize
            user_service.external_user_id = user_id
            user_service.save
          else
            user_services = UserService.where(user_profile: user.user_profile, service: service)
            user_services.each do |user_service|
              user_service.destroy
            end
          end
        end
      end
      alert
    end

    end # end of service object
  end
end #
