class ChangeFareDescToText < ActiveRecord::Migration
  def up
    change_column :fare_structures, :desc, :text
  end
  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :fare_structures, :desc, :string
  end
end
