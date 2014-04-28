class TripSerializer < ActiveModel::Serializer
  self.root = false
  
  attributes :id, :status
  has_many :trip_parts

  def as_json(*args)
    begin
      super(*args)
    rescue Exception => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      {
        status: 0,
        status_text: e.message
        }
      end
    end

    def status
      1
    end

  end
