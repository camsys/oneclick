# class UserPlace < ActiveRecord::Base
class UserPlace < Place
  self.table_name = 'user_places'
  belongs_to :owner, class_name: User, inverse_of: :places

  # mark this model as requiring roles
  resourcify

end
