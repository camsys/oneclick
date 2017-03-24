class UniqueUsersReport < AbstractReport
  include Reporting::ReportHelper, Reporting::ReportHelper::Parcelable, Reporting::GoogleChartsHelper
  ActiveRecord::Relation.send(:include, Reporting::ReportHelper::Parcelable) # Include reporting helper methods in query results

  # Get Data method returns data based on the current user and the report parameters passed in
  def get_data(current_user, report)
    setup_date_attributes(report)

    ### Itinerary Queries ###
    # Base query -- all valid itineraries, joined with ecolane bookings
    itinerary_base = Itinerary.valid.visible.where(created_at: @date_range).includes(:ecolane_booking).references(:ecolane_booking)

    # Filter base by counties
    @county_filters = report.county_filters.select {|f| !f.blank? }
    itinerary_base = itinerary_base.includes(trip_part: [:from_trip_place])
    itinerary_base = itinerary_base.where(trip_places: {county: @county_filters}) unless @county_filters.empty?

    itinerary_base = itinerary_base.joins(trip_part: { trip: :user })

    # Additional queries based on base query
    booked_itins = itinerary_base.where.not(ecolane_bookings: {itinerary_id: nil})
    selected_itins = itinerary_base.selected
    data = {} # Object for holding result

    ### User Queries ###
    new_users = User.where.not(first_name: "Visitor", last_name: "Guest").where(created_at: @date_range)

    ######################################
    # Unique Users Who Have Booked Trips #
    ######################################

    counties = group_by_county(booked_itins).keys

    # Prepare Data Table
    data[:unique_booking_users] = build_google_charts_hash(title: "Unique Users who Booked Trips, by #{@time_unit.to_s.titleize} and Origin County")

    # Add totals
    data[:unique_booking_users][:totals] = {
      count: unique_users(booked_itins).count,
      descriptor: "total unique users"
    }

    # Create Column Headers
    data[:unique_booking_users][:columns] = [{ heading: @time_unit.to_s, type: 'date'}]
    data[:unique_booking_users][:columns] += counties.map do |c|
      { heading: (c.nil? ? 'no county data' : c), type: 'number'}
    end

    # Add Data to the Table
    data[:unique_booking_users][:rows] =
    booked_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      grouped_data = distinct_users_by_county(data)
      [seg] + counties.map{ |c| grouped_data[c] }
    end

    # Set up Tick Marks on hAxis
    data[:unique_booking_users][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)


    ####################
    # New User Signups #
    ####################

    # Prepare Data Table
    data[:new_user_signups] = build_google_charts_hash(title: "New User Signups, by #{@time_unit.to_s.titleize}")

    # Add totals
    data[:new_user_signups][:totals] = {
      count: new_users.count,
      descriptor: "total unique users"
    }

    # Add columns
    data[:new_user_signups][:columns] = [
      { heading: @time_unit.to_s, type: 'date'},
      { heading: "new user signups", type: 'number'}
    ]

    # Add Data to the Table
    data[:new_user_signups][:rows] = new_users.parcel_by(@date_range, @time_unit) do |seg, data|
      puts data.ai
      [seg, data.count]
    end

    # Set up Tick Marks on hAxis
    data[:new_user_signups][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)


    ##########################

    # Return Data Hash
    puts "DATA IS: ", data.ai
    data

  end

  def self.available_date_option_collections
    AVAILABLE_DATE_OPTIONS.map {|option| [TranslationEngine.translate_text(option), option]}
  end

end
