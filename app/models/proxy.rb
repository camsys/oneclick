class Proxy

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  
  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end
  
  def persisted?
    false
  end
          
end