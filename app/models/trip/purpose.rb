module Trip::Purpose
  extend ActiveSupport::Concern

  included do
    attr_reader :trip_purpose_id
    attr_accessor :trip_purpose_raw
    validates :trip_purpose_id,  presence: { if: -> { trip_purpose_raw.blank? } }
    validates :trip_purpose_raw, presence: { if: -> { trip_purpose_id.blank? } }
  end

  def trip_purpose_id= id
    if !id.is_a?(String) || id =~ /^(0|[1-9][0-9]*)$/
      @trip_purpose_id = id
    else
      self.trip_purpose_raw = id
    end
  end

  def self.defaults trip
    # trip.trip_purpose_id = TripPurpose.first.id
    trip
  end
end
