module Kiosk
  module Behavior
    def self.included(base)
      base.class_eval do
        layout 'kiosk/application'
      end
    end
  end
end
