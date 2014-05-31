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

   # A Copy of the logic in rateable.rb to convert value to stars
  def rating_in_stars(size=1)
    rating = value
    html = "<span id='stars'>"
    for i in 1..5
      if i <= rating
        html << "<i class='x fa fa-star fa-#{size}x'> </i>"
      else
        html << "<i class='x fa fa-star-o fa-#{size}x'> </i>"
      end
    end
    html << "</span>"
    return html.html_safe
  end
end
