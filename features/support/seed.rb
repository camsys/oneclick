module SeedHelpers
  FactoryGirl.create(:trip_purpose)
  FactoryGirl.create(:dob_characteristic)
end

World(SeedHelpers)
