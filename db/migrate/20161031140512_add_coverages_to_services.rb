class AddCoveragesToServices < ActiveRecord::Migration
  def change
    add_reference :services, :primary_coverage, references: :coverage_areas, index: true
    add_foreign_key :services, :coverage_areas, column: :primary_coverage_id
    add_reference :services, :secondary_coverage, references: :coverage_areas, index: true
    add_foreign_key :services, :coverage_areas, column: :secondary_coverage_id
  end
end
