class BookedTripsReport < AbstractReport
  attr_reader :totals_class_names, :totals_cols, :user_cols, :trip_cols, :rating_cols
  include Reporting::ReportHelper, Reporting::ReportHelper::Parcelable
  ActiveRecord::Relation.send(:include, Reporting::ReportHelper::Parcelable) # Include reporting helper methods in query results

  AVAILABLE_DATE_OPTIONS = [:annually, :monthly, :weekly, :daily]

  def initialize(attributes = {})
    # Set up four arrays of column names: Totals, User, Trips, and Ratings
    @totals_cols = []
    @totals_class_names = ['Service', 'Provider', 'Agency']
    @totals_class_names.each do |name|
      @totals_cols << "#{name}_total".to_sym
    end
    @user_cols = [:total_users, :active_users, :total_logins_by_active_users, :totals_by_locale]
    @trip_cols = [:total_trips, :trips_by_ui_mode, :total_itineraries_generated, :total_itineraries_selected,
                  :generated_itineraries_by_mode, :selected_itineraries_by_mode]
    if Oneclick::Application.config.allows_booking
      @trip_cols.insert(3, :bookings) # add in Bookings if bookings are allowed in this instance
    end

    @rating_cols = [:total_ratings, :average_rating]
  end

  # Helper Method sets up tick marks based on time unit
  def setup_tick_marks(date_range, time_unit)
    ticks = []
    year_range = date_range.begin.year..date_range.end.year
    case time_unit
    when :year
      ticks = year_range.map {|y| {v: Date.new(y,1,1), f: y.to_s} }
    when :month
      ticks = year_range.map {|y| {v: Date.new(y,1,1), f: "Jan #{y}"} } +
              year_range.map {|y| {v: Date.new(y,7,1), f: "Jul #{y}"} }
    when :week
      days_in_range = date_range.count
      date_range.step( [days_in_range / 28 * 7, 7].max ) do |d|
        ticks << {v: d, f: d}
      end
    when :day
      ticks = date_range.map do |d|
        [d.year, d.month]
      end.uniq.map {|d| {v: Date.new(d[0],d[1],1), f: Date.new(d[0],d[1],1)} }
    else
    end
    ticks
  end

  # Get Data method returns data based on the current user and the report parameters passed in
  def get_data(current_user, report)
    @from_date = Chronic.parse(report.from_date).to_date
    @to_date = Chronic.parse(report.to_date).to_date
    @date_range = @from_date..@to_date
    @time_unit = UNITS_OF_TIME[report.booked_trips_date_option.to_sym]

    # Base query -- all valid itineraries, joined with ecolane bookings
    itinerary_base = Itinerary.valid.visible.where(created_at: @date_range).includes(:ecolane_booking).references(:ecolane_booking)
    booked_itins = itinerary_base.where.not(ecolane_bookings: {itinerary_id: nil})
    data = {} # Object for holding results tables

    ##########################
    # All Booked Trips Count #
    ##########################

    # Prepare Data Table
    data[:all_booked_trips] = {
      columns: [],
      rows: [],
      visualization: 'ColumnChart',
      options: {
        title: "Total Trips Booked, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        hAxis: { ticks: [] }
      }
    }

    # Add columns
    data[:all_booked_trips][:columns] = [
      { heading: @time_unit.to_s, type: 'date'},
      { heading: "trips booked", type: 'number'}
    ]

    # Add Data to the Table
    data[:all_booked_trips][:rows] = booked_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg, data.count]
    end

    # Set up Tick Marks on hAxis
    data[:all_booked_trips][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)


    ##########################
    # Trips Selected by Mode #
    ##########################

    selected_itins = itinerary_base.selected

    # Prepare Data Table
    data[:selected_trips_by_mode] = {
      columns: [],
      rows: [],
      visualization: 'ColumnChart',
      options: {
        title: "Mode of Trips Selected, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        isStacked: true,
        hAxis: { ticks: [] }
      }
    }

    # Create Column Headers
    data[:selected_trips_by_mode][:columns] = [{heading: @time_unit.to_s, type: 'date'}]
    data[:selected_trips_by_mode][:columns] += Mode.all.map do |m|
      { heading: TranslationEngine.translate_text(m.name), type: 'number' }
    end

    # Add Data to the Table
    data[:selected_trips_by_mode][:rows] =
    selected_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg] + Mode.all.map {|m| data.where(mode_id: m.id).count }
    end

    # Set up Tick Marks on hAxis
    data[:selected_trips_by_mode][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)

    ###########################
    # Trips Booked by Purpose #
    ###########################
    # NOTE: Currently only set up to use trip_purpose_raw field from external booking services

    # Query all itineraries with and without a trip_purpose_raw value (for external booking services)
    itins_with_purpose = booked_itins.includes(trip_part: [trip: [:trip_purpose]])
    itins_with_external_purpose = itins_with_purpose.where.not(trips: {trip_purpose_raw: nil})
    itins_without_external_purpose = itins_with_purpose.where(trips: {trip_purpose_raw: nil})

    # Prepare Data Table
    data[:trip_purposes] = {
      columns: [],
      rows: [],
      visualization: 'PieChart',
      options: {
        title: "Purpose of Trips Selected",
        width: 1000,
        height: 600
      }
    }

    # Create Column Headers
    data[:trip_purposes][:columns] = [
      { heading: 'purpose', type: 'string'},
      { heading: 'trip count', type: 'number'}
    ]

    # Group and count itineraries by (external) trip purpose
    purpose_counts = itins_with_external_purpose.group("trips.trip_purpose_raw").count

    # Lump all but the top X purposes into an other category.
    top_x = [10, purpose_counts.keys.length].min
    other_purposes = purpose_counts.select {|k,v| v < purpose_counts.values.sort[-top_x] }
    purpose_counts["All Other Purposes"] = other_purposes.values.sum
    other_purposes.each {|k,v| purpose_counts.delete(k)}

    # Add Data to the Table
    purpose_counts.each { |purpose, count| data[:trip_purposes][:rows] << [purpose, count] }

    ##########################
    # Status of Booked Trips #
    ##########################

    # Prepare Data Table
    data[:booked_trip_status] = {
      columns: [],
      rows: [],
      table: [],
      visualization: 'PieChart',
      options: {
        title: "Status of Booked Trips",
        width: 1000,
        height: 600
      }
    }

    # Create Column Headers
    data[:booked_trip_status][:columns] = [
      { heading: 'status', type: 'string'},
      { heading: 'trip count', type: 'number'}
    ]

    status_counts = booked_itins.group('ecolane_bookings.booking_status_code').count

    # Add Data to the Table
    status_counts.each do |status, count|
      data[:booked_trip_status][:rows] << [status.strip, count] if status
    end

    ##########################

    # Return Data Hash
    puts "DATA IS: ", data.ai
    data

  end

  def self.available_date_option_collections
    AVAILABLE_DATE_OPTIONS.map {|option| [TranslationEngine.translate_text(option), option]}
  end

end
