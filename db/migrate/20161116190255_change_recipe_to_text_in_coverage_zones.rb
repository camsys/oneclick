class ChangeRecipeToTextInCoverageZones < ActiveRecord::Migration
  def up
    change_column :coverage_zones, :recipe, :text
  end

  def down
    change_column :coverage_zones, :recipe, :string
  end
end
