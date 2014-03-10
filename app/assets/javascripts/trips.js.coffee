$ ->
  # Twitter typeahead exmaple.

  # instantiate the bloodhound suggestion engine
  places = new Bloodhound
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace(d.value)
    queryTokenizer:
      Bloodhound.tokenizers.whitespace
    remote:
      '/place_search.json?no_map_partial=true&query=%QUERY'
    # prefetch: '../data/films/post_1960.json'

  # initialize the bloodhound suggestion engine
  places.initialize()

  $("#trip_proxy_from_place").typeahead null,
    displayKey: "name"
    source: places.ttAdapter()
    templates:
      suggestion: Handlebars.compile([
        '<li><a>{{name}}</a></li>'
        #   ,
        # '<p class="repo-name">{{name}}</p>',
        # '<p class="repo-description">{{description}}</p>'
      ].join(''))
  $('#trip_proxy_from_place').on 'typeahead:selected', (e, s, d) ->
    $('#from_place_object').val(JSON.stringify(s))

  $("#trip_proxy_to_place").typeahead null,
    displayKey: "name"
    source: places.ttAdapter()
    templates:
      suggestion: Handlebars.compile([
        '<li><a>{{name}}</a></li>'
        #   ,
        # '<p class="repo-name">{{name}}</p>',
        # '<p class="repo-description">{{description}}</p>'
      ].join(''))
  $('#trip_proxy_to_place').on 'typeahead:selected', (e, s, d) ->
    $('#to_place_object').val(JSON.stringify(s))

