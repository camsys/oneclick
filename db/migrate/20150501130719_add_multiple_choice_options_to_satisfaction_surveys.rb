class AddMultipleChoiceOptionsToSatisfactionSurveys < ActiveRecord::Migration
  def change
    add_column :satisfaction_surveys, :reasoning, :text
  end
end
