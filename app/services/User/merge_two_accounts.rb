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
      merge_all_possible
    end

    def merge_all_possible
      @reflections.each { |r| merge_association(r) if mergeable?(r) && exists(r) }
    end

    def mergeable?(r)
      r.macro == :has_many || r.macro == :has_and_belongs_to_many
    end

    def exists(r)
      @main.respond_to?(r.name) && @sub.respond_to?(r.name) && r.name != :multi_o_d_trips
    end

    def merge_association(r)
      total = @sub.send(r.name) + @main.send(r.name)
      eval("@main.#{ r.name.to_s } = total.uniq")
    end
  end

end