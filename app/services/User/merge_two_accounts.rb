class User

  class MergeTwoAccounts
    attr_reader :main, :sub

    def self.call(user1, user2)
      merger = new(user1, user2)
      merger.main.save
      merger.sub.soft_delete
    end

    private

    def initialize
      @main = user1
      @sub = user2
      @reflections = User.reflect_on_all_associations
    end

    def merge_all_possible
      @reflections.each do |r| { |r| merge_association(r) if mergeable?(r) }
    end

    def mergeable?(r)
      r.macro == :has_many || r.macro == :has_and_belongs_to_many
    end

    def merge_association(r)
      @main.send(r.name) += @sub.send(r.name)
    end

  end

end
