## This is a view model class for trip parts
## Based on a sql view "trip_parts_view"
## Used to show, search, and sort provider's trip_parts
class TripPartView < ActiveRecord::Base

  scope :by_provider, ->(p) { where('provider_id' => p) }

  # configure table/view name
  self.table_name = "trip_parts_view"
  self.primary_key = "id"

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
      I18n.t(:trip_id),
      I18n.t(:traveler),
      I18n.t(:provider_name),
      I18n.t(:trip_date),
      I18n.t(:from),
      I18n.t(:to),
      I18n.t(:trip_purpose),
      I18n.t(:rating)
    ]
  end

  def self.csv_columns
    [
      :id,
      :trip_id,
      :user_name,
      :provider_name,
      :trip_date,
      :from_address,
      :to_address,
      :trip_purpose,
      :trip_rating
    ]
  end

end