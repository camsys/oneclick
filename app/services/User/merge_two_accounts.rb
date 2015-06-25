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

    def get_all_relationships(user)
      user.traveler_
    end

    def merge_all_possible
      @reflections.each { |r| User::MergeOneAssociation.call(@main, @sub, r) if User::CheckAssociationMergeability.call(r) }
    end

    # def mergeable?(r)
    #   many_relationship(r) && included(r)
    # end

    # def many_relationship(r)
    #   (r.macro == :has_many || r.macro == :has_and_belongs_to_many)
    # end

    # def included(r)
    #   if ignored[r.name]
    #     false
    #   elsif keep[r.name]
    #     true
    #   elsif join_tables.has_key?(r.name)
    #     false
    #   else
    #     true
    #   end
    # end

    # def ignored
    #   {
    #     multi_o_d_trips: true,
    #     trip_places: true,
    #     trip_parts: true,
    #     characteristics: true,
    #     user_characteristics: true,
    #     user_roles: true,
    #     roles: true
    #   }
    # end

    # def keep
    #   {
    #     trips: true
    #   }
    # end
  end
end
