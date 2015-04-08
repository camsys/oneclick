puts 'Pilot period: 8/18/14 to 1/16/15'
start_date = Date.new(2014, 8, 14).at_beginning_of_day
end_date = Date.new(2015, 1, 16).at_end_of_day
total_days = (end_date.to_date - start_date.to_date).to_i + 1

puts 'Number of page views (pilot totals and daily averages)' 
registered_user_sign_in_count = User.registered.where("users.created_at <= ?", end_date).sum(:sign_in_count)
guest_user_count = User.with_role(:anonymous_traveler).where("users.created_at >= ? and users.created_at <= ?", start_date, end_date).count
total_page_views = registered_user_sign_in_count + guest_user_count

puts 'Number of started sessions (pilot totals and daily averages) by ui_mode' 
base_started_sessions = Trip.created_between(start_date, end_date);
desktop_started_sessions = base_started_sessions.where(ui_mode: 'desktop').count
tablet_started_sessions = base_started_sessions.where(ui_mode: 'tablet').count
phone_started_sessions = base_started_sessions.where(ui_mode: 'phone').count
kiosk_started_sessions = base_started_sessions.where(ui_mode: 'kiosk').count


puts 'Number of created trips by ui_mode'
base_created_trips = Itinerary.includes(trip_part: :trip).where("trips.created_at >= ? and trips.created_at <= ?",start_date, end_date);
desktop_created_trips = base_created_trips.where("trips.ui_mode = ?", :desktop).group("trips.id").count.count
tablet_created_trips = base_created_trips.where("trips.ui_mode = ?", :tablet).group("trips.id").count.count
phone_created_trips = base_created_trips.where("trips.ui_mode = ?", :phone).group("trips.id").count.count
kiosk_created_trips = base_created_trips.where("trips.ui_mode = ?", :kiosk).group("trips.id").count.count

puts 'Number of planned trips by ui_mode'
base_planned_trips = Trip.planned_between(start_date, end_date)
desktop_planned_desktop = base_planned_trips.where(ui_mode: 'desktop').count
tablet_planned_desktop = base_planned_trips.where(ui_mode: 'tablet').count
phone_planned_desktop = base_planned_trips.where(ui_mode: 'phone').count
kiosk_planned_desktop = base_planned_trips.where(ui_mode: 'kiosk').count

puts 'Number of booked trips (pilot total) by ui_mode'
in_range_itin = Itinerary.where("itineraries.created_at >= ? and itineraries.created_at <= ?", start_date, end_date);
base_booked_legs = in_range_itin.includes(trip_part: :trip).where.not(booking_confirmation: nil).references(trip_part: :trip).uniq("trips.id");
base_desktop_booked_legs = base_booked_legs.where("trips.ui_mode = ?", :desktop).count
base_tablet_booked_legs = base_booked_legs.where("trips.ui_mode = ?", :tablet).count
base_phone_booked_legs = base_booked_legs.where("trips.ui_mode = ?", :phone).count
base_kiosk_booked_legs = base_booked_legs.where("trips.ui_mode = ?", :kiosk).count

  
puts 'Trip itineraries (pilot total, fixed route, and demand responsive) by ui_mode'
base_itins = in_range_itin.includes(trip_part: :trip).references(trip_part: :trip);
fixed_route_itins = base_itins.includes(:mode).references(:mode).where("modes.code = ?", :mode_transit);
fixed_route_itins_count = fixed_route_itins.count
desktop_fixed_route_itins = fixed_route_itins.where("trips.ui_mode = ?", :desktop).count
tablet_fixed_route_itins = fixed_route_itins.where("trips.ui_mode = ?", :tablet).count
phone_fixed_route_itins = fixed_route_itins.where("trips.ui_mode = ?", :phone).count
kiosk_fixed_route_itins = fixed_route_itins.where("trips.ui_mode = ?", :kiosk).count

paratransit_itins = base_itins.includes(:mode).references(:mode).where("modes.code = ?", :mode_paratransit);
paratransit_itins_count = paratransit_itins.count
desktop_paratransit_itins = paratransit_itins.where("trips.ui_mode = ?", :desktop).count
tablet_paratransit_itins = paratransit_itins.where("trips.ui_mode = ?", :tablet).count
phone_paratransit_itins = paratransit_itins.where("trips.ui_mode = ?", :phone).count
kiosk_paratransit_itins = paratransit_itins.where("trips.ui_mode = ?", :kiosk).count


puts 'Usage time (start session to planned trip) by ui_mode'
def get_planning_times(planned_trips)
  start_create_durations = []
  create_plan_durations = []
  start_plan_durations = []
  planned_trips.each do |t|
    t_started_at = t.created_at
    t_created_at = nil
    t_planned_at = nil
    t.trip_parts.each do |tp|
      first_it = tp.itineraries.order(:created_at).first
      if first_it
        first_it_created_at = first_it.created_at
        if !t_created_at || t_created_at > first_it_created_at
          t_created_at = first_it_created_at
        end
      else
        puts "#{tp.id} first itin is nil"
      end

      last_it = tp.itineraries.selected.order(:updated_at).last
      if last_it
        last_it_selected_at = last_it.updated_at
        if !t_planned_at || t_planned_at < last_it_selected_at
          t_planned_at = last_it_selected_at
        end
      else
        puts "#{tp.id} last selected itin is nil"
      end
    end


    start_create_durations << ((t_created_at.to_datetime - t_started_at.to_datetime) * 24 * 60 * 60).to_i
    create_plan_durations << ((t_planned_at.to_datetime - t_created_at.to_datetime) * 24 * 60 * 60).to_i
    start_plan_durations << ((t_planned_at.to_datetime - t_started_at.to_datetime) * 24 * 60 * 60).to_i
  end

  avg_start_create_duration = start_create_durations.sum / start_create_durations.count if start_create_durations.count > 0
  avg_create_plan_duration = create_plan_durations.sum / create_plan_durations.count if create_plan_durations.count > 0
  avg_start_plan_duration = start_plan_durations.sum / start_plan_durations.count if start_plan_durations.count > 0

  {
    start_create: avg_start_create_duration,
    create_plan: avg_create_plan_duration,
    start_plan: avg_start_plan_duration
  }
end

get_planning_times(base_planned_trips)
get_planning_times(base_planned_trips.where(ui_mode: :desktop))
get_planning_times(base_planned_trips.where(ui_mode: :tablet))
get_planning_times(base_planned_trips.where(ui_mode: :phone))
get_planning_times(base_planned_trips.where(ui_mode: :kiosk))

puts 'Average age of user' 
age_char = Characteristic.unscoped.where(code: 'age').first
dob_char = Characteristic.unscoped.where(code: 'date_of_birth').first
## Registered User -> UserProfile.each -> get age_char && dob_char -> find out what the real age is
user_base = User.registered.where("users.created_at >= ? and users.created_at <= ?", start_date, end_date);
ages = []
user_base.each do |u|
  user_chars = u.user_profile.user_characteristics
  user_age_char = user_chars.where(characteristic_id: age_char.id).first if age_char
  
  if user_age_char && !user_age_char.value.blank?
    age_v = user_age_char.value
    if age_v.length == 4
      age = Date.today.year  - age_v.to_i
    else
      age = age_v.to_i
    end
  end

  if !age || age <= 0
    user_dob_char = user_chars.where(characteristic_id: dob_char.id).first if dob_char
    if user_dob_char && !user_dob_char.value.blank?
      begin
        dob = Chronic.parse(user_dob_char.value)
        age = Date.today.year - dob.year
      rescue Exception => ex
        age = nil
      end
    end
  end

  ages << age if age && age > 0
end

if ages.count > 0
  avg_age = ages.sum / ages.count
end


puts 'Trip type (one-way, round-trip) by ui_mode'
base_trip_count_with_trip_type = TripPart.includes(:trip).references(:trip).created_between(start_date, end_date).group("trips.id").reorder('').count
desktop_trip_count_with_trip_type = TripPart.includes(:trip).references(:trip).created_between(start_date, end_date).where("trips.ui_mode = ?", :desktop).group("trips.id").reorder('').count
tablet_trip_count_with_trip_type = TripPart.includes(:trip).references(:trip).created_between(start_date, end_date).where("trips.ui_mode = ?", :tablet).group("trips.id").reorder('').count
phone_trip_count_with_trip_type = TripPart.includes(:trip).references(:trip).created_between(start_date, end_date).where("trips.ui_mode = ?", :phone).group("trips.id").reorder('').count
kiosk_trip_count_with_trip_type = TripPart.includes(:trip).references(:trip).created_between(start_date, end_date).where("trips.ui_mode = ?", :kiosk).group("trips.id").reorder('').count
base_trips_one_way_count = base_trip_count_with_trip_type.select {|k, v| v == 1}.count
desktop_trips_one_way_count = desktop_trip_count_with_trip_type.select {|k, v| v == 1}.count
tablet_trips_one_way_count = tablet_trip_count_with_trip_type.select {|k, v| v == 1}.count
phone_trips_one_way_count = phone_trip_count_with_trip_type.select {|k, v| v == 1}.count
kiosk_trips_one_way_count = kiosk_trip_count_with_trip_type.select {|k, v| v == 1}.count

base_trips_two_way_count = base_trip_count_with_trip_type.select {|k, v| v == 2}.count
desktop_trips_two_way_count = desktop_trip_count_with_trip_type.select {|k, v| v == 2}.count
tablet_trips_two_way_count = tablet_trip_count_with_trip_type.select {|k, v| v == 2}.count
phone_trips_two_way_count = phone_trip_count_with_trip_type.select {|k, v| v == 2}.count
kiosk_trips_two_way_count = kiosk_trip_count_with_trip_type.select {|k, v| v == 2}.count