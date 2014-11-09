class AddSidewalkObstructions < ActiveRecord::Migration
  def change
  	create_table :sidewalk_obstructions do |t|
      t.belongs_to :user, null: false
      t.float :lat, null: false
      t.float :lon, null: false
      t.string :comment, null: false
      t.datetime :removed_at
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end