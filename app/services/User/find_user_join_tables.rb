class User

  class FindUserJoinTables
    attr_reader :join_tables

    def self.call
      reflections = User.reflect_on_all_associations
      throughs = reflections.select { |r| r.name != :multi_od_trips && r.options.has_key?(:through) }
      join_tables = throughs.inject([]) { |memo, r| memo << r.options[:through] }
      join_tables
    end

    private

  end
end
