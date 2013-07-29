require 'awesome_print'

class TripPlace < Place
  self.table_name = 'trip_places'

  belongs_to :trip

  before_save :do_before_save

  def do_before_save
    # if nongeocoded_address is numeric, assume it's a UserPlace id
    # verify that owner of UserPlace is same as owner of trip
    # copy the UserPlace to here
    # if not numeric, then geocode it? not sure if I want geocoding happening in
    # AR callbacks

    # Rails.logger.info "do_before_save"
    # log_stuff
    # if nongeocoded_address =~ %r{^[0-9]+$}
    #   user_place = UserPlace.find_by_id_and_user_id(nongeocoded_address.to_i, self.trip.owner.id)
    #   user_place.attributes.except('id', 'user_id', 'created_at', 'updated_at').each do |attr, value|
    #     self.send("#{attr}=", value)
    #   end
    # else
    #   geocode
    # end

    geocode! unless geocoded?
  end

  private

  def log_stuff
    Rails.logger.info self.ai
    Rails.logger.info nongeocoded_address.inspect
  end

end
