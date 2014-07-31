class KioskLocation < ActiveRecord::Base
  def as_json *args
    result = super(except: [:address_type], methods: ['type'])
    result
  end

  def type
    address_type
  end
end
