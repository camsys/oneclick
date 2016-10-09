class AddFreshnessToCharacteristics < ActiveRecord::Migration
  def change
    add_column :characteristics, :freshness_seconds, :int
    add_column :user_characteristics, :created_at, :datetime
    add_column :user_characteristics, :updated_at, :datetime
  end
end
