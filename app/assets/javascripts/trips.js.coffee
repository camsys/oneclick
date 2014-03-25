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
    console.log 'selected'
    $('#from_place_object').val(JSON.stringify(s))
  $('#trip_proxy_from_place').on 'typeahead:autocompleted', (e, s, d) ->
    console.log 'autocompleted'
    $('#from_place_object').val(JSON.stringify(s))
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, s, d) ->
    console.log 'selected'
    $('#to_place_object').val(JSON.stringify(s))
  $('#trip_proxy_to_place').on 'typeahead:autocompleted', (e, s, d) ->
    console.log 'autocompleted'
    $('#to_place_object').val(JSON.stringify(s))

  $('#new_trip_proxy').on 'submit', ->
    $('#map_center').val((LMmap.getCenter().lat + ',' + LMmap.getCenter().lng))
