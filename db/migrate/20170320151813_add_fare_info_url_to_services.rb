class AddFareInfoUrlToServices < ActiveRecord::Migration
  def change
    add_column :services, :fare_info_url, :string
  end
end
