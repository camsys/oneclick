class CreateSponsorsTable < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.string :code, null: false
      t.integer :index
      t.integer :service_id, null: false
      t.timestamps null: false
    end
  end
end
