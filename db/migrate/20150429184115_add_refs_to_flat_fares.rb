class AddRefsToFlatFares < ActiveRecord::Migration
  def change
    add_reference :flat_fares, :characteristic, index: true
    add_reference :flat_fares, :trip_purpose, index: true
    add_column :flat_fares, :char_base_value, :string
    add_column :flat_fares, :char_complementary_value, :string
  end
end
