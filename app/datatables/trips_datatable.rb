class TripsDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
  # include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  include AjaxDatatablesRails::Extensions::SimplePaginator

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    @sortable_columns ||=
      ['trips.id', 'trips.created_at', 'users.first_name', 'creators.first_name', 'modes.name',
       '', '', '', '', '', '', '', '', '', '',
       '', '', '', '', '',  '', '', '', 'trip_purposes.name']
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    @searchable_columns ||=
      ['users.first_name', 'users.last_name', 'modes.name',]
  end

  # These methods match the common reports_controller interface
  def get_columns
    cols = [:id, :created, :user, :assisted_by, :modes,
            :leaving_from, :from_lat, :from_lon, :out_arrive_or_depart, :out_datetime,
            :going_to, :to_lat, :to_lon, :in_arrive_or_depart, :in_datetime,
            :round_trip, :eligibility, :accommodations, :outbound_itinerary_modes, :return_itinerary_modes,
            :status, :device, :location, :trip_purpose, :outbound_selected_short,
            :return_selected,]
    if Oneclick::Application.config.allows_booking
      cols.insert(16, :booked)
    end
    cols
  end

  def get_data(current_user, report)
    options[:dates] = DateOption.find(report.date_range)
    get_raw_records
  end

  private

  def data
    cols = get_columns
    records.map do |record|
      record = record.decorate
      result = []
      cols.each do |col|
        result << record.send(col)
      end
      result
    end
  end

  def get_raw_records
    Trip.includes(:user, :creator, :trip_places, :trip_purpose, :desired_modes, :trip_parts)
      .where(trip_parts: {scheduled_time: options[:dates].get_date_range})
      .references(:user, :creator, :trip_places, :trip_purpose, :desired_modes, :trip_parts)
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
