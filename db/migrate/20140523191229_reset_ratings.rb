class ResetRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :user
      t.references :rateable, :polymorphic => true
      t.integer :value, :null => false
      t.text :comments
      t.timestamps
    end

    drop_table :rates
    remove_column :trips, :user_comments
    remove_column :trips, :rating
  end
end
