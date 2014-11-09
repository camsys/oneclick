class CreateWalkingSpeeds < ActiveRecord::Migration
  def change
    create_table :walking_speeds do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.float :value, null: false
      t.boolean :is_default, default: false
      
      t.timestamps
    end
    
    WalkingSpeed.create!(code: 'slow', name: 'Slow', value: 2)
    WalkingSpeed.create!(code: 'average', name: 'Average', value: 3, is_default: true)
    WalkingSpeed.create!(code: 'fast', name: 'Fast', value: 4)
  end
end
