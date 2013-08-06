class AddModelParamsToReport < ActiveRecord::Migration
  def change
    add_column :reports, :view_name, :string
    add_column :reports, :class_name, :string
    add_column :reports, :active, :boolean
  end
end
