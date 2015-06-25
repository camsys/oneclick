# This service object accepts two users.  The first user is the main account,
# and the second is merged into the first account.

class User

  class MergeTwoAccounts
    attr_reader :main, :sub

    def self.call(user1, user2)
      merger = new(user1, user2)
      merger.main.save
      merger.sub.soft_delete
    end

    private

    def initialize(user1, user2)
      @main = user1
      @sub = user2
      @reflections = User.reflect_on_all_associations

      unbuddy_users
      merge_all_possible
    end

    def unbuddy_users
      relationships_from_main = UserRelationship.where(user_id: @main.id).where(delegate_id: @sub.id)
      relationships_from_sub = UserRelationship.where(user_id: @sub.id).where(delegate_id: @main.id)

      total_relationships = relationships_from_main + relationships_from_sub
      total_relationships.each { |rel| rel.destroy }
    end

    def merge_all_possible
      @reflections.each { |r| User::MergeOneAssociation.call(@main, @sub, r) if User::CheckAssociationMergeability.call(r) }
    end
  end
end
