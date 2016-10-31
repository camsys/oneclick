class AddCoveragesToServices < ActiveRecord::Migration
  def change
    add_reference :services, :primary_coverage, references: :coverages, index: true
    add_reference :services, :secondary_coverage, references: :coverages, index: true
  end
end
