class GeneratedReport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Serialization

  attr_accessor :report_name, :date_range, :traveler_type, :trip_purpose, :display_type, :summary_type

  def persisted?
    false
  end

end
