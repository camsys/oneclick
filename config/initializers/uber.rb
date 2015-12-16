$uber = Uber::Client.new do |config|
  config.server_token  = ENV['UBER_SERVER_TOKEN']
end

$uber_lat = ENV['UBER_LATITUDE'].try(:to_f) 
$uber_lon = ENV['UBER_LONGITUDE'].try(:to_f) 

$uber_waiting_time = ENV['UBER_WAITING_SECONDS'].try(:to_i)