class User

  class MergeOneAssociation
    attr_reader :main

    def self.call(user1, user2, reflection)
      merger = new(user1, user2, reflection)
      merger.main.save
    end

    private

    def initialize(user1, user2, reflection)
      @main = user1
      @sub = user2
      @r = reflection

      if !special_case[@r.name]
        merge_association
      else
        special_merge
      end
    end

    def merge_association
      unique_to_sub.each { |assoc| @main.send(@r.name) << assoc }
    end

    def ids_from_main
      from_main = { }
      @main.send(@r.name).each { |assoc| from_main[assoc.id.to_s] = true }
      from_main
    end

    def unique_to_sub
      from_main = ids_from_main
      uniques = @sub.send(@r.name).select { |assoc| !from_main.has_key?(assoc.id.to_s) }
      uniques
    end

    def special_merge
      @sub.send(r.name).each { |assoc| assoc.update!(user_id: @main.id) }
    end

    def special_case
      {
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
  end

end
