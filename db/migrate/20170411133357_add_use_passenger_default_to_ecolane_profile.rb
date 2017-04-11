class AddUsePassengerDefaultToEcolaneProfile < ActiveRecord::Migration
  def change
    add_column :ecolane_profiles, :use_customer_default, :boolean, default: true
  end
end
