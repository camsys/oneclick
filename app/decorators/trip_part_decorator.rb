class TripPartDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def description
    # "Outbound - 40 Courtland Street NE Atlanta, GA to Atlanta VA Medical Center"
    trip = object.trip
    "%s - %s" % [
      direction, description_without_direction
    ]
  end

  def description_without_direction
    # "40 Courtland Street NE Atlanta, GA to Atlanta VA Medical Center"
    trip = object.trip
    ("%s %s %s" % [
      object.from_trip_place.name2, I18n.t(:to).downcase, 
      object.to_trip_place.name2
    ]).strip
  end

  def direction
    object.is_return_trip? ? I18n.t(:return) : I18n.t(:outbound)
  end

end
