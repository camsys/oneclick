class AddDisplayColorToServices < ActiveRecord::Migration
  def change
    add_column :services, :display_color, :string
  end
end
