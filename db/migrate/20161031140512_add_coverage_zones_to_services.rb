class AddCoverageZonesToServices < ActiveRecord::Migration
  def change
    add_reference :services, :primary_coverage, references: :coverage_zones, index: true
    add_reference :services, :secondary_coverage, references: :coverage_zones, index: true
  end
end
