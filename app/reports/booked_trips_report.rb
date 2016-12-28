class BookedTripsReport < AbstractReport
  include Reporting::ReportHelper, Reporting::ReportHelper::Parcelable
  ActiveRecord::Relation.send(:include, Reporting::ReportHelper::Parcelable) # Include reporting helper methods in query results

  AVAILABLE_DATE_OPTIONS = [:annually, :monthly, :weekly, :daily]

  # Get Data method returns data based on the current user and the report parameters passed in
  def get_data(current_user, report)
    @from_date = Chronic.parse(report.from_date).to_date.in_time_zone.utc
    @to_date = Chronic.parse(report.to_date).to_date.in_time_zone.utc
    @date_range = @from_date..@to_date
    @time_unit = UNITS_OF_TIME[report.booked_trips_date_option.to_sym]

    # Base query -- all valid itineraries, joined with ecolane bookings
    itinerary_base = Itinerary.valid.visible.where(created_at: @date_range).includes(:ecolane_booking).references(:ecolane_booking)
    booked_itins = itinerary_base.where.not(ecolane_bookings: {itinerary_id: nil})
    selected_itins = itinerary_base.selected
    data = {} # Object for holding result

    ##########################
    # All Booked Trips Count #
    ##########################

    # Prepare Data Table
    data[:all_booked_trips] = {
      columns: [],
      rows: [],
      visualization: 'ColumnChart',
      totals: {
        count: booked_itins.count,
        descriptor: "trips booked"
      },
      options: {
        title: "Total Trips Booked, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        hAxis: { ticks: [] },
        chartArea: {height: '80%'}
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

    selected_modes = selected_itins.group("returned_mode_code").count.keys.map {|m| Mode.unscoped.find_by(code: m)}.select {|m| m }

    # Prepare Data Table
    data[:selected_trips_by_mode] = {
      columns: [],
      rows: [],
      visualization: 'ColumnChart',
      totals: {
        count: selected_itins.count,
        descriptor: "trips selected"
      },
      options: {
        title: "Mode of Trips Selected, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        chartArea: {height: '80%'},
        isStacked: true,
        hAxis: { ticks: [] }
      }
    }

    # Create Column Headers
    data[:selected_trips_by_mode][:columns] = [{heading: @time_unit.to_s, type: 'date'}]
    data[:selected_trips_by_mode][:columns] += selected_modes.map do |m|
      { heading: TranslationEngine.translate_text(m.name), type: 'number' }
    end

    # Add Data to the Table
    data[:selected_trips_by_mode][:rows] =
    selected_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      grouped_data = data.group("returned_mode_code").count
      [seg] + selected_modes.map{ |m| grouped_data[m.code] }
    end

    # Set up Tick Marks on hAxis
    data[:selected_trips_by_mode][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)

    #############################
    # Selected Trips by Purpose #
    #############################
    # NOTE: Currently only set up to use trip_purpose_raw field from external booking services

    # Query all itineraries with and without a trip_purpose_raw value (for external booking services)
    itins_with_purpose = selected_itins.includes(trip_part: [trip: [:trip_purpose]])
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
        height: 600,
        chartArea: {height: '80%'}
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
        height: 600,
        chartArea: {height: '80%'}
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
