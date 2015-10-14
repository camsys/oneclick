class RidepilotProfile < ActiveRecord::Base
  belongs_to :service

  def authenticate
    bs = BookingServices.new
    bs.authenticate_provider_from_profile self
  end

end
