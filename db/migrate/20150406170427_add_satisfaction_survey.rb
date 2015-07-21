class AddSatisfactionSurvey < ActiveRecord::Migration
  def change
    create_table :satisfaction_surveys do |t|
      t.belongs_to :trip, null: false
      t.boolean  :satisfied, null: false
      t.text  :comment, null: false
      t.timestamps
    end
  end
end
