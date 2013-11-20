class AddFareRules < ActiveRecord::Migration

  def up
    add_column :fare_structures, :fare_type, :integer, :default => 0
    add_column :fare_structures, :base, :decimal, :precision => 6, :scale => 2
    add_column :fare_structures, :rate, :decimal, :precision => 6, :scale => 2
    add_column :fare_structures, :desc, :string
  end

  def down
    remove_column :fare_structures, :fare_type
    remove_column :fare_structures, :base
    remove_column :fare_structures, :rate
    remove_column :fare_structures, :desc
  end

end

