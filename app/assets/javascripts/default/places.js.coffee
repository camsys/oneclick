# TODO There's a lot of duplication between this and trips.js.coffee

create_or_update_marker = (key, lat, lon, name, desc, iconStyle) ->  
  marker = findMarkerById(key)
  removeMarkerFromMap marker  if marker
  marker = createMarker(key, lat, lon, iconStyle, desc, name, true)
  addMarkerToMap marker, true
  marker

update_map = (type, e, s, d) ->
  console.log s
  if s.lat==null
    return
  if type=='from'
    key = 'start'
    icon = 'startIcon'
  else
    key = 'stop'
    icon = 'stopIcon'
  removeMatchingMarkers(key);
  marker = create_or_update_marker(key, s.lat, s.lon, s.name, s.full_address, icon);
  setMapToBounds();
  selectMarker(marker);

$ ->
  console.log 'places.js.coffee'
  $('#places-table td').on 'click', (e) ->
    $('#places-table tr').removeClass('success')
    $(e.target).closest('tr').addClass('success')
    # console.log e
    # console.log e.target.dataset.placename
    # console.log $('#from_place').data('foo')
    $('#from_place').val(e.target.dataset.address)
    $('#json').val(e.target.dataset.json)
    $('#place_name').val(e.target.dataset.placename)

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

  $(".places .place_picker").typeahead null,
    limit: 20,
    displayKey: "name"
    source: places.ttAdapter()
    templates:
      suggestion: Handlebars.compile([
        '<a>{{name}}</a>'
      ].join(''))
  
  $('#from_place').on 'typeahead:selected', (e, s, d) ->
    $('#json').val(JSON.stringify(s))
    update_map('from', e, s, d)
  $('#from_place').on 'typeahead:autocompleted', (e, s, d) ->
    $('#json').val(JSON.stringify(s))
    update_map('from', e, s, d)
