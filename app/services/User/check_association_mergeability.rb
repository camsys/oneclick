class User

  class CheckAssociationMergeability

    def self.call(reflection)
      check_mergeablity = new(reflection)
      check_mergeablity.is_mergeable?
    end

    def is_mergeable?
      many_relationship && included
    end

    private

    def initialize(reflection)
      @r = reflection
      @join_tables = User::FindUserJoinTables.call
    end

    def many_relationship
      (@r.macro == :has_many || @r.macro == :has_and_belongs_to_many)
    end

    def included
      if ignored[@r.name]
        false
      elsif keep[@r.name]
        true
      elsif @join_tables.has_key?(@r.name)
        false
      else
        true
      end
    end

    def ignored
      {
        multi_o_d_trips: true,
        trip_places: true,
        trip_parts: true,
        characteristics: true,
        user_characteristics: true,
        user_roles: true,
        roles: true,
        accomodations: true,
        user_accomodations: true,
        ratings: true,
        buddies: true,
        buddy_relationships: true,
        delegates: true,
        delegate_relationships: true,
        confirmed_delegates: true,
        pending_and_confirmed_delegates: true,
        traveler_relationships: true,
        travelers: true,
        confirmed_travelers: true
      }
    end



    def keep
      {
        trips: true
      }
    end
  end

end
