class GeneratedReport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Serialization

  attr_accessor :report_name, :date_range, :from_date, :to_date,
        :traveler_type, :trip_purpose, :display_type, :summary_type

  def initialize(hash)
    hash.each {|k,v| public_send("#{k}=",v)}
  end
  
  def persisted?
    false
  end

end
