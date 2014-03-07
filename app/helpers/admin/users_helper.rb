module Admin::UsersHelper

    def can_be_impersonated_by_current_user(user)
        current_user.agency.presence && user.is_registered? && (user != current_user)
    end
end
