
# Transient class to aggregate and persist ratings for a rateable.
# Allows us to treat rating trips and organizations the same
class RatingsProxy < Proxy
  # include ActiveModel::Model
  attr_reader :rateables
      
  def initialize(rateable)
    @rateables = []
    case rateable
    when Trip
      @rateables << rateable
      if rateable.planned_by_agent
        @rateables << rateable.creator.agency
      end
      rateable.selected_services.each do |s|
        @rateables << s
      end
    when Agency, Provider, Service
        @rateables << rateable
    end
    super
  end

end