class DropPrimaryCoveragesTable < ActiveRecord::Migration
  def up
    drop_table :primary_coverages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
