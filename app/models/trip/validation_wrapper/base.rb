class Trip::ValidationWrapper::Base
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  def initialize(params={})
    Rails.logger.info "\nTrip::ValidationWrapper::Base#initialize"
    params.each do |attr, value|
      Rails.logger.info "#{attr}=#{value}"
      self.public_send("#{attr}=", value)
    end if params

    super()
    Rails.logger.info ""
  end

  def persisted?
    false
  end
end
