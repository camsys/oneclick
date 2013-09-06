class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :category
      t.string :name
      t.string :value
      t.integer :sort_order

      t.timestamps
    end
  end
end
