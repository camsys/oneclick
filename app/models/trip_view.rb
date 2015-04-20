## This is a view model class for trips
## Based on a sql view "v_Trips"
## Used to show, search, and sort admin/provider/agency/user trips
class TripView < ActiveRecord::Base

  scope :by_provider, ->(p) { where('provider_id' => p) }

  scope :by_agency, ->(a) { where('agency_id' => a) }

  scope :by_user, ->(u) { where('user_id' => u) }

  # configure table/view name
  self.table_name = "v_Trips"

  # case insensitive search and sort
  ransacker :user_name_case_insensitive, type: :string do
    arel_table[:user_name].lower
  end

  # in case a different id column being used
  def self.id_column
    'id'
  end

  # model should be readonly (since this is a reporting tool)
  def readonly?
    true
  end

end