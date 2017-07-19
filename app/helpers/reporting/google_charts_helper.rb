# A set of helpers for creating google charts reports in Rails.

module Reporting::GoogleChartsHelper

  # Helper Method sets up tick marks based on time unit
  def setup_tick_marks(date_range, time_unit)
    ticks = []
    year_range = date_range.begin.year..date_range.end.year
    date_range = date_range.begin.to_date..date_range.end.to_date
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

  # Returns a hash with default google charts config values, or overridden with options
  def build_google_charts_hash(opts={})
    {
      columns: [],
      rows: [],
      visualization: opts[:visualization] || 'ColumnChart',
      options: {
        title: opts[:title] || '',
        width: opts[:width] || 1000,
        height: opts[:height] || 600,
        hAxis: { ticks: [] },
        chartArea: {height: '80%'},
        isStacked: opts[:is_stacked] || true
      }
    }
  end

end
