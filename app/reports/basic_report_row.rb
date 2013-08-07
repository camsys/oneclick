class BasicReportRow
  
  attr_accessor  :key, :count, :id_list
  
  def initialize(key)
    self.key = key
    self.count = 0
    self.id_list = []
  end
  
  def add(trip)
    self.count += 1
    self.id_list << trip.id
  end
  
end
