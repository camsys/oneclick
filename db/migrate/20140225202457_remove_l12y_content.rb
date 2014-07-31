class RemoveL12yContent < ActiveRecord::Migration
  def change

    drop_table :l12y_contents

    add_column :translations, :locale, :string
    add_column :translations, :value, :text
  end
end
