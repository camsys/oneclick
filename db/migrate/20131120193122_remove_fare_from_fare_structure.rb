class RemoveFareFromFareStructure < ActiveRecord::Migration
  def change
    remove_column :fare_structures, :fare
  end
end
