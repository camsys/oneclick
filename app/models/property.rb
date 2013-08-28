class Property < ActiveRecord::Base
  attr_accessible :category, :name, :sort_order, :value
end
