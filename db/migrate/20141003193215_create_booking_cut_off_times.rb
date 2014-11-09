class CreateBookingCutOffTimes < ActiveRecord::Migration
  def change
    create_table :booking_cut_off_times do |t|
      t.belongs_to :service, null: false
      t.integer  "day_of_week", null: false
      t.boolean  "active", default: true, null: false
      t.integer  "cut_off_seconds", null: false

      t.timestamps
    end
  end
end
