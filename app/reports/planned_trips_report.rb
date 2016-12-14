class PlannedTripsReport < AbstractReport
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
    itinerary_base = Itinerary.valid.visible.where(created_at: @date_range)
    trip_base = Trip.created_between(@from_date, @to_date)
    planned_trips = trip_base.planned
    selected_itins = itinerary_base.selected
    data = {} # Object for holding result


    ###########################
    # All Created Trips Count #
    ###########################

    # Prepare Data Table
    data[:all_created_trips] = {
      columns: [],
      rows: [],
      visualization: 'ColumnChart',
      totals: {
        count: trip_base.count,
        descriptor: "trips created"
      },
      options: {
        title: "Total Trips Created, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        chartArea: {height: '80%'},
        hAxis: { ticks: [] }
      }
    }

    # Add columns
    data[:all_created_trips][:columns] = [
      { heading: @time_unit.to_s, type: 'date'},
      { heading: "trips created", type: 'number'}
    ]

    # Add Data to the Table
    data[:all_created_trips][:rows] = trip_base.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg, data.count]
    end

    # Set up Tick Marks on hAxis
    data[:all_created_trips][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)


    ###########################
    # All Planned Trips Count #
    ###########################

    # Prepare Data Table
    data[:all_planned_trips] = {
      columns: [],
      rows: [],
      visualization: 'ColumnChart',
      totals: {
        count: planned_trips.count,
        descriptor: "trips planned"
      },
      options: {
        title: "Total Trips Planned, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        chartArea: {height: '80%'},
        hAxis: { ticks: [] }
      }
    }

    # Add columns
    data[:all_planned_trips][:columns] = [
      { heading: @time_unit.to_s, type: 'date'},
      { heading: "trips planned", type: 'number'}
    ]

    # Add Data to the Table
    data[:all_planned_trips][:rows] = planned_trips.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg, data.count]
    end

    # Set up Tick Marks on hAxis
    data[:all_planned_trips][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)


    ##########################
    # Trips Selected by Mode #
    ##########################

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
    data[:selected_trips_by_mode][:columns] += Mode.all.map do |m|
      { heading: TranslationEngine.translate_text(m.name), type: 'number' }
    end

    # Add Data to the Table
    data[:selected_trips_by_mode][:rows] =
    selected_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg] + Mode.all.map {|m| data.with_mode(m.code).count }
    end

    # Set up Tick Marks on hAxis
    data[:selected_trips_by_mode][:options][:hAxis][:ticks] = setup_tick_marks(@date_range, @time_unit)

    # Return Data Hash
    puts "DATA IS: ", data.ai
    data

  end

  def self.available_date_option_collections
    AVAILABLE_DATE_OPTIONS.map {|option| [TranslationEngine.translate_text(option), option]}
  end

end
