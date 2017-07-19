require 'capybara/poltergeist'

class PrintMapWorker
  include Sidekiq::Worker

  def perform(print_url, itinerary_id)
    Rails.logger.info "PrintMapWorker#perform, print_url=#{print_url}"

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app,
        :phantomjs_options => ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'], 
        :debug => false,
        :js_errors => false)
    end

    session = Capybara::Session.new :poltergeist
    tempfile = Tempfile.new(['itinerary_map','.png'])

    session.visit(print_url)
    sleep 2
    session.driver.render(tempfile.path, selector: '#map_container')

    i = Itinerary.find(itinerary_id)
    i.map_image = File.open(tempfile)

    Rails.logger.info "Map IMAGE DONE"
    Rails.logger.info (i.map_image.url)
    i.save!
  ensure
    session.driver.quit
  end
end
