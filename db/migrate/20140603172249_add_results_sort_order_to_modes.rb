class AddResultsSortOrderToModes < ActiveRecord::Migration
  def change
    add_column :modes, :results_sort_order, :integer
  end
end
