class DropOrganization < ActiveRecord::Migration
  def up
    drop_table :organizations
  end

  def down
    create_table :organizations do |t|
      t.string :name
      t.string :type
      t.integer :parent_id

      t.timestamps
    end
  end
end
