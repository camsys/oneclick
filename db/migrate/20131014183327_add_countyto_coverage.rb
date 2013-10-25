class AddCountytoCoverage < ActiveRecord::Migration
  def up
    add_column :coverages, :county, :string, :limit => 128
  end

  def down
    remove_column :coverages, :county
  end
end
