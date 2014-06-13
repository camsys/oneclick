class TripDecorator < Draper::Decorator
  decorates_association :itineraries  
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def created
    I18n.l created_at, format: :isoish
  end

  def trip_date
    I18n.l trip_datetime, format: :isoish
  end

  def user
    object.user.name
  end

  def creator
    object.creator.name
  end

  def from
    from_place.name
  end

  def to
    to_place.name
  end

  def trip_purpose
    I18n.t object.trip_purpose.name
  end

  def modes
    I18n.t(desired_modes.map{|m| m.name}).join ', '
  end
  
end
