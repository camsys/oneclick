class CreateTrapezeProfiles < ActiveRecord::Migration
  def change
    create_table :trapeze_profiles do |t|
      t.string :endpoint
      t.string :username
      t.string :password
      t.integer :service_id
      t.timestamps
    end
  end
end
