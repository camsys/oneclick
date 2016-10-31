class AddCoveragesToServices < ActiveRecord::Migration
  def change
    add_reference :services, :primary_coverage, references: :coverages, index: true
    add_foreign_key :services, :coverages, column: :primary_coverage_id
    add_reference :services, :secondary_coverage, references: :coverages, index: true
    add_foreign_key :services, :coverages, column: :secondary_coverage_id
  end
end
