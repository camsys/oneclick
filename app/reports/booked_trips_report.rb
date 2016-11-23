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

  # Get Data method returns data based on the current user and the report parameters passed in
  def get_data(current_user, report)
    @from_date = Chronic.parse(report.from_date).to_date
    @to_date = Chronic.parse(report.to_date).to_date
    @date_range = @from_date..@to_date
    @time_unit = UNITS_OF_TIME[report.booked_trips_date_option.to_sym]
    itinerary_base = Itinerary.valid.visible.where(created_at: @date_range) # Base query -- all valid itineraries
    data = {} # Object for holding results tables

    ##########################
    # All Booked Trips Count #
    ##########################

    booked_itins = itinerary_base.where.not(booking_confirmation: nil)

    # Prepare Data Table
    data[:all_booked_trips] = {
      table: [[@time_unit.to_s, "trips booked"]],
      visualization: 'ColumnChart',
      options: {
        title: "Total Trips Booked, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600
      }
    }

    # Add Data to the Table
    data[:all_booked_trips][:table] +=
    booked_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg.send(@time_unit).to_s, data.count]
    end

    ##########################
    # Trips Selected by Mode #
    ##########################

    selected_itins = itinerary_base.selected

    # Prepare Data Table
    data[:selected_trips_by_mode] = {
      table: [],
      visualization: 'ColumnChart',
      options: {
        title: "Mode of Trips Selected, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600,
        isStacked: true
      }
    }

    # Create Column Headers
    data[:selected_trips_by_mode][:table] << ([@time_unit.to_s] + Mode.all.map {|m| TranslationEngine.translate_text(m.name)})

    # Add Data to the Table
    data[:selected_trips_by_mode][:table] +=
    selected_itins.parcel_by(@date_range, @time_unit) do |seg, data|
      [seg.send(@time_unit).to_s] + Mode.all.map {|m| data.where(mode_id: m.id).count }
    end

    ###########################
    # Trips Booked by Purpose #
    ###########################

    # Query all itineraries with and without a trip_purpose_raw value (for external booking services)
    itins_with_purpose = itinerary_base.includes(trip_part: [trip: [:trip_purpose]])
    itins_with_external_purpose = itins_with_purpose.where.not(trips: {trip_purpose_raw: nil})
    itins_without_external_purpose = itins_with_purpose.where(trips: {trip_purpose_raw: nil})

    # Prepare Data Table
    data[:trip_purposes] = {
      table: [],
      visualization: 'PieChart',
      options: {
        title: "Mode of Trips Selected, by #{@time_unit.to_s.titleize}",
        width: 1000,
        height: 600
      }
    }

    # Create Column Headers
    data[:trip_purposes][:table] << ['purpose', 'trip count']

    # Make a list of trip purposes
    purpose_list = (
      TripPurpose.all.map {|tp| tp.code} +
      Trip.where.not(trip_purpose_raw: nil).map {|t| t.trip_purpose_raw.parameterize.underscore}
    ).uniq

    # Add Data to the Table
    purpose_list.each do |tp|
      data[:trip_purposes][:table] << [tp,
        itins_with_external_purpose.where(:trips => {trip_purpose_raw: tp.humanize.titleize}).count +
        itins_without_external_purpose.where(:trip_purposes => {:code => tp}).count
      ] # REFACTOR trip_purpose_raw -- doesn't work for all trip_purposes
    end


    ###########################

    # Return Data Hash
    puts "DATA IS: ", data.ai
    data

  end

  def self.available_date_option_collections
    AVAILABLE_DATE_OPTIONS.map {|option| [TranslationEngine.translate_text(option), option]}
  end

end
