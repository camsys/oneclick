class CreateWalkingMaximumDistances < ActiveRecord::Migration
  def change
    create_table :walking_maximum_distances do |t|
      t.float :value, null: false
      t.boolean :is_default, default: false
      
      t.timestamps
    end
    
    WalkingMaximumDistance.create!(value: 0.25)
    WalkingMaximumDistance.create!(value: 0.5)
    WalkingMaximumDistance.create!(value: 0.75)
    WalkingMaximumDistance.create!(value: 1)
    WalkingMaximumDistance.create!(value: 1.5)
    WalkingMaximumDistance.create!(value: 2, is_default: true)
    WalkingMaximumDistance.create!(value: 3)
    WalkingMaximumDistance.create!(value: 4)
  end
end
