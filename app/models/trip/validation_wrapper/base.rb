class Trip::ValidationWrapper::Base
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  def initialize(params={})
    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params

    super()
  end

  def persisted?
    false
  end
end
