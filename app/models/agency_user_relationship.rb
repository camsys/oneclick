class AgencyUserRelationship < ActiveRecord::Base
    include RelationshipsHelper
    
    belongs_to :relationship_status
    belongs_to :user
    belongs_to :agency
  
end
