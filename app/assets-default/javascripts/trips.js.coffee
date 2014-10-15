# detect touch device
is_touch_device = ->
  return "ontouchstart" of window or navigator.MaxTouchPoints > 0 or navigator.msMaxTouchPoints > 0

remove_marker = (map, key) ->
  marker = map.findMarkerById(key)
  map.removeMarkerFromMap marker  if marker

create_or_update_marker = (map, key, lat, lon, name, desc, iconStyle) ->
  remove_marker(map, key)
  marker = map.createMarker(key, lat, lon, iconStyle, desc, name, false)
  map.addMarkerToMap marker, true
  marker

update_map = (map, dir, e, addr, d) ->
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

  map.removeMatchingMarkers(key);
  marker = create_or_update_marker(map, key, lat, lon, addr.name, addr.full_address, icon);
  map.setMapToBounds();
  map.selectMarker(marker);
  addr.lat = lat
  addr.lon = lon
  add_multi_od_places(dir, addr.name, addr)

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
  addr_obj = {
    data: addr_data,
    name: addr_text,
    address: addr_text,
    lat: addr_data.lat,
    lon: addr_data.lon,
    is_full: false
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
    "<td>" + addr_text + "</td>" +
    "<td class='center nowrap'><button class='btn btn-sm btn-danger delete-button'><i class='fa fa-times'></i></button></td>" +
    "</tr>"
  $('#' + dir + '_places').append new_place_row_tags

  $('#' + dir + '_places').attr('place-counter', new_place_counter)
  $('#trip_proxy_' + dir + '_place').attr('last-multi-od-value', addr_text)
  setTimeout (->
    $('#trip_proxy_' + dir + '_place').val('')
    return
  ), 100

  return

process_location_from_map = (addr, dir) -> #update map marker from selected location, and update address input field from reverse geocoded address
  update_map(CsMaps.tripMap, dir, null, addr, null)
  update_place(addr.name, dir, addr)

validateDateTimes = (isReturn) ->
  outboundDateField = $("#trip_proxy_outbound_trip_date")
  outboundTimeField = $("#trip_proxy_outbound_trip_time")
  returnDateField = $("#trip_proxy_return_trip_date")
  returnTimeField = $("#trip_proxy_return_trip_time")
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

  outboundDateTime = moment(outboundDateField.val() + " " + outboundTimeField.val(), outboundDateData.format + " " + outboundTimeData.format)
  returnDateTime = moment(returnDateField.val() + " " + returnTimeField.val(), returnDateData.format + " " + returnTimeData.format)
  outboundDateTimeInvalid =  !outboundDateTime.isValid()
  returnDateTimeInvalid = !returnDateTime.isValid()
  minOutboundDateTime = moment()

  isOutboundChanged = false
  isReturnChanged = false

  if outboundDateTimeInvalid or outboundDateTime < minOutboundDateTime
    outboundDateTime = minOutboundDateTime.clone().next15()
    isOutboundChanged = true


  if returnDateTimeInvalid or returnDateTime <= outboundDateTime
    if returnDateTimeInvalid or isOutboundChanged
      returnDateTime = outboundDateTime.clone().add(2, "hours")
      isReturnChanged = true
    else if isReturn
      if returnDateTime.clone().subtract(2, "hours") <= minOutboundDateTime
        outboundDateTime = minOutboundDateTime.clone().next15()
        returnDateTime = outboundDateTime.clone().add(2, "hours")
        isReturnChanged = true
      else
        outboundDateTime = returnDateTime.clone().subtract(2, "hours")
      isOutboundChanged = true
    else
      returnDateTime = outboundDateTime.clone().add(2, "hours")
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

generate_maps = (after) ->
  user_id = $('meta[name="user_id"]').attr('content')
  trip_id = $('meta[name="trip_id"]').attr('content')
  itinerary_ids = $('meta[name="itinerary_ids"]').attr('content')
  locale = $('meta[name="locale"]').attr('content')
  $.ajax
    type: 'GET'
    url: '/users/' + user_id + '/trips/' + trip_id + '/itineraries/' + itinerary_ids + '/request_create_map'
  timer = setInterval (->
    progress = $('#prepare_print_maps .progress-bar').attr('aria-valuenow')
    if (progress=="100")
      clearInterval(timer)    
      after()
    $.ajax
      type: 'GET'
      url: '/users/' + user_id + '/trips/' + trip_id + '/itineraries/' + itinerary_ids + '/map_status'
      async: false
      success: (data) ->
        total = data['itineraries'].length
        done = data['itineraries'].filter (i) ->
          i['has_map']==true
        for i in done
          $('#print_map_' + i.id).html('<img src="' + i.url + '">')
        percent = if (done.length > 0)
          done.length/total*100
        else
          20
        $('#prepare_print_maps .progress-bar').css('width', percent + '%')
        $('#prepare_print_maps .progress-bar').html(percent + '%')
        $('#prepare_print_maps .progress-bar').attr('aria-valuenow', percent)
    ), 1000

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
    if $('#from_places').length == 0
      $('#trip_proxy_to_place').focus()
      $('#trip_proxy_to_place').trigger('touchstart')
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, addr, d) ->
    $('#from_place_object').val(JSON.stringify(addr))
    update_map CsMaps.tripMap, 'from', e, addr, d

  $('#trip_proxy_to_place, #trip_proxy_outbound_arrive_depart').on 'touchstart', () ->
    $(this).focus()
  $('#trip_proxy_to_place').on 'focusin', () ->
    show_to_typeahead_hint = true
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, addr, d) ->
    $('#to_place_object').val(JSON.stringify(addr))
    update_map CsMaps.tripMap, 'to', e, addr, d
    if $('#to_places').length == 0
      $('#trip_proxy_outbound_arrive_depart').focus()
      $('#trip_proxy_outbound_arrive_depart').trigger('touchstart')
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
    $(this).data('DateTimePicker').hide()
    return
  $('#trip_proxy_return_trip_date, #trip_proxy_return_trip_time').on "focusout", ->
    validateDateTimes true
    $(this).data('DateTimePicker').hide()
    return

  if $('.plan-a-trip').length > 0
    validateDateTimes false #when page load, validate outbound and return times

  if is_touch_device()
    $('#trip_proxy_outbound_trip_date, #trip_proxy_outbound_trip_time, #trip_proxy_return_trip_date, #trip_proxy_return_trip_time').attr('readonly', true)

  $('.place-container').on "click", ".delete-button", (e) ->
    tr = $(this).closest('tr')
    tr.fadeOut 400, ->
      key = $(tr).attr('place-marker-key')
      remove_marker(CsMaps.tripMap, key)
      tr.remove()
    return false

  if ($('body.trips.show_printer_friendly').length > 0)
    $('#prepare_print_maps').modal('show')
    generate_maps(
      ->
        $('#prepare_print_maps').modal('hide')
        setTimeout (-> window.print()), 2000
      )

  $('#send_trip_by_email').on "shown.bs.modal", ->
    generate_maps(
      ->
        $('#prepare_print_maps').hide()
        $('#send_email_button').prop('disabled', false) 
    )
