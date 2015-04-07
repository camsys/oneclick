require 'rails_erd/domain/relationship'

module RailsERD
  class Domain
    class Relationship
      class << self
        private

        def association_identity(association)
          Set[association_owner(association), association_target(association)]
        end
      end
    end
  end
end