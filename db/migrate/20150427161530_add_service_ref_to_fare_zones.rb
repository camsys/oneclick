class AddServiceRefToFareZones < ActiveRecord::Migration
  def change
    add_reference :fare_zones, :service, index: true
  end
end
