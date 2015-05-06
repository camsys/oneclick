class FareStructure < ActiveRecord::Base

  #associations
  belongs_to :service

  # fare types
  has_one :flat_fare
  has_one :mileage_fare
  has_many :zone_fares

  #Type Definitions
  # 0: Flat Fare (Flat fare is stored in :base)
  # 1: Mileage based Fare (:base stores the initial charge, and :rate stores the addition fare for each mile,)
  # 2: Complex Fares that Cannot be Calculated.  :desc will contain a short description explaining the fare structure
  # attr_accessible :service, :fare_type, :base, :rate, :desc

  FLAT = 0
  MILEAGE = 1
  COMPLEX = 2
  ZONE=3

  def fare_data
    case fare_type
    when FLAT
      flat_fare
    when MILEAGE
      mileage_fare
    when ZONE
      zone_fares
    else
      nil
    end
  end

  def zone_fare(start_lat, start_lng, end_lat, end_lng)
    return nil unless service && start_lat && start_lng && end_lat && end_lng && service.fare_zones
    
    from_zone_id = service.fare_zones.identify(start_lat, start_lng)
    to_zone_id = service.fare_zones.identify(end_lat, end_lng)

    zone_fare = zone_fares.where(from_zone_id: from_zone_id, to_zone_id: to_zone_id).first

    zone_fare.rate if zone_fare
  end

end
