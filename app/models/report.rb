class Report < ActiveRecord::Base
  
  attr_accessible :string, :description
  
  # default scope
  default_scope where(:active => true)
  
end
