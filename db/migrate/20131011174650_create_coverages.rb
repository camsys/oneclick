class CreateCoverages < ActiveRecord::Migration
  def up
    create_table :coverages do |t|
      t.string :zip
    end
  end

  def down
  end
end
