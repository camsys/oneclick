fixes = {'disabled' => "persons with a permanent or temporary disability",
         'ada_eligible' => "persons eligible for ADA paratransit",
         'matp' => "persons with a Medical Assistance Access Card",
         'veteran' => "military veterans",
         'walk_distance' => "persons able to comfortably walk for 5, 10, 15, 20, 25, 30 minutes",
         }

fixes.each do |code, value|
  c = Characteristic.where(code: code).first
  c.update_attributes(desc: value)
end
