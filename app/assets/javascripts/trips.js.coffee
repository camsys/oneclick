create_or_update_marker = (key, lat, lon, name, desc, iconStyle) ->  
  marker = findMarkerById(key)
  removeMarkerFromMap marker  if marker
  marker = createMarker(key, lat, lon, iconStyle, desc, name, true)
  addMarkerToMap marker, true
  marker

update_map = (type, e, s, d) ->
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
  removeMatchingMarkers(key);
  marker = create_or_update_marker(key, lat, lon, s.name, s.full_address, icon);
  setMapToBounds();
  selectMarker(marker);

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
        url = url + '&map_center=' + (LMmap.getCenter().lat + ',' + LMmap.getCenter().lng)
        return url
    limit: 20
    # prefetch: '../data/films/post_1960.json'

  places.initialize()

  $(".place_picker").typeahead null,
    limit: 20,
    displayKey: "name"
    source: places.ttAdapter()
    templates:
      suggestion: Handlebars.compile([
        '<a>{{name}}</a>'
      ].join(''))
  
  $('#trip_proxy_from_place').on 'typeahead:selected', (e, s, d) ->
    $('#from_place_object').val(JSON.stringify(s))
    update_map('from', e, s, d)
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, s, d) ->
    $('#from_place_object').val(JSON.stringify(s))
    update_map('from', e, s, d)
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, s, d) ->
    $('#to_place_object').val(JSON.stringify(s))
    update_map('to', e, s, d)
  $('#trip_proxy_to_place').on 'typeahead:autocompleted', (e, s, d) ->
    $('#to_place_object').val(JSON.stringify(s))
    update_map('to', e, s, d)

  $('#new_trip_proxy').on 'submit', ->
    $('#map_center').val((LMmap.getCenter().lat + ',' + LMmap.getCenter().lng))
