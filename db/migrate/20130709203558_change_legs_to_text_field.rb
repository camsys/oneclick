class ChangeLegsToTextField < ActiveRecord::Migration

  def change
    change_column :itineraries, :legs, :text
  end

end
