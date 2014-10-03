class SystemUsageReport

  attr_reader :totals_class_names, :totals_cols, :user_cols, :trip_cols, :rating_cols
  
  def initialize(attributes = {})
    @totals_cols = []
    @totals_class_names = ['Service', 'Provider', 'Agency', 'KioskLocation']
    @totals_class_names.each do |name|
      @totals_cols << "#{name}_total".to_sym
    end
    @user_cols = [:total_users, :active_users, :total_logins_by_active_users, :totals_by_locale]
    @trip_cols = [:total_trips, :trips_by_ui_mode, :total_itineraries_generated, :total_itineraries_selected,
                  :generated_itineraries_by_mode, :selected_itineraries_by_mode]
    if Oneclick::Application.config.allows_booking
      @trip_cols.insert(3, :bookings)
    end
    
    @rating_cols = [:total_ratings, :average_rating]
  end    

  def get_data(current_user, report)
    date_option = DateOption.find(report.date_range)
    date_option ||= DateOption.find_by(code: DateOption::DEFAULT)
    date_range = date_option.get_date_range(report.from_date, report.to_date)

    data = Hash.new

    @totals_class_names.zip(@totals_cols).each do |name, col|
      if name.constantize.method_defined? :created_at
        data[col] = name.constantize.where(created_at: date_range).count
      else
        data[col] = name.constantize.count
      end
    end

    @user_cols.each do |col|
      case col
      when :total_users
        data[col] = User.where(created_at: date_range).count
      when :active_users
        data[col] = User.where(last_sign_in_at: date_range).count
      when :total_logins_by_active_users
        data[col] = User.where(last_sign_in_at: date_range).sum(:sign_in_count)
      when :totals_by_locale
        data[col] = User.where(created_at: date_range).group(:preferred_locale).count(:preferred_locale)
      end
    end

    trip_base = Trip.where(scheduled_time: date_range)
    trip_base = trip_base.where(agency_id: report.agency_id) if report.agency_id
    trip_base = trip_base.where(creator_id: report.agent_id).where.not(user_id: report.agent_id) if report.agent_id
    trip_base = trip_base.where("outbound_provider_id = ? OR return_provider_id = ?",
                                report.provider_id, report.provider_id) if report.provider_id

    itinerary_base = Itinerary.where(start_time: date_range)
    itinerary_base = itinerary_base.joins(:service)
      .where(services: {provider_id: report.provider_id}) if report.provider_id
    
    @trip_cols.each do |col|
      data[col] = case col
      # Trips
      when :total_trips
        trip_base.count
      when :trips_by_ui_mode
        trip_base.where.not(ui_mode: nil).group(:ui_mode).count(:ui_mode)
      # Itineraries
      when :total_itineraries_generated
        itinerary_base.count
      when :total_itineraries_selected
        itinerary_base.where(selected: true).count
      when :bookings
        itinerary_base.where.not(booking_confirmation: nil).count
      when :generated_itineraries_by_mode
        itinerary_base.group(:mode_id).count
      when :selected_itineraries_by_mode
        itinerary_base.where(selected: true).group(:mode_id).count
      end
    end

    @rating_cols.each do |col|
      data[col] = case col
      when :total_ratings
        Rating.where(status: "approved", updated_at: date_range).count
      when :average_rating
        Rating.where(status: "approved", updated_at: date_range).average(:value)
      end
    end
    
    data
  end
  
  def get_columns
    @totals_cols + @user_cols + @trip_cols
  end
  
end
