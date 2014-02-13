class Trip::ValidationWrapper::From < Trip::ValidationWrapper::Base
  include Trip::From
  attr_accessor :use_current_location
end
