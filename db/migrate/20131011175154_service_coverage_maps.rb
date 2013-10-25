class ServiceCoverageMaps < ActiveRecord::Migration
  def up
    create_table :service_coverage_maps do |t|
      t.integer :service_id
      t.integer :coverage_id
      t.string  :rule
    end
  end

  def down
  end
end
