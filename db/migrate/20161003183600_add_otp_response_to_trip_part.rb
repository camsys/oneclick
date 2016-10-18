class AddOtpResponseToTripPart < ActiveRecord::Migration
  def change
    add_column :trip_parts, :otp_response, :text
  end
end
