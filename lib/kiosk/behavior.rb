module Kiosk
  module Behavior
    extend ActiveSupport::Concern

    included do
      layout 'kiosk/application'
      helper_method :back_url
    end

    def back_url
      # raise 'Not implemented'
      ''
    end
  end
end
