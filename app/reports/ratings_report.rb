class RatingsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, report)
    date_option = DateOption.find(report.date_range)
    date_option ||= DateOption.find_by(code: DateOption::DEFAULT)

    date_range = date_option.get_date_range(report.from_date, report.to_date)

    rating_base = Rating.includes(:user)
      .where(created_at: date_range)
      .references(:user)

    data = []

    if report.agency_id || report.agent_id || report.provider_id
      trips = rating_base.where(rateable_type: 'Trip')
        .joins('INNER JOIN trips ON trips.id = ratings.rateable_id')
      agencies = rating_base.where(rateable_type: 'Agency')
      services = rating_base.where(rateable_type: 'Service')
        .joins('INNER JOIN services ON services.id = ratings.rateable_id')
      
      if report.agency_id
        trips = trips.where(trips: {agency_id: report.agency_id})
        agency_id = report.agency_id
        services = nil
      end

      if report.agent_id
        trips = trips.where(trips: {creator_id: report.agent_id})
          .where.not(trips: {user_id: report.agent_id})
        # Brute force find corresponding agency_id
        agency = Agency.all.find{|a| a.agents.find{|agent| agent.id == report.agent_id}}
        agent_agency_id = agency.id if agency
        if (agency_id && agent_agency_id && (agency_id != agent_agency_id))
          agency_id = nil
        elsif agent_agency_id
          agency_id = agent_agency_id
        end
        
        services = nil
      end

      if agency_id
        agencies = agencies.where(rateable_id: report.agency_id)
      end
      
      if report.provider_id
        trips = trips.where("trips.outbound_provider_id = ? OR trips.return_provider_id = ?",
                            report.provider_id, report.provider_id)
        agencies = nil
        services = services.where(services: {provider_id: report.provider_id}) if services
      end
      
      data = data | trips.decorate if trips
      data = data | agencies.decorate if agencies
      data = data | services.decorate if services

    else
      data = rating_base.decorate
    end
    data
  end

  def get_columns
    [:id, :username, :created, :rating_targets, :rating_in_stars, :comments, :status]
  end

end
