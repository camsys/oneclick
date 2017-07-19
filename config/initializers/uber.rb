$uber = Uber::Client.new do |config|
  config.server_token  = ENV['UBER_SERVER_TOKEN']
  config.client_id     = ENV['UBER_CLIENT_ID']
  config.client_secret = ENV['UBER_CLIENT_SECRET']
end

$uber_waiting_time = ENV['UBER_WAITING_SECONDS'].try(:to_i)