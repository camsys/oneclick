class AddDisallowedPurposesToService < ActiveRecord::Migration
  def change
    add_column :services, :disallowed_purposes, :text
  end
end
