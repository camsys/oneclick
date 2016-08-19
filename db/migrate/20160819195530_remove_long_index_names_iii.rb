class RemoveLongIndexNamesIii < ActiveRecord::Migration
  def change
    remove_index(:fare_zones, :name => 'index_fare_zones_on_service_id')
    remove_index(:mileage_fares, :name => 'index_mileage_fares_on_fare_structure_id')
    remove_index(:users, :name => 'index_users_on_authentication_token')
    remove_index(:users, :name => 'index_users_on_reset_password_token')
    remove_index(:zone_fares, :name => 'index_zone_fares_on_fare_structure_id')
    remove_index(:zone_fares, :name => 'index_zone_fares_on_from_zone_id')
    remove_index(:zone_fares, :name => 'index_zone_fares_on_to_zone_id')

    drop_table :reporting_specific_filter_groups
  end
end
