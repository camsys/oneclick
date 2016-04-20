class DropFeedbackTables < ActiveRecord::Migration
  def change
    drop_table :feedback_issues
    drop_table :feedback_issues_feedback_types
    drop_table :feedback_issues_feedbacks
    drop_table :feedback_ratings
    drop_table :feedback_ratings_feedback_types
    drop_table :feedback_ratings_feedbacks
    drop_table :feedback_statuses
    drop_table :feedback_types
    drop_table :feedbacks
  end
end
