class UberItinerary < RideHailingItinerary
  def formulate
    return [] unless service && trip_part
      
    product_name = get_uber_product_name
    coords = place_coords

    estimation = UberHelpers.new.get_product_estimate(
      product_name,
      coords[:start_latitude],
      coords[:start_longitude],
      coords[:end_latitude],
      coords[:end_longitude]
      ) if UberHelpers.available?
    
    parse_uber_estimation(estimation)
  end

  private

  def get_uber_product_name
    'uberX' if service.try(:service_type).try(:code) == 'uber_x'
  end

  def place_coords
    from_address = trip_part.try(:from_trip_place).try(:location) || []
    to_address = trip_part.try(:to_trip_place).try(:location) || []

    {
      start_latitude: from_address[0],
      start_longitude: from_address[1],
      end_latitude: to_address[0],
      end_longitude: to_address[1]
    }
  end

  def parse_uber_estimation(estimation)
    return if !estimation
    self.server_status = 200
    
    self.duration = estimation.duration
    self.transfers = 0
    self.cost = (estimation.low_estimate.to_f + estimation.high_estimate.to_f) / 2 # pick the middle value
    self.cost_comments = estimation.estimate
    self.wait_time = $uber_waiting_time
    self.duration_estimated = true

    base_time = trip_part.trip_time
    if trip_part.is_depart
      self.start_time = base_time
      self.end_time = base_time + duration.seconds
      self.end_time += self.wait_time.seconds if self.wait_time
    else
      self.start_time = base_time - duration.seconds
      self.start_time -= self.wait_time.seconds if self.wait_time
      self.end_time = base_time
    end
  end

end