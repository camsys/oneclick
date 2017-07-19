require 'active_support/concern'

module Encryption

  def encryption_key
    # if in production. require key to be set.
    if Rails.env.production?
      raise 'Must set token key!!' unless ENV['BOOKING_PASSWORD_TOKEN_KEY']
      ENV['BOOKING_PASSWORD_TOKEN_KEY']
    else
      ENV['BOOKING_PASSWORD_TOKEN_KEY'] ? ENV['BOOKING_PASSWORD_TOKEN_KEY'] : 'test'
    end
  end

end