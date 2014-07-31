class AddCodeToCodelessModels < ActiveRecord::Migration
  def change
    add_column :trip_statuses, :code, :string
    add_column :modes, :code, :string
    add_column :relationship_statuses, :code, :string
  end
end
