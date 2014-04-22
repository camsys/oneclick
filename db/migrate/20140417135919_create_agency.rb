class CreateAgency < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name, limit: 64
      t.string :address, limit: 100
      t.string :city, limit: 100
      t.string :state, limit: 64
      t.string :zip, limit: 10
      t.string :phone, limit: 25
      t.string :email
      t.string :url
      t.integer :parent_id
    end
  end
end
