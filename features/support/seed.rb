module SeedHelpers
  # NOTE Do not create TripPurposes or characteristics with factory; they are seed data and
  # so will be put there by db:seeds  
  # FactoryGirl.create(:trip_purpose)
  # FactoryGirl.create(:dob_characteristic)
end

World(SeedHelpers)
