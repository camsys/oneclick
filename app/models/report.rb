class Report < ActiveRecord::Base
  
  # attr_accessible :string, :description, :name, :view_name, :class_name, :active
  
  # default scope
  default_scope {where(:active => true)}

  def name_and_id
    [name, id]
  end

  def self.names_and_ids
    Report.all.map(&:name_and_id)
  end

  # TODO This shoudl go into decorator (and previous as well, I would say)
  def self.date_options
    [
      'All',
      'Past Trips',
      'Future Trips',
      'Last 7 Days',
      'Next 7 Days',
      'Last 30 Days',
      'Next 30 Days',
      'Last Month',
      'Custom'
    ]
  end

  def self.traveler_types
    ['All'] + Characteristic.all.map(&:name).sort
  end

  def self.trip_purposes
    ['All'] + TripPurpose.all.map(&:name).sort
  end

  def self.display_types
    ['Summary Chart', 'Summary Table', 'Detailed Listing']
  end

  def self.summary_types
    ['Day', 'Week', 'Month', 'Traveler Type', 'Purpose', 'Rating']
  end

end
