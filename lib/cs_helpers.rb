module CsHelpers

  # TODO Unclear whether this will need to be more flexible depending on how clients want to do their domains
  # may have to vary by environment
  def brand
    request.subdomains.first || nil
  end

end
