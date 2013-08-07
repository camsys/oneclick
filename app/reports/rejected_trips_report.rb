class RejectedTripsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    return Trip.rejected

  end
    
end
