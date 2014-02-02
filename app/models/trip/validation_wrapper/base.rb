class Trip::ValidationWrapper::Base
  include ActiveModel::Model
  include ActiveModel::Validations
  attr_reader :errors
end
