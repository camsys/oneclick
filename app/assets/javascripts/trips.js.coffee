$ ->
  # Twitter typeahead exmaple.

  # instantiate the bloodhound suggestion engine
  numbers = new Bloodhound(
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace d.num

    queryTokenizer: Bloodhound.tokenizers.whitespace
    local: [
      {
        num: "one"
      }
      {
        num: "two"
      }
      {
        num: "three"
      }
      {
        num: "four"
      }
      {
        num: "five"
      }
      {
        num: "six"
      }
      {
        num: "seven"
      }
      {
        num: "eight"
      }
      {
        num: "nine"
      }
      {
        num: "ten"
      }
    ]
  )

  # initialize the bloodhound suggestion engine
  numbers.initialize()

  # instantiate the typeahead UI
  console.log $("#trip_proxy_from_place")

  $("#trip_proxy_from_place").typeahead null,
    displayKey: "num"
    source: numbers.ttAdapter()
    templates:
      suggestion: Handlebars.compile([
        '<li><a>{{num}}</a></li>'
        #   ,
        # '<p class="repo-name">{{name}}</p>',
        # '<p class="repo-description">{{description}}</p>'
      ].join(''))
