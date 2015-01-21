class StandardUsageReport < AbstractReport

  attr_reader :totals_cols, :planned_trip_stat_rows, :created_trip_stat_rows, :modes_stat_rows, :booked_legs_stat_rows, :users_stat_rows, :platforms_stat_rows

  AVAILABLE_DATE_OPTIONS = [:weekly, :biweekly, :monthly, :quarterly]

  def initialize(effective_date, date_option)
    effective_date = Date.today if effective_date.blank?
    date_option = :weekly if date_option.blank?
    @totals_cols = get_total_cols(effective_date, date_option)

    @planned_trip_stat_rows = [
      :number_of_trips_planned,
      :registered_users,
      :visitors
    ]

    @created_trip_stat_rows = [
      :number_of_trips_created,
      :registered_users,
      :visitors,
      :agents
    ]

    @modes_stat_rows = [
      :transit,
      :paratransit,
      :walk,
      :others
    ]

    @booked_legs_stat_rows = [:trip_legs_booked]

    @users_stat_rows = [
      :registered_users_total,
      :new_sign_ups,
      :active
    ]

    @platforms_stat_rows = [
      :platform,
      :computer,
      :tablet,
      :smartphone
    ]

    @platforms_stat_rows << :koisk if Rails.application.config.kiosk_available
  end    

  def self.available_date_option_collections
    StandardUsageReport::AVAILABLE_DATE_OPTIONS.map {|option| [I18n.t(option), option]}
  end

  def get_data
    [
      get_planned_trip_stat_rows,
      [get_empty_data_row],
      get_created_trip_stat_rows,
      [get_empty_data_row],
      get_modes_stat_rows,
      [get_empty_data_row],
      get_booked_legs_stat_rows,
      [get_empty_data_row],
      get_users_stat_rows,
      [get_empty_data_row],
      get_platforms_stat_rows,
      [get_empty_data_row]
    ].flatten(1)
  end
  
  def get_columns
    @totals_cols.map {|col| col[:name]}
  end

  def get_planned_trip_stat_rows
    data = []

    @planned_trip_stat_rows.each do |row|
      row_data = []
      @totals_cols.each do |col|
        if col[:name] == :time_period
          row_data << I18n.t(row)
        else
          base = Trip.planned.created_between(col[:start_time], col[:end_time])
          row_data << case row
          when :registered_users
            base.without_role(Role::ANONYMOUS_TRAVELER).count
          when :visitors
            base.with_role(Role::ANONYMOUS_TRAVELER).count
          when :number_of_trips_planned
            base.count
          end
        end
      end
      data << row_data
    end

    data
  end

  def get_created_trip_stat_rows
    data = []

    @created_trip_stat_rows.each do |row|
      row_data = []
      @totals_cols.each do |col|
        if col[:name] == :time_period
          row_data << I18n.t(row)
        else
          base = Trip.created_between(col[:start_time], col[:end_time])
          row_data << case row
          when :registered_users
            base.without_role(Role::ANONYMOUS_TRAVELER).count
          when :visitors
            base.with_role(Role::ANONYMOUS_TRAVELER).count
          when :agents
            base.with_role(Role::AGENT).count
          when :number_of_trips_created
            base.count
          end
        end
      end
      data << row_data
    end
    data
  end

  def get_modes_stat_rows
    data = []

    @modes_stat_rows.each do |row|
      row_data = []
      @totals_cols.each do |col|
        if col[:name] == :time_period
          row_data << I18n.t(row)
        else
          base = Itinerary.created_between(col[:start_time], col[:end_time])
          row_data << case row
          when :transit
            base.with_mode('mode_transit').count
          when :paratransit
            base.with_mode('mode_paratransit').count
          when :walk
            base.with_mode('mode_walk').count
          when :others
            base.without_mode(['mode_transit','mode_paratransit','mode_walk']).count
          end
        end
      end
      data << row_data
    end

    data
  end

  def get_booked_legs_stat_rows
    data = []

    @booked_legs_stat_rows.each do |row|
      row_data = []
      @totals_cols.each do |col|
        if col[:name] == :time_period
          row_data << I18n.t(row)
        else
          base = Itinerary.created_between(col[:start_time], col[:end_time]).booked
          row_data << case row
          when :trip_legs_booked
            base.count
          end
        end
      end
      data << row_data
    end

    data
  end

  def get_users_stat_rows
    data = []

    @users_stat_rows.each do |row|
      row_data = []
      @totals_cols.each do |col|
        if col[:name] == :time_period
          row_data << I18n.t(row)
        else
          base = User.registered
          row_data << case row
          when :registered_users_total
            base.created_before(col[:end_time]).count
          when :new_sign_ups
            base.created_between(col[:start_time], col[:end_time]).count
          when :active
            base.active_before(col[:end_time]).count
          end
        end
      end
      data << row_data
    end

    data
  end

  def get_platforms_stat_rows
    data = []

    @platforms_stat_rows.each do |row|
      row_data = []
      @totals_cols.each do |col|
        if col[:name] == :time_period
          row_data << I18n.t(row)
        else
          base = Trip.planned.created_between(col[:start_time], col[:end_time])
          row_data << case row
          when :platform
            base.count
          when :computer
            base.with_ui_mode(:desktop).count
          when :tablet
            base.with_ui_mode(:tablet).count
          when :smartphone
            base.with_ui_mode(:phone).count
          when :koisk
            base.with_ui_mode(:koisk).count
          end
        end
      end
      data << row_data
    end

    data
  end

  private

  def get_empty_data_row
    @totals_cols.map {""}
  end

  def get_total_cols(effective_date, date_option)
    cols = [{
      name: :time_period
    }]
    launch_date = Rails.application.config.application_launch_date
    cols << {
      name: :year_td,
      start_time: Date.new(effective_date.year, 1, 1).midnight,
      end_time: effective_date
    }
    cols << {
      name: :launch_td,
      start_time: launch_date.midnight,
      end_time: effective_date
    }

  end
  
end
