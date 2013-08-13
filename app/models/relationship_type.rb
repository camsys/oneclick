class RelationshipType < ActiveRecord::Base
  
  # Associations
  has_many :user_relationships
  
end
