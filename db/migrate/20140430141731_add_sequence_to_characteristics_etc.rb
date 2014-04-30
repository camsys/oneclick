class AddSequenceToCharacteristicsEtc < ActiveRecord::Migration
  def change
    add_column :characteristics, :sequence, :integer, default: 0
    add_column :accommodations, :sequence, :integer, default: 0
  end
end
