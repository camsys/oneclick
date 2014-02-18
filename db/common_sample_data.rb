require 'lorem-ipsum'

#encoding: utf-8
def update_reports
  reports = [
    {name: 'Trips Created', description: 'Displays a chart showing the number of trips created each day.', view_name: 'generic_report', class_name: 'TripsCreatedByDayReport', active: 1},
    {name: 'Trips Scheduled', description: 'Displays a chart showing the number of trips scheduled for each day.', view_name: 'generic_report', class_name: 'TripsScheduledByDayReport', active: 1},
    {name: 'Failed Trips', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1},
    {name: 'Rejected Trips', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1},
    {name: 'Trips Planned', description: 'Trips planned with various breakdowns.', view_name: 'breakdown_report', class_name: 'TripsBreakdownReport', active: 1}
  ]

  %w{reports}.each do |table_name|
    puts "Truncating table #{table_name}"
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
  end

  # load the reports
  reports.each do |rep|
    r = Report.new(rep)
    puts "Loading report #{r.name}"
    r.save!
  end
end

def load_pois
  require 'csv'
  return
  filename  = ENV['FILENAME']
  # FILENAME = File.join(Rails.root, 'db', 'arc_poi_data', 'CommFacil_20131015.txt')

  puts
  puts "Loading POI and POI TYPES from file '#{filename}'"
  puts "Starting at: #{Time.now}"

  # Delete existing POIs by truncating the tables
  #%w{poi_types pois}.each do |table_name|
  #  puts "Truncating table #{table_name}"
  #  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
  #end

  count_good = 0
  count_bad = 0
  count_failed = 0
  count_poi_type = 0

  File.open(filename) do |f|

    CSV.foreach(f, {:col_sep => "\t", :headers => true}) do |row|

      poi_type_name = row[13]
      if poi_type_name.blank?
        poi_type_name = 'Unknown'
      end
      poi_type = PoiType.find_by_name(poi_type_name)
      if poi_type.nil?
        puts "Adding new poi type #{poi_type_name}"
        poi_type = PoiType.create!({:name => poi_type_name, :active => true})
        count_poi_type += 1
      end
      if poi_type

        #If we have already created this POI, don't create it again.
        p = Poi.find_by_name(row[3])
        unless p.nil?
          return
        end

        p = Poi.new
        p.poi_type = poi_type
        p.lon = row[1]
        p.lat = row[2]
        p.name = row[3]
        p.address1 = row[4]
        p.address2 = row[5]
        p.city = row[6]
        p.state = 'GA'
        p.zip = row[8]
        p.county = row[12]
        begin
          if p.name && row[2] != "0.0"
            p.save!
            count_good += 1
          else
            count_bad += 1
          end
        rescue Exception => e
          puts "Failed to save: #{e.message} for #{p.ai}"
          count_failed += 1
        end
      else
        puts ">>> Can't find POI type '#{poi_type_name}'"
      end
    end
  end
  puts
  puts "Loaded #{count_poi_type} POI Types and #{count_good} POIs. #{count_bad} were skipped, #{count_failed} failed to save."
end

def generate_trips
  #Check to see if we already have a large set of users
  if User.all.count >= 100
    return
  end

  users = (1..100).each.collect do |i|
    random_string = ((0...16).map { (65 + rand(26)).chr }.join)
    u = User.new
    u.first_name = "Visitor"
    u.last_name = "Guest"
    u.password = random_string
    u.email = "guest_#{random_string}@example.com"
    u.save!(:validate => false)
    Rails.logger.info "Generated user"
    u
  end
  users.each do |u|
    u.user_profile.traveler_characteristics.create! traveler_characteristic: Characteristic.where(datatype: 'bool').sample,
    value: [true, false].sample
    u.user_profile.traveler_characteristics.create! traveler_characteristic: Characteristic.where(datatype: 'bool').sample,
    value: [true, false].sample
    u.user_profile.traveler_characteristics.create! traveler_characteristic: Characteristic.where(datatype: 'bool').sample,
    value: [true, false].sample
    Rails.logger.info "Added characterstics to user"
  end
  users.each_with_index do |u, ui|
    d = Date.today + rand(-30..30).days
    (1..100).each do |i|
      text_size = rand(200)
      t = u.trips.create! trip_purpose: TripPurpose.all.sample,
      user_comments: LoremIpsum.generate.truncate(text_size, omission: '').split.sample(text_size).join(' '),
      taken: [true, false].sample,
      rating: [nil, [*0..5]].flatten.sample
      t.trip_parts.create! from_trip_place: TripPlace.all.sample, to_trip_place: TripPlace.all.sample, sequence: 0,
      scheduled_date: (d + rand(-5..5).days), scheduled_time: Time.now
      Rails.logger.info "Added trip #{i} to user #{ui}"
    end
  end
end

def populate_provider_orgs
  Provider.all.each do |p|
    unless p.provider_org.nil?
      next
    end
    p.create_provider_org! name: p.name
    p.save!
  end
end

update_reports
load_pois
generate_trips
populate_provider_orgs