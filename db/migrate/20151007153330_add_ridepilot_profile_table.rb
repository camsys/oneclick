class AddRidepilotProfileTable < ActiveRecord::Migration
  def change
    create_table :ridepilot_profiles do |t|
      t.string :endpoint
      t.string :api_token
      t.string :provider_id
      t.integer :service_id
      t.timestamps
    end
  end
end
