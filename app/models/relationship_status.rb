class RelationshipStatus < ActiveRecord::Base
  
  attr_accessible :id, :name
   
  def to_s
    name
  end 
end
