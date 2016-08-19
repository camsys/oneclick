class RemoveLongIndexNamesIi < ActiveRecord::Migration
  def change
    remove_index(:flat_fares, :name => 'index_flat_fares_on_fare_structure_id')
  end
end
