class RemoveNullConstraintFromSatisfactionSurveyComments < ActiveRecord::Migration
  def change
    change_column :satisfaction_surveys, :comment, :text, null: true
  end
end
