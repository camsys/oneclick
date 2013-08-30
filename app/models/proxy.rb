require 'active_model'

class Proxy
  include ActiveModel::Conversion
  include ActiveModel::Validations  
  attr_reader   :errors
  
  def initialize(attrs = {})
    @errors = ActiveModel::Errors.new(self)    
  end
       
  def persist
    @persisted = false
  end

  def persisted?
    @persisted
  end       
  
end