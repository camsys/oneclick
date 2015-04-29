class CreateMileageFares < ActiveRecord::Migration
  def change
    create_table :mileage_fares do |t|
      t.float :base_rate
      t.float :mileage_rate
      t.references :fare_structure, index: true

      t.timestamps
    end
  end
end
