module RatingsHelper
  # Convert numeric values into HTML for display
  def to_stars(value, size, noblanks = false)
    if value.eql? Rating::DID_NOT_TAKE
      return "<span id='stars'>#{t(:untaken_trip)}</span>".html_safe
    end
    html = "<span id='stars'>"
    for i in 1..5
      if i <= value
        html << "<i class='x fa fa-star fa-#{size}x'> </i>"
      else
        unless noblanks
          html << "<i class='x fa fa-star-o fa-#{size}x'> </i>"
        end
      end
    end
    html << "</span>"
    return html.html_safe
  end
end