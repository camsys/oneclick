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
      TranslationEngine.translate_text(:id),
      TranslationEngine.translate_text(:trip_id),
      TranslationEngine.translate_text(:traveler),
      TranslationEngine.translate_text(:trip_datetime),
      TranslationEngine.translate_text(:from),
      TranslationEngine.translate_text(:to),
      TranslationEngine.translate_text(:outbound_or_return),
      TranslationEngine.translate_text(:provider_name)
    ]
  end

  def self.csv_columns
    [
      :id,
      :trip_id,
      :user_name,
      :trip_datetime,
      :from_address,
      :to_address,
      :is_return_trip,
      :provider_name
    ]
  end

end