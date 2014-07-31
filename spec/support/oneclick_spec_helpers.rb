module OneclickSpecHelpers
  def login_as(user)
    @request.env["devise.mapping"] = Devise.mappings[user]
    mock_user = FactoryGirl.create user
    sign_in mock_user
  end

  def login_as_using_find_by(options = {})
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = User.find_by options
    sign_in user
  end
end

RSpec.configure do |c|
  c.include OneclickSpecHelpers
end

# This test leg has (all on 2013-12-09):
# Bus from 17:59:17 to 18:07:20
# Bus from 18:17:20 to 18:27:20 (10 minute gap prior)
# Bus from 18:27:21 to 18:36:59 (No gap prior)
# Walk from 18:37:00 to 18:47:00 (No gap prior)

def test_legs
	x =<<EOT
---
- startTime: 1386629957000
  endTime: 1386630440000
  distance: 1728.5176517562375
  mode: BUS
  route: '110'
  agencyName:
  agencyUrl:
  agencyTimeZoneOffset: 0
  routeColor: '808000'
  routeId: MARTA_7691
  routeTextColor:
  interlineWithPreviousLeg:
  tripShortName:
  headsign: Route 110 - Five Points
  agencyId: MARTA
  tripId: '3399469'
  from:
    name: PEACHTREE ST NE@4TH ST NE
    stopId:
      agencyId: ASFS
      id: MARTA_82016
    stopCode: '904295'
    lon: -84.384911
    lat: 33.774944
    arrival:
    departure:
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.384911,33.774944]}'
  to:
    name: PEACHTREE ST NW@INTERNATIONAL BLVD
    stopId:
      agencyId: ASFS
      id: MARTA_93024
    stopCode: '900727'
    lon: -84.387728
    lat: 33.759853
    arrival: 1386630440000
    departure: 1386630440000
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.387728,33.759853]}'
  legGeometry:
    points: gtcmE`k`bOtFTfHZbCLvI^vER@?~EJpMVf@FjAj@|BdAhGvEhBvAbF@tF@
    levels:
    length: 16
  routeShortName: '110'
  routeLongName: Peachtree St./"The Peach"
  boardRule:
  alightRule:
  rentedBike:
  duration: 483000
  bogusNonTransitLeg: false
  intermediateStops: []
- startTime: 1386631040000
  endTime: 1386631640000
  distance: 1728.5176517562375
  mode: BUS
  route: '112'
  agencyName:
  agencyUrl:
  agencyTimeZoneOffset: 0
  routeColor: '808000'
  routeId: MARTA_7691
  routeTextColor:
  interlineWithPreviousLeg:
  tripShortName:
  headsign: Route 112 - Someplace Else
  agencyId: MARTA
  tripId: '3399469'
  from:
    name: PEACHTREE ST NE@4TH ST NE
    stopId:
      agencyId: ASFS
      id: MARTA_82016
    stopCode: '904295'
    lon: -84.384911
    lat: 33.774944
    arrival:
    departure:
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.384911,33.774944]}'
  to:
    name: PEACHTREE ST NW@INTERNATIONAL BLVD
    stopId:
      agencyId: ASFS
      id: MARTA_93024
    stopCode: '900727'
    lon: -84.387728
    lat: 33.759853
    arrival: 1386631640000
    departure: 1386631040000
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.387728,33.759853]}'
  legGeometry:
    points: gtcmE`k`bOtFTfHZbCLvI^vER@?~EJpMVf@FjAj@|BdAhGvEhBvAbF@tF@
    levels:
    length: 16
  routeShortName: '112'
  routeLongName: Peachtree St./"The Peach"
  boardRule:
  alightRule:
  rentedBike:
  duration: 483000
  bogusNonTransitLeg: false
  intermediateStops: []
- startTime: 1386631641000
  endTime: 1386632219000
  distance: 1728.5176517562375
  mode: BUS
  route: '113'
  agencyName:
  agencyUrl:
  agencyTimeZoneOffset: 0
  routeColor: '808000'
  routeId: MARTA_7691
  routeTextColor:
  interlineWithPreviousLeg:
  tripShortName:
  headsign: Route 113 - Yet Another Place
  agencyId: MARTA
  tripId: '3399469'
  from:
    name: PEACHTREE ST NE@4TH ST NE
    stopId:
      agencyId: ASFS
      id: MARTA_82016
    stopCode: '904295'
    lon: -84.384911
    lat: 33.774944
    arrival:
    departure:
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.384911,33.774944]}'
  to:
    name: PEACHTREE ST NW@INTERNATIONAL BLVD
    stopId:
      agencyId: ASFS
      id: MARTA_93024
    stopCode: '900727'
    lon: -84.387728
    lat: 33.759853
    arrival: 1386632219000
    departure: 1386631641000
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.387728,33.759853]}'
  legGeometry:
    points: gtcmE`k`bOtFTfHZbCLvI^vER@?~EJpMVf@FjAj@|BdAhGvEhBvAbF@tF@
    levels:
    length: 16
  routeShortName: '113'
  routeLongName: Peachtree St./"The Peach"
  boardRule:
  alightRule:
  rentedBike:
  duration: 483000
  bogusNonTransitLeg: false
  intermediateStops: []
- startTime: 1386632220000
  endTime: 1386632820000
  distance: 228.37099466966987
  mode: WALK
  route: ''
  agencyName:
  agencyUrl:
  agencyTimeZoneOffset: -18000000
  routeColor:
  routeId:
  routeTextColor:
  interlineWithPreviousLeg:
  tripShortName:
  headsign:
  agencyId:
  tripId:
  from:
    name: Peachtree Street
    stopId:
    stopCode:
    lon: -84.38760450114215
    lat: 33.75984838609497
    arrival:
    departure:
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.38760450114215,33.75984838609497]}'
  to:
    name: Peachtree Center Avenue Northeast
    stopId:
    stopCode:
    lon: -84.38607220988743
    lat: 33.75906560016298
    arrival: 1386632820000
    departure: 1386632220000
    orig:
    zoneId:
    geometry: ! '{"type": "Point", "coordinates": [-84.38607220988743,33.75906560016298]}'
  legGeometry:
    points: _v`mEp}`bOZ?BsHzB@
    levels:
    length: 4
  routeShortName:
  routeLongName:
  boardRule:
  alightRule:
  rentedBike:
  duration: 129000
  bogusNonTransitLeg: false
  steps:
  - distance: 16.374265268266697
    relativeDirection:
    streetName: Peachtree Street
    absoluteDirection: SOUTH
    exit:
    stayOn: false
    bogusName: false
    lon: -84.38760450114215
    lat: 33.75984838609497
    elevation: ''
  - distance: 143.11603478992063
    relativeDirection: LEFT
    streetName: International Boulevard Northeast
    absoluteDirection: EAST
    exit:
    stayOn: false
    bogusName: false
    lon: -84.38761
    lat: 33.7597012
    elevation: ''
  - distance: 68.88069461148254
    relativeDirection: RIGHT
    streetName: Peachtree Center Avenue Northeast
    absoluteDirection: SOUTH
    exit:
    stayOn: false
    bogusName: false
    lon: -84.386062
    lat: 33.759685
    elevation: ''
EOT
x
end
