class CreateDateOptions < ActiveRecord::Migration
  def change
    create_table :date_options do |t|
      t.string :name
      t.string :code
      t.string :start_date
      t.string :end_date

      t.timestamps
    end
  end
end
