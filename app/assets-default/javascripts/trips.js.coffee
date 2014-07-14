# detect touch device
is_touch_device = ->
  return 'ontouchstart' in window or navigator.MaxTouchPoints > 0 or navigator.msMaxTouchPoints > 0

create_or_update_marker = (map, key, lat, lon, name, desc, iconStyle) ->  
  marker = map.findMarkerById(key)
  map.removeMarkerFromMap marker  if marker
  marker = map.createMarker(key, lat, lon, iconStyle, desc, name, true)
  map.addMarkerToMap marker, true
  marker

update_map = (map, type, e, addr, d) ->
  lat = addr.lat
  lon = addr.lon
  if lat==null
    $.ajax
      type: 'GET'
      url: '/place_details/' + addr.id
      async: false
      success: (data) ->
        lat = data.result.geometry.location.lat
        lon = data.result.geometry.location.lng
  if type=='from'
    key = 'start'
    icon = 'startIcon'
  else
    key = 'stop'
    icon = 'stopIcon'

  map.removeMatchingMarkers(key);
  marker = create_or_update_marker(map, key, lat, lon, addr.name, addr.full_address, icon);
  map.setMapToBounds();
  map.selectMarker(marker);

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

update_place = (placeText, type) ->
  if type =='from'
    placeid = 'trip_proxy_from_place'
    show_from_typeahead_hint = false
  else
    placeid = 'trip_proxy_to_place'
    show_to_typeahead_hint = false

  $('#' + placeid).typeahead('val', placeText)

process_location_from_map = (addr, dir) -> #update map marker from selected location, and update address input field from reverse geocoded address
  update_map(CsMaps.tripMap, dir, null, addr, null)
  update_place(addr.name, dir)

validateDateTimes = (isReturn) ->
  outboundDateData = $("#trip_proxy_outbound_trip_date").data("DateTimePicker")
  outboundTimeData = $("#trip_proxy_outbound_trip_time").data("DateTimePicker")
  returnDateData = $("#trip_proxy_return_trip_date").data("DateTimePicker")
  returnTimeData = $("#trip_proxy_return_trip_time").data("DateTimePicker")

  outboundDateStr = outboundDateData.date.format(outboundDateData.format)
  outboundTimeStr = outboundTimeData.date.format(outboundTimeData.format)
  returnDateStr = returnDateData.date.format(returnDateData.format)
  returnTimeStr = returnTimeData.date.format(returnTimeData.format)

  outboundDateTime = moment(outboundDateStr + " " + outboundTimeStr)
  returnDateTime = moment(returnDateStr + " " + returnTimeStr)
  minOutboundDateTime = moment()

  isOutboundChanged = false
  isReturnChanged = false

  if outboundDateTime < minOutboundDateTime
    outboundDateTime = minOutboundDateTime.next15()
    isOutboundChanged = true
  
  if returnDateTime <= outboundDateTime
    if isOutboundChanged
      returnDateTime = outboundDateTime.add(2, "hours")
      isReturnChanged = true
    else if isReturn
      outboundDateTime = (if returnDateTime.subtract(2, "hours") < minOutboundDateTime then minOutboundDateTime.next15() else returnDateTime.subtract(2, "hours"))
      isOutboundChanged = true
    else 
      returnDateTime = outboundDateTime.add(2, "hours")
      isReturnChanged = true

  if isReturnChanged
    returnDateData.setValue returnDateTime.toDate()
    returnTimeData.setValue returnDateTime.toDate()
  if isOutboundChanged
    outboundDateData.setValue outboundDateTime.toDate()
    outboundTimeData.setValue outboundDateTime.toDate()
  return

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

reverse_geocode = (lat, lon, dir) ->
  $.ajax
    type: 'GET'
    url: '/reverse_geocode?lat=' + lat + '&lon=' + lon
    success: (data) ->
      search_results = data.place_searching 
      if search_results instanceof Array
        i = 0
        result_count = search_results.length

        while i < result_count
          el = search_results[i]
          if typeof (el) is "object" and el
            actual_results = el.place_searching
            if actual_results instanceof Array and actual_results.length > 0
              addr =
                lat: lat
                lon: lon
                name: actual_results[0].formatted_address
              process_location_from_map(addr, dir)
              break
          i++
    failure: (error) ->
      console.log error

$ ->

  places = new Bloodhound
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace(d.value)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/place_search.json?no_map_partial=true'
      rateLimitWait: 600
      replace: (url, query) ->
        url = url + '&query=' + query
        # TODO This may need to get handled differently depending on whether map is shown
        url = url + '&map_center=' + (CsMaps.tripMap.LMmap.getCenter().lat + ',' + CsMaps.tripMap.LMmap.getCenter().lng)
        # url = url + '&map_center=33.7550,-84.3900'
        return url
    limit: 20
    # prefetch: '../data/films/post_1960.json'

  places.initialize()

  $(".plan-a-trip .place_picker").typeahead null,
    limit: 20,
    displayKey: "name"
    source: places.ttAdapter()
    templates:
      suggestion: Handlebars.compile([
        '<a>{{name}}</a>'
      ].join(''))

  # $(".plan-a-trip .place_picker").typeahead('val', 'foobar')

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
    $('#from_place_object').val(JSON.stringify(addr))
    update_map CsMaps.tripMap, 'from', e, addr, d
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, addr, d) ->
    $('#from_place_object').val(JSON.stringify(addr))
    update_map CsMaps.tripMap, 'from', e, addr, d

  $('#trip_proxy_to_place').on 'focusin', () ->
    show_to_typeahead_hint = true
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, addr, d) ->
    $('#to_place_object').val(JSON.stringify(addr))
    update_map CsMaps.tripMap, 'to', e, addr, d
  $('#trip_proxy_to_place').on 'typeahead:autocompleted', (e, addr, d) ->
    $('#to_place_object').val(JSON.stringify(addr))
    update_map CsMaps.tripMap, 'to', e, addr, d

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

  $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time').on "dp.change", ->
    validateDateTimes false
    return
  $('#trip_proxy_return_trip_date, #trip_proxy_return_trip_time').on "dp.change", ->
    validateDateTimes true
    return
  $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time').on "focusout", ->
    validateDateTimes false
    return
  $('#trip_proxy_return_trip_date, #trip_proxy_return_trip_time').on "focusout", ->
    validateDateTimes true
    return

  if $('.plan-a-trip').length > 0
    validateDateTimes false #when page load, validate outbound and return times

  if is_touch_device
    $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time, #trip_proxy_return_trip_date, #trip_proxy_return_trip_time').attr('readonly', true)

  return
      
