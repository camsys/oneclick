module UsersHelper
  # decouples View and Controller logic to pass messages back for editing a user
  # given a string, returns a jQuery selector for that string
  def selectorify(name)
    "$('##{name}')"
  end

end
