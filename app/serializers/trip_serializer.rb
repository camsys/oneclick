class TripSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :status, :modes, :user_id, :characteristics_update_url
  attributes :max_ui_duration, :min_ui_duration
  has_many :trip_parts
  attr_accessor :asynch

  def as_json(*args)
    begin
      @asynch = options[:asynch]
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

  def filter(keys)
    (keys - [:modes]) unless @asynch
  end

  def status
    1
  end

  def modes
    if @asynch
      return object.desired_modes.collect do |m|
        {
          mode: m.code,
          mode_name: I18n.t(m.name),
          urls: object.trip_parts.collect do |tp|
            {
              trip_part_id: tp.id,
              url: itineraries_user_trip_part_path(object.user, tp, mode: m.code, format: :json, locale: I18n.locale)
            }
          end
        }
      end
    end
  end

  def characteristics_update_url
    "/users/#{object.user_id}/characteristics/update"
  end

  def max_ui_duration
    (options[:max_ui_duration] || Oneclick::Application.config.max_ui_duration).to_i
  end

  def min_ui_duration
    (options[:min_ui_duration] || Oneclick::Application.config.min_ui_duration).to_i
  end

end
