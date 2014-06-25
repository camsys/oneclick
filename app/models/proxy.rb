# Base class for transient models. Provides naming and validations via ActiveModel
# so concrete classes can call xxx.valid? to validate the transient
# model and forms can process error messages.
# replace this with ActiveModel::Model after upgrading to rails 4:
# http://api.rubyonrails.org/classes/ActiveModel/Model.html
class Proxy
  include ActiveModel::Conversion
  include ActiveModel::Validations
  attr_accessor   :errors

  def initialize(attrs = {})
    @errors = ActiveModel::Errors.new(self)
  end

  # ensure that they are never stored in the database
  def persist
    @persisted = false
  end

  def persisted?
    @persisted
  end
end
