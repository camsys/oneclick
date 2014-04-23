class CreateUserService < ActiveRecord::Migration
  def change
    create_table :user_services do |t|
      t.integer :user_profile_id, null: false
      t.integer :service_id, null: false
      t.string :external_user_id, null: false
      t.boolean :disabled, null: false, default: false
    end
  end
end
