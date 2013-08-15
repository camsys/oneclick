class RelationshipStatus < ActiveRecord::Base
  
  REQUESTED = 1
  PENDING = 2
  CONFIRMED = 3
  DENIED = 4
  REVOKED = 5
  
  attr_accessible :id, :name
   
  def self.requested
    find(REQUESTED)
  end
  def self.pending
    find(PENDING)
  end
  def self.confirmed
    find(CONFIRMED)
  end
  def self.denied
    find(DENIED)
  end
  def self.revoked
    find(REVOKED)
  end
  
  def to_s
    name
  end 
end
