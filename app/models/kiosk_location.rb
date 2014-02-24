class KioskLocation < ActiveRecord::Base
  attr_accessible :addr, :address_type, :lat, :lon, :name

  def as_json *args
    result = super(except: [:address_type], methods: ['type'])
    result
  end

  def type
    address_type
  end
end
