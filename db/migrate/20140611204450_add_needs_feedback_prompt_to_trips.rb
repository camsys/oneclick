class AddNeedsFeedbackPromptToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :needs_feedback_prompt, :boolean
  end
end
