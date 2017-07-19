class GeneratedReport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Serialization

  attr_accessor :report_name, :date_range, :standard_usage_report_effective_date,
    :standard_usage_report_date_option, :from_date, :to_date, :agency_id,
    :agent_id, :provider_id, :traveler_type, :trip_purpose, :display_type,
    :summary_type, :date_option, :county_filters

  def initialize(hash)
    hash.each {|k,v| public_send("#{k}=", (v == "-1") ? false : v)}
  end

  def persisted?
    false
  end

end
