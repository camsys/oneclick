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
      object.from_trip_place.name2  + (((object.from_trip_place.poi or object.from_trip_place.place) and  not object.from_trip_place.address1.blank?) ? ", " + object.from_trip_place.address1 : ""), TranslationEngine.translate_text(:to).downcase,
      object.to_trip_place.name2 + (((object.to_trip_place.poi or object.to_trip_place.place) and  not object.to_trip_place.address1.blank?) ? ", " + object.to_trip_place.address1 : "")
    ]).strip
  end

  def direction
    object.is_return_trip? ? TranslationEngine.translate_text(:return) : TranslationEngine.translate_text(:outbound)
  end

end
