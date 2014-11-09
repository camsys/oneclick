class LocalizedComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :comment
      t.string :locale
      t.string :visibility, default: 'public'
      t.integer :commentable_id
      t.string :commentable_type

      t.timestamps
    end
    rename_column :agencies, :public_comments, :public_comments_old
    rename_column :agencies, :private_comments, :private_comments_old

    rename_column :providers, :public_comments, :public_comments_old
    rename_column :providers, :private_comments, :private_comments_old

    rename_column :services, :public_comments, :public_comments_old
    rename_column :services, :private_comments, :private_comments_old

  end
end
