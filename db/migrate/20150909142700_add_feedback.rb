class AddFeedback < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :user_email      
      t.references :user
      t.references :trip
      t.references :feedback_type
      t.references :feedback_rating
      t.references :feedback_issue
      t.references :feedback_status
      t.text :comment
      t.float :average_rating

      t.timestamps
    end

    create_table :feedback_types do |t|
      t.string :name
    end
    create_table :feedback_ratings do |t|
      t.string :name
    end
    create_table :feedback_issues do |t|
      t.string :name
    end
    create_table :feedback_statuses do |t|
      t.string :name
    end

    create_join_table :feedbacks, :feedback_issues do |t|
      t.primary_key :id
      t.boolean :value
    end
    create_join_table :feedbacks, :feedback_ratings do |t|
      t.primary_key :id
      t.integer :value
    end
    create_join_table :feedback_types, :feedback_issues
    create_join_table :feedback_types, :feedback_ratings
  end
end
