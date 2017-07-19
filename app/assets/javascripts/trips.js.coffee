# detect touch device
is_touch_device = ->
  return "ontouchstart" of window or navigator.MaxTouchPoints > 0 or navigator.msMaxTouchPoints > 0

isMobile = ->
  if /mobile|android|touch|webos|hpwos/i.test(navigator.userAgent.toLowerCase())
    return true
  else
    return false

remove_marker = (map, key) ->
  marker = map.findMarkerById(key)
  map.removeMarkerFromMap marker  if marker

create_or_update_marker = (map, key, lat, lon, name, desc, iconStyle) ->
  remove_marker(map, key)
  marker = map.createMarker(key, lat, lon, iconStyle, desc, name, false)
  map.addMarkerToMap marker, true
  marker

# is_dup: a temp fix to stop duplicating another place for multi_od_places
#           also not need to select marker
# reason:
#       current enlarged map implementation is to have a duplicated map (expandedMap), then repeat same updates as for tripMap
#       we only allow certain updates to happen on second map (enlargedMap), by passing is_dup as true to differentiate
update_map = (map, dir, e, addr, d, is_dup) ->
  if dir =='from'
    key = 'start'
    icon = 'startIcon'
  else
    key = 'stop'
    icon = 'stopIcon'

  # for multi_od, in order to use different marker key to display all places on map
  if $('#' + dir + '_places').length > 0
    place_counter = get_current_multi_od_place_counter(dir)
    key += (++place_counter)

  map.removeMatchingMarkers(key)
  marker = create_or_update_marker(map, key, addr.lat, addr.lon, addr.name, addr.full_address, icon)
  map.setMapToBounds()
  if !is_dup
    map.selectMarker(marker)
    add_multi_od_places(dir, addr.name, addr)

format_place = (addr) ->
  if !addr.lat && addr.lat != 0
    addr = 
      'type'    : '5'
      'type_name'    : 'PLACES_AUTOCOMPLETE_TYPE'
      'name'   : addr['description']
      'id'     : addr['place_id']
      'reference': addr['reference']
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
      process_place = (place_obj) ->
        addr.lat =  place_obj.geometry.location.lat()
        addr.lon =  place_obj.geometry.location.lng()
        place_obj.geometry.location = 
          lat: addr.lat
          lng: addr.lon
        addr.google_details = place_obj
        cb addr

      if status == google.maps.places.PlacesServiceStatus.OK
        process_place place
      else 
        # noticed occasionally no match based on place_id, so try again with reference 
        google_place_service.getDetails {
          reference: addr.reference
        }, (new_place, status) ->
          if status == google.maps.places.PlacesServiceStatus.OK
            process_place new_place
          else
            console.log "No match found for: " + addr.name
  else
    cb addr

show_marker = (map, dir) ->
  if dir=='from'
    key = 'start'
  else
    key = 'stop'
  map.selectMarkerById(key)

toggle_map = (dir) ->
  if dir=='from'
    otherdir = 'to'
  else
    otherdir = 'from'
  c = '#' + dir + "MapContainer"
  $(c).toggleClass('hide')
  CsMaps[dir + "Map"].refresh()
  if !$(c).hasClass('hide')
    hide_map(otherdir)

hide_map = (dir) ->
  $('#' + dir + "MapContainer").addClass('hide')
  CsMaps[dir + "Map"].addressType = null

show_map = (dir, addrType) ->
  $('#' + dir + "MapContainer").removeClass('hide')
  CsMaps[dir + "Map"].refresh()
  CsMaps[dir + "Map"].addressType = addrType # assign addressType to use in updating place input field after picking location from map

# !important: these two flags are used to not show hint options when select a place from map
# only show options after place input got focused
show_from_typeahead_hint = true
show_to_typeahead_hint = true

update_place = (placeText, type, addr) ->
  if type =='from'
    placeid = 'trip_proxy_from_place'
    show_from_typeahead_hint = false
  else
    placeid = 'trip_proxy_to_place'
    show_to_typeahead_hint = false

  $('#' + placeid).typeahead('val', placeText)

get_current_multi_od_place_counter = (dir) ->
  place_counter = parseInt($('#' + dir + '_places').attr('place-counter'))
  if isNaN(place_counter) or typeof(place_counter) != 'number'
     place_counter = 0

  place_counter

add_multi_od_places = (dir, addr_text, addr_data) ->
  if $('#' + dir + '_places').length == 0
    return
  addr_data = addr_data || {}
  is_addr_full_object = !$.isEmptyObject(addr_data) # whether this is just a address name or full address object
  addr_name = addr_text
  if is_addr_full_object
    addr_text = addr_data.full_address || addr_data.address || addr_text
  addr_obj = {
    data: addr_data,
    name: addr_name,
    address: addr_text,
    lat: addr_data.lat,
    lon: addr_data.lon,
    is_full: is_addr_full_object
  }

  current_place_counter = get_current_multi_od_place_counter(dir)
  new_place_counter = ++current_place_counter
  if dir=='from'
    key = 'start'
  else
    key = 'stop'
  place_marker_key = key + new_place_counter
  new_place_row_tags = "<tr place-marker-key='" + place_marker_key + "'>" +
    "<td class='address-data' style='display:none;'>" + JSON.stringify(addr_obj) + "</td>" +
    "<td>" + addr_name + "</td>" +
    "<td class='center nowrap'><button class='btn btn-sm btn-danger delete-button'><i class='fa fa-times'></i></button></td>" +
    "</tr>"
  $('#' + dir + '_places').append new_place_row_tags

  $('#' + dir + '_places').attr('place-counter', new_place_counter)
  $('#trip_proxy_' + dir + '_place').attr('last-multi-od-value', addr_name)
  setTimeout (->
    $('#trip_proxy_' + dir + '_place').val('')
    return
  ), 100

  return

#update map marker from selected location, and update address input field from reverse geocoded address
process_location_from_map = (addr, dir) -> 
  $('#' + dir + '_place_object').val(JSON.stringify(addr))
  update_map CsMaps.tripMap, dir, null, addr, null
  update_map CsMaps.expandedMap, dir, null, addr, null, true
  update_place addr.name, dir, addr

validateDateTimes = (isReturn) ->
  outboundDateField = $("#trip_proxy_outbound_trip_date")
  outboundTimeField = $("#trip_proxy_outbound_trip_time")
  returnDateField = $("#trip_proxy_return_trip_date")
  returnTimeField = $("#trip_proxy_return_trip_time")

  unless isMobile()
    outboundDateData = outboundDateField.data("DateTimePicker")
    outboundTimeData = outboundTimeField.data("DateTimePicker")
    returnDateData = returnDateField.data("DateTimePicker")
    returnTimeData = returnTimeField.data("DateTimePicker")

    if !moment(outboundDateField.val(), outboundDateData.format).isValid()
      outboundDateData.setValue(outboundDateData.date)
    if !moment(outboundTimeField.val(), outboundTimeData.format).isValid()
      outboundTimeData.setValue(outboundTimeData.date)
    if !moment(returnDateField.val(), returnDateData.format).isValid()
      returnDateData.setValue(returnDateData.date)
    if !moment(returnTimeField.val(), returnTimeData.format).isValid()
      returnTimeData.setValue(returnTimeData.date)

    outboundDate = moment(outboundDateField.val(), outboundDateData.format)
    returnDate = moment(returnDateField.val(), returnDateData.format)
    outboundDateTime = moment(outboundDateField.val() + " " + outboundTimeField.val(), outboundDateData.format + " " + outboundTimeData.format)
    returnDateTime = moment(returnDateField.val() + " " + returnTimeField.val(), returnDateData.format + " " + returnTimeData.format)
    outboundDateTimeInvalid =  !outboundDateTime.isValid()
    returnDateTimeInvalid = !returnDateTime.isValid()
    minOutboundDateTime = moment()

    if returnDate < outboundDate
      returnDateField.val(outboundDateField.val())
      returnDateField.attr('value', outboundDateField.val())

  else
    ###
    IF WE GET INVALID DATETIMES, WE...?
    if !moment(outboundDateField.val(), 'MM/DD/YYYY').isValid()
      ?????????
    if !moment(outboundTimeField.val(), 'h:mm A').isValid()
      ?????????
    if !moment(returnDateField.val(), 'MM/DD/YYYY').isValid()
      ?????????
    if !moment(returnTimeField.val(), 'h:mm A').isValid()
      ?????????
    ###

    if returnDateField.val() < outboundDateField.val()
      returnDateField.val(outboundDateField.val())
      returnDateField.attr('value', outboundDateField.val())

get_my_location = (dir) ->
  if window.navigator.geolocation
    process_location = (position) ->
      reverse_geocode position.coords.latitude, position.coords.longitude, dir
      return

    process_error = (error) ->
      warning_msg = ""
      switch error.code
        when error.PERMISSION_DENIED
          warning_msg = "User denied the request for Geolocation."
        when error.POSITION_UNAVAILABLE
          warning_msg = "Location information is unavailable."
        when error.TIMEOUT
          warning_msg = "The request to get user location timed out."
        else
          warning_msg = "An unknown error occurred."
      show_alert warning_msg
      return

    window.navigator.geolocation.getCurrentPosition process_location, process_error
  else
    show_alert "Geolocation is not supported by this browser."
  return

google_geocoder = new google.maps.Geocoder()
reverse_geocode = (lat, lon, dir) ->
  latlng = new google.maps.LatLng(lat, lon)
  google_geocoder.geocode {'latLng': latlng}, (results, status) ->
    if status == google.maps.GeocoderStatus.OK
      if results[0]
        google_details = results[0]
        google_details.geometry.location = {
          lat: lat,
          lng: lon
        }
        addr =
          google_details: google_details
          lat: lat
          lon: lon
          name: google_details.formatted_address
          type: '5'
          type_name: 'PLACES_AUTOCOMPLETE_TYPE'
          id: google_details.place_id
          reference: google_details.reference
          address: google_details.formatted_address
          description: '(not rendered)'

        process_location_from_map(addr, dir)
      else
        console.log error

$ ->
  # Show/hide map popover when in input field
  $('#trip_proxy_from_place').on 'typeahead:opened', () ->
    if $('#fromAddressMarkerButton').css('display') != 'none'
      show_map 'trip', 'from'
    if not show_from_typeahead_hint
      $('#trip_proxy_from_place').typeahead('close')
  $('#trip_proxy_to_place').on 'typeahead:opened', () ->
    if $('#toAddressMarkerButton').css('display') != 'none'
      show_map 'trip', 'to'
    if not show_to_typeahead_hint
      $('#trip_proxy_to_place').typeahead('close')

  $('#trip_proxy_from_place').on 'focusin', () ->
    show_from_typeahead_hint = true
  $('#trip_proxy_from_place').on 'typeahead:selected', (e, addr, d) ->
    addr = format_place(addr)
    parse_place_details addr, (addr_with_details) -> 
      $('#from_place_object').val(JSON.stringify(addr_with_details))
      update_map CsMaps.tripMap, 'from', e, addr_with_details, d
      update_map CsMaps.expandedMap, 'from', e, addr_with_details, d, true
      if $('#from_places').length == 0
        $('#trip_proxy_to_place').focus()
        $('#trip_proxy_to_place').trigger('touchstart')
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, addr, d) ->
    addr = format_place(addr)
    parse_place_details addr, (addr_with_details) ->
      $('#from_place_object').val(JSON.stringify(addr_with_details))
      update_map CsMaps.tripMap, 'from', e, addr_with_details, d
      update_map CsMaps.expandedMap, 'from', e, addr_with_details, d, true

  $('#trip_proxy_to_place, #trip_proxy_outbound_arrive_depart').on 'touchstart', () ->
    $(this).focus()
  $('#trip_proxy_to_place').on 'focusin', () ->
    show_to_typeahead_hint = true
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, addr, d) ->
    addr = format_place(addr)
    parse_place_details addr, (addr_with_details) ->
      $('#to_place_object').val(JSON.stringify(addr_with_details))
      update_map CsMaps.tripMap, 'to', e, addr_with_details, d
      update_map CsMaps.expandedMap, 'to', e, addr_with_details, d, true
      if $('#to_places').length == 0
        $('#trip_proxy_outbound_arrive_depart').focus()
        $('#trip_proxy_outbound_arrive_depart').trigger('touchstart')
  $('#trip_proxy_to_place').on 'typeahead:autocompleted', (e, addr, d) ->
    addr = format_place(addr)
    parse_place_details addr, (addr_with_details) ->
      $('#to_place_object').val(JSON.stringify(addr_with_details))
      update_map CsMaps.tripMap, 'to', e, addr_with_details, d
      update_map CsMaps.expandedMap, 'to', e, addr_with_details, d, true

  $('.plan-a-trip input, .plan-a-trip select').on 'focusin', () ->
    if $(this).parents('.trip_proxy_from_place, .trip_proxy_to_place').length == 0
      hide_map 'trip'

  # TODO This needs to be done differently.
  # Not sure why the form needs a map center on submit, it has two locations...
  # Maybe this is only needed if the user typed something in, did not geocode.
  # For now use the fromMap center.
  $('#new_trip_proxy').on 'submit', ->
    $('#map_center').val((CsMaps.tripMap.LMmap.getCenter().lat + ',' + CsMaps.tripMap.LMmap.getCenter().lng))

  $('#fromAddressMarkerButton').on 'click', ->
    show_map 'trip', 'from'
  $('#toAddressMarkerButton').on 'click', ->
    show_map 'trip', 'to'
  $('#fromCenterMyLocation').on 'click', ->
    get_my_location 'from'
  $('#toCenterMyLocation').on 'click', ->
    get_my_location 'to'

  $('#mapCloseButton').on 'click', ->
    hide_map 'trip'

  $('.trip_proxy_modes').on 'change', (e, addr, d) ->

  if typeof(CsMaps) != 'undefined' and CsMaps and CsMaps.tripMap
    CsMaps.tripMap.LMmap.on 'placechange', (e) ->
      latlng = (if e.latlng then e.latlng else {})
      reverse_geocode(latlng.lat, latlng.lng, CsMaps.tripMap.addressType)

  if typeof(CsMaps) != 'undefined' and CsMaps and CsMaps.expandedMap
    CsMaps.expandedMap.LMmap.on 'placechange', (e) ->
      latlng = (if e.latlng then e.latlng else {})
      reverse_geocode(latlng.lat, latlng.lng, CsMaps.tripMap.addressType)

  $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time').on "dp.change", ->
    validateDateTimes false
    return
  $('#trip_proxy_return_trip_date, #trip_proxy_return_trip_time').on "dp.change", ->
    validateDateTimes true
    return
  $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time').on "focusout", ->
    validateDateTimes false
    $(this).data('DateTimePicker').hide() unless isMobile()
    return
  $('#trip_proxy_return_trip_date, #trip_proxy_return_trip_time').on "focusout", ->
    validateDateTimes true
    $(this).data('DateTimePicker').hide() unless isMobile()
    return

  if $('.plan-a-trip').length > 0
    validateDateTimes false #when page load, validate outbound and return times
  
  ###
  if is_touch_device()
    $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time, #trip_proxy_return_trip_date, #trip_proxy_return_trip_time').attr('readonly', true)
  ###

  $('.place-container').on "click", ".delete-button", (e) ->
    tr = $(this).closest('tr')
    tr.fadeOut 400, ->
      key = $(tr).attr('place-marker-key')
      remove_marker(CsMaps.tripMap, key)
      tr.remove()
    return false

  $('#send_trip_by_email').on "shown.bs.modal", ->
    generate_maps(
      ->
        $('#send_email_button').prop('disabled', false)
    )
