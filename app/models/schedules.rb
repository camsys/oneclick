class Schedules < ActiveRecord::Base

  #associations
  belongs_to :service

  # attr_accessible :title, :body
end
