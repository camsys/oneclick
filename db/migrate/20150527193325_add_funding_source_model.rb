class AddFundingSourceModel < ActiveRecord::Migration
  def change
    create_table :funding_sources do |t|
      t.string :code, null: false
      t.integer :index
      t.integer :service_id, null: false

      t.timestamps null: false
    end
  end
end
