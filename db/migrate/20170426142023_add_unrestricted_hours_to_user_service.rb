class AddUnrestrictedHoursToUserService < ActiveRecord::Migration
  def change
    add_column :user_services, :unrestricted_hours, :boolean, default: false
  end
end
