class AddFactorsToService < ActiveRecord::Migration
  def change
    add_column :services, :service_window, :integer
    add_column :services, :time_factor, :float
  end
end
