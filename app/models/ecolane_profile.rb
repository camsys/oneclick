class EcolaneProfile < ActiveRecord::Base
  belongs_to :service

  serialize :booking_counties # List of counties whose residents can book through this service
  serialize :disallowed_purposes # List of trip purposes to not provide to users

  # Get and set disallowed purposes using a string of comma separated values
  def disallowed_purposes_text
    (disallowed_purposes || []).join(", ")
  end

  def disallowed_purposes_text=(new_value)
    write_attribute(:disallowed_purposes, new_value.split(',').map(&:strip))
  end

  def booking_counties_text
    (booking_counties || []).join(", ")
  end

  def booking_counties_text=(new_value)
    write_attribute(:booking_counties, new_value.split(',').map(&:strip))
  end

end
