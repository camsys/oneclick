class AddRefsToZoneFares < ActiveRecord::Migration
  def change
    add_reference :zone_fares, :characteristic, index: true
    add_reference :zone_fares, :trip_purpose, index: true
    add_column :zone_fares, :char_base_value, :string
    add_column :zone_fares, :char_complementary_value, :string
  end
end
