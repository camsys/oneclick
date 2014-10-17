class RatingDecorator < Draper::Decorator
  delegate_all


  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

   # A Copy of the logic in rateable.rb to convert value to stars specifically for a Rating object (rather than a Rateable object)
  def rating_in_stars(size=1)
    h.to_stars(value, size)
  end

  # For Ratings Report
  def username
    user.name
  end

  def created
    I18n.l created_at, format: :isoish
  end

  def rating_targets
    rateable_desc
  end
  
end
