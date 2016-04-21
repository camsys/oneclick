class RemoveLongIndexNames < ActiveRecord::Migration
  def change
    remove_index(:flat_fares, :name => 'index_flat_fares_on_fare_structure_id')
    remove_index(:mileage_fares, :name => 'index_mileage_fares_on_fare_structure_id')
    remove_index(:roles, :name => 'index_roles_on_name_and_resource_type_and_resource_id')
    #remove_index(:service_users, :name => 'index_services_users_on_service_id_and_user_id')
    remove_index(:trip_parts, :name => 'index_trip_parts_on_trip_id_and_sequence')
    remove_index(:users, :name => 'index_users_on_authentication_token')
    remove_index(:users, :name => 'index_users_on_reset_password_token')
    remove_index(:zone_fares, :name => 'index_zone_fares_on_fare_structure_id')
    remove_index(:zone_fares, :name => 'index_zone_fares_on_from_zone_id')
    remove_index(:zone_fares, :name => 'index_zone_fares_on_to_zone_id')

    drop_table :user_messages
  end
end
