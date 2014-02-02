module Trip::Purpose
  extend ActiveSupport::Concern

  included do
    attr_accessor :trip_purpose_id
    validates :trip_purpose_id, :presence => true
  end
end
