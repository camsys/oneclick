class AddStopCodeToPoi < ActiveRecord::Migration
  def change
    add_column :pois, :stop_code, :string
  end
end
