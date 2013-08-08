class HomeController < ApplicationController
  include CsHelpers

  def index
    @actions = [
      {label: t(:plan_a_trip), target: new_trip_path, icon: ACTION_ICONS[:plan_a_trip]}]
      unless user_signed_in?
        @actions += [
          {label: t(:log_in), target: new_user_session_path, icon: ACTION_ICONS[:log_in]},
          {label: t(:create_an_account), target: new_user_registration_path, icon: ACTION_ICONS[:create_an_account]}
        ]
      else
        @actions += [
          {label: t(:travel_profile), target: error_501_path, icon: ACTION_ICONS[:travel_profile]},
          {label: t(:previous_trips), target: error_501_path, icon: ACTION_ICONS[:previous_trips]},
        ]
      end
# {label: t(:identify_places), target: error_501_path, icon: ACTION_ICONS[:identify_places]},
# {label: t(:change_my_settings), target: error_501_path, icon: ACTION_ICONS[:change_my_settings]},
# {label: t(:help_and_support), target: error_501_path, icon: ACTION_ICONS[:help_and_support]},

end

  end
