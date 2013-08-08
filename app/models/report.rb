class Report < ActiveRecord::Base
  
  attr_accessible :string, :description, :name, :view_name, :class_name, :active
  
  # default scope
  default_scope where(:active => true)
  
end
