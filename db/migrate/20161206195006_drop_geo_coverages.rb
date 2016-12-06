class DropGeoCoverages < ActiveRecord::Migration
  def change
    #This task implements the streamlined Provider and Service Data Admin UI, copying over data from the old geometries.
    Rake::Task["oneclick:one_offs:migrate_to_new_service_data_ui"].invoke

    # Now that data is copied over, may drop the tables.
    drop_table :geo_coverages
  end
end
