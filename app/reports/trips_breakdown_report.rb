class TripsBreakdownReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    Rails.logger.info "TripsBreakdownReport"
    Rails.logger.info params.ai

    s = <<EOS
    select tp.scheduled_date, tc.code, utcm.value, count(1) from
    trips t
    join trip_parts tp on tp.trip_id=t.id
    join users u on t.user_id=u.id
    join user_profiles up on u.id=up.user_id
    join public.user_characteristics utcm on up.id=utcm.user_profile_id
    join public.traveler_characteristics tc on tc.id=utcm.characteristic_id
    where utcm.value='t'
    group by tp.scheduled_date, tc.code, utcm.value
    order by tp.scheduled_date
EOS

    c = ActiveRecord::Base.connection

    # we want to return:
    # for each time unit (say day), each of the characteristcs and the count

    result = c.execute s

    # a = {}
    # duration = TimeFilterHelper.time_filter_as_duration(params[:time_filter_type])
    # days = duration.first.to_date..duration.last.to_date
    # days.each do |day|

    #   row = BasicReportRow.new(day)
    #   # get the trips that were generated on this day
    #   trips = Trip.created_between(day.beginning_of_day, day.end_of_day)
    #   trips.each do |trip|
    #     row.add(trip)
    #   end     
    #   a[day] = row;      
    # end
    f = Hash.new {|h, k| h[k] = {}}
    result.each do |r|
      f[r['scheduled_date']][r['code']] = r['count']
    end
    return f.to_a

  end

end
