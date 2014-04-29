create_or_update_marker = (map, key, lat, lon, name, desc, iconStyle) ->  
  marker = map.findMarkerById(key)
  map.removeMarkerFromMap marker  if marker
  marker = map.createMarker(key, lat, lon, iconStyle, desc, name, true)
  map.addMarkerToMap marker, true
  marker

update_map = (map, type, e, s, d) ->
  lat = s.lat
  lon = s.lon
  if lat==null
    $.ajax
      type: 'GET'
      url: '/place_details/' + s.id
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
  marker = create_or_update_marker(map, key, lat, lon, s.name, s.full_address, icon);
  map.setMapToBounds();
  map.selectMarker(marker);

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

show_map = (dir) ->
  $('#' + dir + "MapContainer").removeClass('hide')
  CsMaps[dir + "Map"].refresh()

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
        # url = url + '&map_center=' + (LMmap.getCenter().lat + ',' + LMmap.getCenter().lng)
        url = url + '&map_center=33.7550,-84.3900'
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
  
  # Show/hide map popover when in input field
  $('#trip_proxy_from_place').on 'typeahead:opened', () ->
    show_map('trip')
  $('#trip_proxy_from_place').on 'focusout', () ->
    hide_map('trip')
  $('#trip_proxy_to_place').on 'typeahead:opened', () ->
    show_map('trip')
  $('#trip_proxy_to_place').on 'focusout', () ->
    hide_map('trip')

  $('#trip_proxy_from_place').on 'typeahead:selected', (e, s, d) ->
    $('#from_place_object').val(JSON.stringify(s))
    update_map(CsMaps.tripMap, 'trip', e, s, d)
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, s, d) ->
    $('#from_place_object').val(JSON.stringify(s))
    update_map(CsMaps.tripMap, 'trip', e, s, d)
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, s, d) ->
    $('#to_place_object').val(JSON.stringify(s))
    update_map(CsMaps.tripMap, 'trip', e, s, d)
  $('#trip_proxy_to_place').on 'typeahead:autocompleted', (e, s, d) ->
    $('#to_place_object').val(JSON.stringify(s))
    update_map(CsMaps.tripMap, 'trip', e, s, d)

  # TODO This needs to be done differently.
  # Not sure why the form needs a map center on submit, it has two locations...
  # Maybe this is only needed if the user typed something in, did not geocode.
  # For now use the fromMap center.
  $('#new_trip_proxy').on 'submit', ->
    $('#map_center').val((CsMaps.tripMap.getCenter().lat + ',' + CsMaps.tripMap.getCenter().lng))

  $('#fromAddressMarkerButton').on 'click', ->
    toggle_map('trip')
  $('#toAddressMarkerButton').on 'click', ->
    toggle_map('trip')
