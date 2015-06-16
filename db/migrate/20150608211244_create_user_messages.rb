class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.references :recipient, index: true
      t.references :message, index: true
      t.boolean :read

      t.timestamps
    end
  end
end
