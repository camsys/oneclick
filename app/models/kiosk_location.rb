class KioskLocation < ActiveRecord::Base
  attr_accessible :addr, :address_type, :lat, :lon, :name, :poi_id

  def as_json *args
    result = super(except: [:address_type], methods: ['type'])

    # have the JSON return to Poi id as the id.. this will make it compatible with
    # RideshareAdapter
    id = result.delete('poi_id')
    result['id'] = id

    result
  end

  def type
    address_type
  end
end
