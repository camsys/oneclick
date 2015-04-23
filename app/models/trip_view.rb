## This is a view model class for trips
## Based on a sql view "v_Trips"
## Used to show, search, and sort admin/provider/agency/user trips
class TripView < ActiveRecord::Base

  scope :by_provider, ->(p) { where('provider_id' => p) }

  scope :by_agency, ->(a) { where('agency_id' => a) }

  scope :by_user, ->(u) { where('user_id' => u) }

  # configure table/view name
  self.table_name = "trips_view"
  self.primary_key = "trip_part_id"

  # case insensitive search and sort
  ransacker :user_name_case_insensitive, type: :string do
    arel_table[:user_name].lower
  end

  # model should be readonly (since this is a reporting tool)
  def readonly?
    true
  end

  # csv related
  def self.csv_headers
    [
      I18n.t(:id),
      I18n.t(:traveler),
      I18n.t(:trip_date),
      I18n.t(:from),
      I18n.t(:to),
      I18n.t(:trip_purpose),
      I18n.t(:rating),
    ]
  end

  def self.csv_columns
    [
      :id,
      :user_name,
      :trip_date,
      :from_address,
      :to_address,
      :trip_purpose,
      :trip_rating
    ]
  end

end