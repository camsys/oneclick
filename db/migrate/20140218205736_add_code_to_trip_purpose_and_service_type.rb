class AddCodeToTripPurposeAndServiceType < ActiveRecord::Migration
  def change
    add_column :trip_purposes, :code, :string
    add_column :service_types, :code, :string
  end
end
