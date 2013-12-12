class FareStructure < ActiveRecord::Base

  #associations
  belongs_to :service

  #Type Definitions
  # 0: Flat Fare (Flat fare is stored in :base)
  # 1: Mileage based Fare (:base stores the initial charge, and :rate stores the addition fare for each mile,)
  # 2: Complex Fares that Cannot be Calculated.  :desc will contain a short description explaining the fare structure
  attr_accessible :service, :fare_type, :base, :rate, :desc

end
