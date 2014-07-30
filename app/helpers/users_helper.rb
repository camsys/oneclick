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

end
