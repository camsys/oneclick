class AgencyUserRelationship < ActiveRecord::Base
    include RelationshipsHelper
    
    belongs_to :relationship_status
    belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
    belongs_to :agency
  
end
