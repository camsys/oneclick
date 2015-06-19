# This service object will return a hash in which the name of each
# join table associated with the user model is a key that points to 'true'
# Join tables should not be reassigned because the objects inside them are
# already reassigned.  The only exception is when a user 'has_many' through
# another class that has_many of the association.  For example, this object
# should not reassign trip_places because it should reassign the trips instead.

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
      join_table_names = throughs.inject([]) { |memo, r| memo << r.options[:through] if !self.many_through_many(r) }
      join_table_names
    end

    def self.many_through_many(r)
      join_class_string = r.options[:through].to_s.singularize.camelize
      join_klass = Object::const_get(join_class_string)
      singular_reflection = r.name.to_s.singularize.to_sym
      join_klass.reflect_on_association(singular_reflection).macro == :has_many
    end

  end
end
