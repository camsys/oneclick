class FareStructure < ActiveRecord::Base
  include Commentable

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

  TYPES = {
    flat: 0,
    mileage: 1,
    zone: 3
  }

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

  def flat_fare_number
    if flat_fare
      flat_fare.one_way_rate
    end
  end

  def mileage_fare_number(trip_part)
    return nil unless trip_part && mileage_fare && mileage_fare.base_rate

    mileage = TripPlanner.new.get_drive_distance(
      !trip_part.is_depart,
      trip_part.scheduled_time,
      trip_part.from_trip_place.lat,
      trip_part.from_trip_place.lon,
      trip_part.to_trip_place.lat,
      trip_part.to_trip_place.lon)

    if mileage_fare.mileage_rate
      mileage_fare.base_rate.to_f + mileage * mileage_fare.mileage_rate.to_f
    else
      mileage_fare.base_rate.to_f
    end
  end

  def zone_fare_number(trip_part)
    return nil unless trip_part && service && service.fare_zones

    start_lat = trip_part.from_trip_place.lat
    start_lng = trip_part.from_trip_place.lon
    end_lat = trip_part.to_trip_place.lat
    end_lng = trip_part.to_trip_place.lon
    return nil unless start_lat && start_lng && end_lat && end_lng

    from_zone_id = service.fare_zones.identify(start_lat, start_lng)
    to_zone_id = service.fare_zones.identify(end_lat, end_lng)

    zone_fare = zone_fares.where(from_zone_id: from_zone_id, to_zone_id: to_zone_id).first

    zone_fare.rate if zone_fare
  end

end
