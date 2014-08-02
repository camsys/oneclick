class MoveGeometriesOutOfServices < ActiveRecord::Migration
  def up
    add_column :services, :endpoint_area_geom_id, :integer
    add_column :services, :coverage_area_geom_id, :integer
    add_column :services, :residence_area_geom_id, :integer
    Service.all.each do |s|
      next if s.coverage_area.nil? and s.endpoint_area.nil? and s.residence.nil?
      unless s.endpoint_area.nil?
        gc = GeoCoverage.create! coverage_type: 'endpoint_area', geom: s.endpoint_area
        s.update_attributes! endpoint_area_geom: gc
      end
      unless s.coverage_area.nil?
        gc = GeoCoverage.create! coverage_type: 'coverage_area', geom: s.coverage_area
        s.update_attributes! coverage_area_geom: gc
      end
      unless s.residence.nil?
        gc = GeoCoverage.create! coverage_type: 'residence_area', geom: s.residence
        s.update_attributes! residence_area_geom: gc
      end
    end
    remove_column :services, :endpoint_area
    remove_column :services, :coverage_area
    remove_column :services, :residence
  end

  def down
    add_column :services, :endpoint_area, :geometry
    add_column :services, :coverage_area, :geometry
    add_column :services, :residence, :geometry
    Service.all.each do |s|
      next if s.coverage_area_geom.nil? and s.endpoint_area_geom.nil? and s.residence_area_geom.nil?
      unless s.endpoint_area_geom.nil?
        s.update_attributes! endpoint_area: s.endpoint_area_geom.geom
        s.endpoint_area_geom.destroy
      end
      unless s.coverage_area_geom.nil?
        s.update_attributes! coverage_area: s.coverage_area_geom.geom
        s.coverage_area_geom.destroy
      end
      unless s.residence_area_geom.nil?
        s.update_attributes! residence: s.residence_area_geom.geom
        s.residence_area_geom.destroy
      end
    end
    remove_column :services, :endpoint_area_geom_id
    remove_column :services, :coverage_area_geom_id
    remove_column :services, :residence_area_geom_id
  end

end
