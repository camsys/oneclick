class AddGeocodeResultType < ActiveRecord::Migration
  def change
    add_column :trip_places, :result_types, :string
  end
end
