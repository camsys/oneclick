class RenameZipAndCounty < ActiveRecord::Migration
  def up
    rename_column :geo_coverages, :zip, :value
    rename_column :geo_coverages, :county, :coverage_type
  end

  def down
    rename_column :geo_coverages, :value, :zip
    rename_column :geo_coverages, :coverage_type, :county
  end
end
