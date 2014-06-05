class AddApprovedToRatings < ActiveRecord::Migration
  def up
    add_column :ratings, :approved, :boolean

    Rating.update_all approved: true
    change_column :ratings, :approved, :boolean, :null => false, default: false

  end

  def down
    remove_column :ratings, :approved, :boolean
  end
end
