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
      @join_tables = User::FindUserJoinTables.call
      merge_all_possible
    end

    def merge_all_possible
      @reflections.each { |r| User::MergeOneAssociation.call(@main, @sub, r) if mergeable?(r) && appropriate?(r) }
    end

    def mergeable?(r)
      (r.macro == :has_many || r.macro == :has_and_belongs_to_many) && !@join_tables.has_key?(r.name)
    end

    def appropriate?(r)
      @main.respond_to?(r.name) && r.name != :multi_o_d_trips && r.options.has_key?(:through)
    end

    # def merge_association(r)
    #   unique_to_sub(r).each { |assoc| @main.send(r.name) << assoc.dup }
    # end

    # def ids_from_main(r)
    #   from_main = { }
    #   @main.send(r.name).each { |assoc| from_main[assoc.id.to_s] = true }
    #   from_main
    # end

    # def unique_to_sub(r)
    #   from_main = ids_from_main(r)
    #   uniques = @sub.send(r.name).select { |assoc| !from_main.has_key?(assoc.id.to_s) }
    #   uniques
    # end
  end

end
