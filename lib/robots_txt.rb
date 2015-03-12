class RobotsTxt
  def self.call(env)
    # build a new response
    resp = Rack::Response.new
    resp['Content-Type'] = 'text/plain'

    # cache the response for a year, so further requests won't hit the app
    resp['Cache-Control'] = 'public, max-age=31557600'

    # if we're not in production, set the content to disallow all robots
    unless Rails.env.production?
      resp.write "User-agent: *\nDisallow: /"
    end

    resp.finish
  end
end
