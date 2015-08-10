jQuery(function($) {
    var Typeahead = $('<div>').typeahead().data('typeahead').constructor,
        typeaheadDelay = +$('meta[name="ui_typeahead_delay"]').attr('content'),
        typeaheadMinChars = +$('meta[name="ui_typeahead_min_chars"]').attr('content'),
        typeaheadListLength = +$('meta[name="ui_typeahead_list_length"]').attr('content'),
        typeaheadTimeouts = {};

    // Enable typeahead for the places forms
    Typeahead.prototype.listen = function() {
        this.$element
            .on('focus', $.proxy(this.focus, this))
        // .on('blur',     $.proxy(this.blur, this))
            .on('keypress', $.proxy(this.keypress, this))
            .on('keyup', $.proxy(this.keyup, this))

        if (this.eventSupported('keydown')) {
            this.$element.on('keydown', $.proxy(this.keydown, this))
        }

        this.$menu
            .on('click', $.proxy(this.click, this))
            .on('mouseenter', 'li', $.proxy(this.mouseenter, this))
            .on('mouseleave', 'li', $.proxy(this.mouseleave, this))
    };

    Typeahead.prototype.click = function(e) {
        e.stopPropagation();
        e.preventDefault();
        this.select();
        // this.$element.focus();
    }

    Typeahead.prototype.process = function(items) {
        var that = this;

        items = $.grep(items, function(item) {
            if (!item.name) item.name = item.description;
            return that.matcher(item);
        });

        items = this.sorter(items);

        if (!items.length)
            return this.shown ? this.hide() : this;


        return this.render(items.slice(0, this.options.items)).show();
    };

    Typeahead.prototype.render = function(items) {
        var that = this;

        items = $(items).map(function(i, item) {
            i = $(that.options.item).attr('data-value', item);
            i.find('a').html(that.highlighter(item));
            return i[0];
        })

        items.first().addClass('active');

        this.$menu
            .html(items)
            .closest('.js-typeahead-visibility-root').find('.search-dropdown-container')
            .data('scroll-content').resetOffset();

        return this;
    };

    Typeahead.prototype.show = function() {
        this.$menu.closest('.js-typeahead-visibility-root')
            .removeClass('hidden')
            .find('.search-dropdown-container')
            .data('scroll-content').refresh();
        this.shown = true;
        return this;
    };

    Typeahead.prototype.hide = function() {
        this.$menu.closest('.js-typeahead-visibility-root')
            .addClass('hidden')
            .find('.search-dropdown-container')
            .data('scroll-content').refresh();
        this.shown = false;
        return this;
    };

    window.setupPlacesSearchTypeahead = function(locationName, markerName) {
        var $placeField        = $('#trip_proxy_' + locationName + '_place')
          , $selectedTypeField = $('#' + locationName + '_place_selected_type')
          , $selectedField     = $('#' + locationName + '_place_selected');

        $placeField.on('change', function() {
            $selectedTypeField.val('').change();
            $selectedField.val('').change();
        });

        $placeField.typeahead({
            items: typeaheadListLength,
            minLength: typeaheadMinChars,
            menu: $('ul.nav.nav-list')[0],
            item: '<li><a class="address-select" href="#"></a></li>',
            source: function(query, process) {
                if (typeaheadTimeouts[locationName]) clearTimeout(typeaheadTimeouts[locationName]);

                typeaheadTimeouts[locationName] = setTimeout(function() {

                    var saved_places = new Bloodhound({
                        datumTokenizer: function(d) {
                         return  Bloodhound.tokenizers.whitespace(d.value);
                        },
                        queryTokenizer: Bloodhound.tokenizers.whitespace,
                        remote: {
                            url: '/place_search.json?no_map_partial=true',
                            rateLimitWait: 600,
                            replace: function(url, query) {
                                url = url + '&query=' + query;
                                return url;
                            }
                        },
                        limit: 10
                    });


                    var autocomplete_service_config = {};

                    var bounds = CsMaps.lmap.LMmap.getBounds();

                    autocomplete_service_config.bounds = new google.maps.LatLngBounds(
                        new google.maps.LatLng(bounds.getSouthWest().lat,bounds.getSouthWest().lng),
                        new google.maps.LatLng(bounds.getNorthEast().lat,bounds.getNorthEast().lng)
                    );

                    var google_place_picker = new AddressPicker({
                        autocompleteService: autocomplete_service_config
                    });

                    saved_places.initialize();

                    var remainingCalls = 2
                      , data = [];

                    // poor man's async
                    function processQueue(list) {
                        remainingCalls--;
                        data = data.concat(list);
                        console.log('list:', list);
                        console.log('data:', data);


                        if (remainingCalls < 1) {
                            process(data);
                        }
                    };

                    saved_places.ttAdapter()        (query, processQueue);
                    google_place_picker.ttAdapter() (query, processQueue);
                }, typeaheadDelay);

                //     return $.ajax({
                //         url: $('#trip_proxy_' + locationName + '_place').data('link'),
                //         type: 'get',
                //         data: {
                //             query: query,
                //             map_center: CsMaps.lmap.LMmap.getCenter().lat + ',' + CsMaps.lmap.LMmap.getCenter().lng
                //         },
                //         dataType: 'json',
                //         success: function(result) {
                //             var resultList = result.map(function(item) {
                //                 var aItem = {
                //                     index: item.index,
                //                     type: item.type,
                //                     id: item.id,
                //                     name: item.name,
                //                     desc: item.description,
                //                     lat: item.lat,
                //                     lon: item.lon,
                //                     addr: item.address
                //                 };

                //                 return JSON.stringify(aItem);
                //             });

                //             return process(resultList);
                //         },
                //         error: function(data) {
                //             show_alert('We are sorry but something went wrong. Please try again.');
                //         }
                //     });
            },

            matcher: function(obj) {
                var item;

                if (typeof obj == 'string') {
                    item = JSON.parse(obj);
                } else {
                    item = obj;
                }

                return~ item.name.toLowerCase().indexOf(this.query.toLowerCase())
            },

            sorter: function(items) {
                var beginswith = [],
                    caseSensitive = [],
                    caseInsensitive = [],
                    item,
                    obj;

                while (obj = items.shift()) {
                    if (typeof obj == 'string') {
                        item = JSON.parse(obj);
                    } else {
                        item = obj;
                    }


                    if (!item.name.toLowerCase().indexOf(this.query.toLowerCase()))
                        beginswith.push(JSON.stringify(item));
                    else if (~item.name.indexOf(this.query))
                        caseSensitive.push(JSON.stringify(item));
                    else
                        caseInsensitive.push(JSON.stringify(item));
                }

                return beginswith.concat(caseSensitive, caseInsensitive);
            },

            highlighter: function(obj) {
                var item;

                if (typeof obj == 'string') {
                    item = JSON.parse(obj);
                } else {
                    item = obj;
                }

                var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
                return item.name.replace(new RegExp('(' + query + ')', 'ig'), function($1, match) {
                    return '<strong>' + match + '</strong>'
                })
            },

            updater: function(obj) {
                var item;

                if (typeof obj == 'string') {
                    item = JSON.parse(obj);
                } else {
                    item = obj;
                }


                function showMarker() {
                    // create marker on the map
                    CsMaps.lmap.removeMatchingMarkers(markerName);
                    var marker = create_or_update_marker(markerName, item.lat, item.lon, item.name, item.desc, markerName + 'Icon');
                    zoom_to_marker(marker);
                }

                if (item.place_id) {
                    $.get('/place_details/' + item.place_id + '.json', function(data) {
                        item.lat = data.result.geometry.location.lat;
                        item.lon = data.result.geometry.location.lng;
                        item.id = item.place_id;
                        showMarker();
                    });
                } else {
                    showMarker();
                }

                setTimeout(function() {
                    window.setAddressObject(locationName, item);
                    // Update the UI
                    $selectedTypeField.val(item.type).change();
                    debugger;
                    $selectedField.val(item.place_id || item.id).change();
                }, 0);

                return item.name;
            }
        });
    };

    window.setAddressObject = function(locationName, item) {
        var $objectField = $('#trip_proxy_' + locationName + '_place_object');

        var type_map = [
            null,
            'POI_TYPE',
            'CACHED_ADDRESS_TYPE',
            'PLACES_TYPE',
            'RAW_ADDRESS_TYPE',
            'PLACES_AUTOCOMPLETE_TYPE',
            'KIOSK_LOCATION_TYPE',
        ]

        item.type_name = type_map[item.type];

        if (!item.raw_address)  item.raw_address  = item.addr;
        if (!item.address)      item.address      = item.addr;
        if (!item.address1)     item.address1     = item.addr;

        $objectField.val(JSON.stringify(item))
    };

    // User has selected an alternate address in the list
    $('.address-select').click(function() {
        select_candidate_address($(this));
        return false;
    });

    // User has selected an alternate address in the list
    $('.address-select').hover(function() {
        var addr = $(this).data('addr');
        // Pan to the marker
        CsMaps.lmap.selectMarkerByName(addr);
    });

    scrollContent($, {
        rootSel: '.search-dropdown-container',
        listSel: '.js-candidate-list-inner',
        property: 'margin-top',
        size: 273,
        total: function($root) {
            return $root.find('.js-candidate-list-inner ul.nav.nav-list').height();
        }
    });
});