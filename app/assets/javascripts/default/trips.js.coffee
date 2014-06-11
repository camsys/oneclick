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

update_place = (placeText, type) ->
  if type =='from'
    placeid = 'trip_proxy_from_place'
  else
    placeid = 'trip_proxy_to_place'

  $('#' + placeid).val(placeText)

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
    show_map('trip', 'from')
  $('#trip_proxy_from_place').on 'focusout', () ->
    # hide_map('trip')
  $('#trip_proxy_to_place').on 'typeahead:opened', () ->
    show_map('trip', 'to')
  $('#trip_proxy_to_place').on 'focusout', () ->
    # hide_map('trip')

  $('#trip_proxy_from_place').on 'typeahead:selected', (e, addr, d) ->
    $('#from_place_object').val(JSON.stringify(addr))
    update_map(CsMaps.tripMap, 'from', e, addr, d)
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, addr, d) ->
    $('#from_place_object').val(JSON.stringify(addr))
    update_map(CsMaps.tripMap, 'from', e, addr, d)
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, addr, d) ->
    $('#to_place_object').val(JSON.stringify(addr))
    update_map(CsMaps.tripMap, 'to', e, addr, d)
  $('#trip_proxy_to_place').on 'typeahead:autocompleted', (e, addr, d) ->
    $('#to_place_object').val(JSON.stringify(addr))
    update_map(CsMaps.tripMap, 'to', e, addr, d)

  # TODO This needs to be done differently.
  # Not sure why the form needs a map center on submit, it has two locations...
  # Maybe this is only needed if the user typed something in, did not geocode.
  # For now use the fromMap center.
  $('#new_trip_proxy').on 'submit', ->
    $('#map_center').val((CsMaps.tripMap.LMmap.getCenter().lat + ',' + CsMaps.tripMap.LMmap.getCenter().lng))

  $('#fromAddressMarkerButton').on 'click', ->
    show_marker(CsMaps.tripMap, 'from')
  $('#toAddressMarkerButton').on 'click', ->
    show_marker(CsMaps.tripMap, 'to')

  $('#mapCloseButton').on 'click', ->
    hide_map('trip')
                        
  $('.trip_proxy_modes').on 'change', (e, addr, d) ->
    console.log e
    console.log $('.trip_proxy_modes input:checked').length

  if typeof(CsMaps) != 'undefined' and CsMaps and CsMaps.tripMap
    CsMaps.tripMap.LMmap.on 'placechange', (e) ->
      addr = e.latlon
      placeText = '(' + addr.lat + ', ' + addr.lon + ')' #TODO: need to display a real address instead of coords
      addr.name = placeText
      addrType = CsMaps.tripMap.addressType
      update_map(CsMaps.tripMap, addrType, e, addr, null)

      update_place(placeText, addrType)
