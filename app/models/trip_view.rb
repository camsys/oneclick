## This is a view model class for trips
## Based on a sql view "trips_view"
## Used to show, search, and sort admin/provider/agency/user trips
class TripView < ActiveRecord::Base

  scope :by_provider, ->(p) { where('provider_id' => p) }

  scope :by_agency, ->(a) { where('agency_id' => a) }

  scope :by_user, ->(u) { where('user_id' => u) }

  # configure table/view name
  self.table_name = "trips_view"
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
      TranslationEngine.translate_text(:traveler),
      TranslationEngine.translate_text(:trip_date),
      TranslationEngine.translate_text(:from),
      TranslationEngine.translate_text(:to),
      TranslationEngine.translate_text(:trip_purpose),
      TranslationEngine.translate_text(:rating),
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