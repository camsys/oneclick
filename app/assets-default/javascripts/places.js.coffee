# TODO There's a lot of duplication between this and trips.js.coffee

create_or_update_marker = (map, key, lat, lon, name, desc, iconStyle) ->  
  marker = map.findMarkerById(key)
  map.removeMarkerFromMap marker  if marker
  marker = map.createMarker(key, lat, lon, iconStyle, desc, name, true)
  map.addMarkerToMap marker, true
  marker

draw_loc = (map, dir, addr, lat, lon) ->
  key = 'start'
  icon = 'startIcon'
  map.removeMatchingMarkers(key)
  marker = create_or_update_marker(map, key, lat, lon, addr.name, addr.full_address, icon)
  map.setMapToBounds()
  map.selectMarker(marker)

update_map = (map, dir, e, addr, d) ->
  key = 'start'
  icon = 'startIcon'
  map.removeMatchingMarkers(key)
  marker = create_or_update_marker(map, key, addr.lat, addr.lon, addr.name, addr.full_address, icon)
  map.setMapToBounds()
  map.selectMarker(marker)

format_place = (addr) ->
  if !addr.lat && addr.lat != 0
    addr = 
      'type'    : '5'
      'type_name'    : 'PLACES_AUTOCOMPLETE_TYPE'
      'name'   : addr['description']
      'id'     : addr['place_id']
      'lat'    : null
      'lon'    : null
      'address' : addr['description']
      'description': '(not rendered)'

  return addr

# create a fake dom to initialize a new google place service
google_place_service = new google.maps.places.PlacesService(document.createElement('div'))
parse_place_details = (addr, cb) ->
  if !cb
    cb = () ->
  lat = addr.lat
  if !lat && lat != 0
    google_place_service.getDetails {
      placeId: addr.id
    }, (place, status) ->
      if status == google.maps.places.PlacesServiceStatus.OK
        addr.lat =  place.geometry.location.lat()
        addr.lon =  place.geometry.location.lng()
        place.geometry.location = 
          lat: addr.lat
          lng: addr.lon
        addr.google_details = place
        cb addr
  else
    cb addr

$ ->
  select_place = (selected_tr) ->
    $('#places-table tr').removeClass('success')
    dataset = $(selected_tr).data()
    selected_tr.addClass('success')
    $('#places_controller_places_proxy_id').val(dataset.id)
    $('#places_controller_places_proxy_from_place').val(dataset.address)
    $('#places_controller_places_proxy_json').val(JSON.stringify(dataset.json))
    $('#places_controller_places_proxy_place_name').val(dataset.placename)
    $('#places_controller_places_proxy_from_place').data().ttTypeahead.input.query = dataset.address
    $('#save').removeAttr('disabled')
  $('#places-table tr').on 'keyup', (e) ->
    if e.which == 32
      select_place $(e.target).closest('tr')
  $('#places-table tr').on 'click', (e) ->
    select_place $(e.target).closest('tr')

  $('#clear').on 'click', () ->
    $('#save').attr('disabled', 'true')
    $('#places-table tr').removeClass('success')
    $('#places_controller_places_proxy_id').val('')
    $('#places_controller_places_proxy_from_place').val('')
    $('#places_controller_places_proxy_json').val('')
    $('#places_controller_places_proxy_place_name').val('')

  $('#places_controller_places_proxy_from_place').on 'input', () ->
    if $.trim($(this).val()).length > 0
      $('#save').removeAttr('disabled')
    else  
      $('#save').attr('disabled', 'true')
  
  $('#places_controller_places_proxy_from_place').on 'typeahead:selected', (e, s, d) ->
    s = format_place(s)
    parse_place_details s, (addr_with_details) -> 
      $('#places_controller_places_proxy_json').val(JSON.stringify(addr_with_details))
      update_map(CsMaps.placesMap, 'trip', e, addr_with_details, d)
  $('#places_controller_places_proxy_from_place').on 'typeahead:autocompleted', (e, s, d) ->
    s = format_place(s)
    parse_place_details s, (addr_with_details) -> 
      $('#places_controller_places_proxy_json').val(JSON.stringify(addr_with_details))
      update_map(CsMaps.placesMap, 'trip', e, addr_with_details, d)
