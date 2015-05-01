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

end
