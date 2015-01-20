class StandardUsageReport < AbstractReport

  attr_reader :totals_cols, :planned_trip_stat_rows, :created_trip_stat_rows, :options_stat_rows, :booked_legs_stat_rows, :users_stat_rows

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
  end    

  def self.available_date_option_collections
    StandardUsageReport::AVAILABLE_DATE_OPTIONS.map {|option| [I18n.t(option), option]}
  end

  def get_data
    planned_trip_stat_rows = get_planned_trip_stat_rows
    
    planned_trip_stat_rows
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
          row_data << Trip.created_between(col[:start_time], col[:end_time]).count
        end
      end
      data << row_data
    end

    data
  end

  private

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
