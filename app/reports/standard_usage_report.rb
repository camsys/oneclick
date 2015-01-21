class StandardUsageReport < AbstractReport

  attr_reader :effective_date, :date_option, :totals_cols, :planned_trip_stat_rows, :created_trip_stat_rows, :modes_stat_rows, :booked_legs_stat_rows, :users_stat_rows, :platforms_stat_rows

  AVAILABLE_DATE_OPTIONS = [:weekly, :biweekly, :monthly, :quarterly]

  def initialize(effective_date, date_option)
    @effective_date = if effective_date.blank?
      Date.today 
    else
      effective_date
    end

    @date_option = if date_option.blank?
      :weekly
    else
      date_option.to_sym
    end

    @totals_cols = get_total_cols

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

    @booked_legs_stat_rows = [:number_of_trip_legs_booked]

    @users_stat_rows = [
      :total_registered_users,
      :new_sign_ups,
      :active_users
    ]

    @platforms_stat_rows = [
      :platform,
      :computer,
      :tablet,
      :phone
    ]

    @platforms_stat_rows << :kiosk if Rails.application.config.kiosk_available
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

  def get_localized_columns
    @totals_cols.map {|col| 
      col_name = col[:name]
      if col_name.is_a? Integer
        col_name
      else
        if col_name == :time_period
          "#{I18n.t(col_name)} (#{I18n.t(@date_option)})"
        else
          I18n.t(col_name)
        end
      end
    }
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
          when :number_of_trip_legs_booked
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
          base = User.without_role(:anonymous_traveler)
          row_data << case row
          when :total_registered_users
            base.created_before(col[:end_time]).count
          when :new_sign_ups
            base.created_between(col[:start_time], col[:end_time]).count
          when :active_users
            base.active_between(col[:start_time], col[:end_time]).count
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
          when :phone
            base.with_ui_mode(:phone).count
          when :kiosk
            base.with_ui_mode(:kiosk).count
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

  def get_total_cols
    cols = [{
      name: :time_period
    }]
    launch_date = Rails.application.config.application_launch_date
    last_n = Rails.application.config.usage_report_last_n

    n = 0
    start_date = @effective_date
    while start_date >= launch_date && n < last_n
      name = if n>0 
        -n
      else 
        :current
      end

      end_date = start_date

      start_date = case @date_option
      when :weekly
        start_date.beginning_of_week(:sunday)
      when :biweekly
        start_date.beginning_of_week(:sunday).weeks_ago(1)
      when :monthly
        start_date.beginning_of_month
      when :quarterly
        start_date.beginning_of_quarter
      end

      start_date = launch_date if start_date < launch_date

      cols << {
        name: name,
        start_time: start_date,
        end_time: end_date
      }

      start_date = start_date.yesterday
      n += 1
    end

    cols << {
      name: :year_to_date,
      start_time: Date.new(@effective_date.year, 1, 1).midnight,
      end_time: @effective_date
    }
    cols << {
      name: :launch_to_date,
      start_time: launch_date.midnight,
      end_time: @effective_date
    }

  end
  
end
