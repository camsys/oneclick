class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :sender, index: true
      t.text :body
      t.datetime :from_date
      t.datetime :to_date

      t.timestamps
    end
  end
end
