class Proxy

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  
  attr_accessor :name
  attr_reader   :errors

  def validate!
    errors.add(:name, "can not be nil") if name == nil
  end
  
  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    @errors = ActiveModel::Errors.new(self)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end
  
  def persisted?
    false
  end
     
  def add_error(field, error)
    @errors.add(field, error)
  end     
end