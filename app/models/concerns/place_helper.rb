module PlaceHelper
  STATE_REPLACEMENTS = {
      Pennsylvania: "PA",
      pennsylvania: "PA",
      pa: "PA",
      Pa: "PA"
  }

  def state_code
    if self.state.nil?
      return nil
    end
    return STATE_REPLACEMENTS[self.state.to_sym] || self.state
  end

end