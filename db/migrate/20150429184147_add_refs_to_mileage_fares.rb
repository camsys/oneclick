class AddRefsToMileageFares < ActiveRecord::Migration
  def change
    add_reference :mileage_fares, :characteristic, index: true
    add_reference :mileage_fares, :trip_purpose, index: true
    add_column :mileage_fares, :char_base_value, :string
    add_column :mileage_fares, :char_complementary_value, :string
  end
end
