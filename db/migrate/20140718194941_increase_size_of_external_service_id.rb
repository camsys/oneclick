class IncreaseSizeOfExternalServiceId < ActiveRecord::Migration
  def change
    change_column :services, :external_id, :string, :limit => 100
  end
end
