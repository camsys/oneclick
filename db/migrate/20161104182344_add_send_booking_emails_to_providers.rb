class AddSendBookingEmailsToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :send_booking_emails, :boolean
  end
end
