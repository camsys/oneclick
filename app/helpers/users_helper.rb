module UsersHelper
  # decouples View and Controller logic to pass messages back for editing a user
  # given a string, returns a jQuery selector for that string
  def selectorify(name)
    "$('##{name}')"
  end

  def get_user_name(user)
  	return user.first_name + ' ' + user.last_name if user.first_name and user.last_name
  	return user.first_name if user.first_name
  	return user.last_name if user.last_name
  	return I18n.t(:unknown)
  end

  def get_selected_walking_speed_id(user)
    return user.walking_speed_id if user.walking_speed_id
    default_speed = WalkingSpeed.where(is_default: true).first
    unless default_speed.nil?
      return default_speed.id
    end
  end

  def get_selected_walking_max_distance_id(user)
    return user.walking_maximum_distance_id if user.walking_maximum_distance_id
    default_dist = WalkingMaximumDistance.where(is_default: true).first
    unless default_dist.nil?
      return default_dist.id
    end
  end

end
