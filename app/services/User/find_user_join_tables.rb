# This service object will return a hash in which the name of each
# join table associated with the user model is a key that points to 'true'
# Join tables should not be reassigned because the objects inside them are
# already reassigned.

class User

  class FindUserJoinTables

    def self.call
      join_tables = { }

      join_table_names = self.find_keys
      join_table_names.each { |name| join_tables[name] = true }
      join_tables
    end

    def self.find_keys
      reflections = User.reflect_on_all_associations
      throughs = reflections.select { |r| r.name != :multi_od_trips && r.options.has_key?(:through) }
      join_table_names = throughs.inject([]) { |memo, r| memo << r.options[:through] }
      join_table_names
    end

  end
end
