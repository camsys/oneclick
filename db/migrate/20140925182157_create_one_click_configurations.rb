class CreateOneClickConfigurations < ActiveRecord::Migration
  def change
    create_table :oneclick_configurations do |t|
      t.string :code
      t.text :value
      t.text :description
      t.timestamps
    end
  end
end
