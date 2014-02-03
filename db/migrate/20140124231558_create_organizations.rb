class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :type
      t.integer :parent_id

      t.timestamps
    end
  end
end
