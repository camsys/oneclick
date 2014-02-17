class KioskLocation < ActiveRecord::Base
  attr_accessible :addr, :address_type, :lat, :lon, :name

  def as_json *args
    super(except: [:address_type], methods: [:type])
  end

  def type
    address_type
  end
end
