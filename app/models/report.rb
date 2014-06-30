class Report < ActiveRecord::Base
  
  # attr_accessible :string, :description, :name, :view_name, :class_name, :active
  
  # default scope
  default_scope {where(:active => true)}

  def name_and_id
    [I18n.t(class_name), id]
  end

  def self.names_and_ids
    Report.all.map(&:name_and_id)
  end

  # TODO Probably delete this
  def self.display_types
    ['Summary Chart', 'Summary Table', 'Detailed Listing']
  end

  def self.summary_types
    ['Day', 'Week', 'Month', 'Traveler Type', 'Purpose', 'Rating']
  end

  # TODO Add modes and accomodations
end
