// From Crockford Javascript: The Good Parts.
// TODO move elsewhere, make available globally
if (typeof Object.create !== 'function') {
    Object.create = function(o) {
        var F = function() {};
        F.prototype = o;
        return new F();
    };
}

var CsLeaflet = CsLeaflet || {};

CsLeaflet.Leaflet = {
    //options
    _options: null,

    // Leaflet map rendering functions


    /*
     * Add a set of markers to the map. Markers are defined as an array of json hashes. Each
     * JSON hash has values latitude, longitude, iconClass, popupText, open
     */
    LMmarkers: new Array(),
    LMcircles: new Array(),
    LMpolylines: new Array(),
    LMmultipolygons: new Array(),
    LMmap: null,
    LMbounds: null,
    LMcacheBounds: null,
    LMcurrent_popup: null,

    LMsidewalk_feedback_tool: null,

    OPENSTREETMAP_URL: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    OPENSTREETMAP_ATTRIB: 'Map data © OpenStreetMap contributors',

    CLOUDMADE_URL: 'http://{s}.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/{styleId}/256/{z}/{x}/{y}.png',
    CLOUDMADE_ATTRIB: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://cloudmade.com">CloudMade</a>',

    STREET_VIEW: 'streetView',
    CURRENT_LOCATION: 'currentLocation',
    LOCATION_SELECT: 'locationSelect',
    SIDEWALK_FEEDBACK: 'sidewalkFeedback',

    /*
     * Must be called first. Pass the Id of the div containing the map and any options
     * that should be passed to the map constructor
     */

    // TODO make this a constructor

    init: function(mapId, options) {
        this._options = options;

        this.LMmap = L.map(mapId, { zoomControl: false, scrollWheelZoom: options.scroll_wheel_zoom, zoomAnimation: options.zoom_animation});
        this.addZoomControl();

        //alert(options.tile_provider);
        //alert(options.min_zoom);
        //alert(options.max_zoom);
        if (options.tile_provider == 'OPENSTREETMAP') {
            var mapUrl = this.OPENSTREETMAP_URL;
            var mapAttrib = this.OPENSTREETMAP_ATTRIB;
            L.tileLayer(mapUrl, {
                minZoom: options.min_zoom,
                maxZoom: options.max_zoom,
                attribution: mapAttrib
            }).addTo(this.LMmap);
        } else if (options.tile_provider == 'GOOGLEMAP') {
            var googleLayer = new L.Google('ROADMAP');
            this.LMmap.addLayer(googleLayer);
        } else {
            var mapUrl = this.CLOUDMADE_URL;
            var mapAttrib = this.CLOUDMADE_ATTRIB;
            L.tileLayer(mapUrl, {
                minZoom: options.min_zoom,
                maxZoom: options.max_zoom,
                attribution: mapAttrib,
                styleId: options.tile_style_id
            }).addTo(this.LMmap);
        }

        //register CurrentLocation Control
        if(options.show_my_location) {
            this.addCurrentLocationControl();
        }

        //register StreetView Control
        if(options.show_street_view) {
            this.addStreetViewControl();
        }

        //register LocationSelect Control
        if(options.show_location_select) {
            this.addLocationSelectControl();
        }

        //register FeedbackInput Control
        if(options.show_sidewalk_feedback) {
            if(CsLeaflet.SidewalkFeedbackTool) {
                var sidewalkFeedbackTool = Object.create(CsLeaflet.SidewalkFeedbackTool);
                sidewalkFeedbackTool.init(this, options.sidewalk_feedback_options);
                this.LMsidewalk_feedback_tool = sidewalkFeedbackTool;
            }
        }

        this.registerMapClickEvent();
        this.registerPopupOpenEvent();
    },

    /**
     * Centers the map on a specified marker without changing the zoom level
     */
    centerOnMarker: function(markerId) {
        var marker = findMarkerById(markerId);
        if (marker) {
            var latlng = marker.getLatLng();
            this.panTo(latlng.lat, latlng.lng);
        }
    },

    /*
     * Pans the map to a gven coordinate without changing the zoom level
     */
    panTo: function(lat, lng) {
        var latlng = new L.LatLng(lat, lng);
        this.LMmap.panTo(latlng);
    },

    /*
     * Called last after the map has been configured.
     */
    showMap: function() {
        // Add the markers to the map
        for (var i = 0; i < this.LMmarkers.length; i++) {
            this.LMmap.addLayer(this.LMmarkers[i]);
        }
        // Add the circles to the map
        for (var i = 0; i < this.LMcircles.length; i++) {
            this.LMmap.addLayer(this.LMcircles[i]);
        }
        // Add the polylines to the map
        for (var i = 0; i < this.LMpolylines.length; i++) {
            this.LMmap.addLayer(this.LMpolylines[i]);
        }

        // Add the MultiPolygons to the map
        for (var i = 0; i < this.LMmultipolygons.length; i++) {
            this.LMmap.addLayer(this.LMmultipolygons[i]);
        }

        var mapBounds;
        if (this.LMmarkers.length > 0) {
            mapBounds = this.calcMapBounds(this.LMmarkers);
        } else {
            mapBounds = this.LMbounds;
        }
        this.LMmap.fitBounds(mapBounds);
    },

    showMapOriginal: function() {
        mapBounds = this.LMcacheBounds;
        this.LMmap.fitBounds(mapBounds);
    },

    /*
     * Replaces the markers on the map with a new set
     */
    replaceMarkers: function(arr, updateMap) {
        //alert('Replacing Markers');
        this.removeMarkers();
        this.addMarkers(arr);
        if (updateMap) {
            //alert('Updating map');
            this.showMap();
        } else {
            // Add the markers to the map
            for (var i = 0; i < this.LMmarkers.length; i++) {
                this.LMmap.addLayer(this.LMmarkers[i]);
            }
        }
    },

    replaceSidewalkFeedbackMarkers: function(arr, updateMap) {
        var sidewalk_feedback_tool = this.LMsidewalk_feedback_tool;
        if(sidewalk_feedback_tool) {
            sidewalk_feedback_tool.removeSidewalkFeedbackMarkers();
            sidewalk_feedback_tool.addSidewalkFeedbackMarkers(arr);
            if (updateMap) {
                this.showMap();
            } else {
                this.LMmap.addLayer(sidewalk_feedback_tool.LMsidewalk_feedback_layergroup);
            }
        }
    },

    /*
     * Removes the markers from the map and re-draws them from
     * the markers array
     */
    refreshMarkers: function() {
        for (var i = 0; i < this.LMmarkers.length; i++) {
            this.LMmap.removeLayer(this.LMmarkers[i]);
        }
        // Add the markers to the map
        for (var i = 0; i < this.LMmarkers.length; i++) {
            this.LMmap.addLayer(this.LMmarkers[i]);
        }
    },

    /*
     * Replaces the circles on the map with a new set
     */
    replaceCircles: function(arr, updateMap) {
        //alert('Replacing Circles');
        this.removeCircles();
        this.addCircles(arr);
        if (updateMap) {
            //alert('Updating map');
            this.showMap();
        } else {
            for (var i = 0; i < this.LMcircles.length; i++) {
                this.LMmap.addLayer(this.LMcircles[i]);
            }
        }
    },

    /*
     * Replaces the polylines on the map with a new set
     */
    replacePolylines: function(arr, updateMap) {
        //alert('Replacing Polylines');
        this.removePolylines();
        this.addPolylines(arr);
        if (updateMap) {
            //alert('Updating map');
            this.showMap();
        } else {
            for (var i = 0; i < this.LMpolylines.length; i++) {
                this.LMmap.addLayer(this.LMpolylines[i]);
            }
        }
    },

    removeMarkersKeepCache: function() {
        for (var i = 0; i < this.LMmarkers.length; i++) {
            this.LMmap.removeLayer(this.LMmarkers[i]);
        }
    },

    /*
     *
     */
    removeMarkers: function() {
        // Loop through the markers and remove them from the map
        //alert('Removing markers from map');
        for (var i = 0; i < this.LMmarkers.length; i++) {
            //alert('Removing Marker ' + this.LMmarkers[i].id);
            this.LMmap.removeLayer(this.LMmarkers[i]);
        }
        this.LMmarkers = new Array();
    },

    /*
     *
     */
    removeCircles: function() {
        // Loop through the circles and remove them from the map
        for (var i = 0; i < this.LMcircles.length; i++) {
            this.LMmap.removeLayer(this.LMcircles[i]);
        }
        this.LMcircles = new Array();
    },

    /*
     *
     */
    removePolylines: function() {
        // Loop through the polylines and remove them from the map
        for (var i = 0; i < this.LMpolylines.length; i++) {
            this.LMmap.removeLayer(this.LMpolylines[i]);
        }
        this.LMpolylines = new Array();
    },

    /*
     * Processes an array of json objects containing marker definitions and adds them
     * to the array of markers
     */
    addMarkers: function(arr) {
        //alert('Adding ' + data.length + ' markers');

        for (var i = 0; i < arr.length; i++) {
            var obj = arr[i];
            if (obj.lat == null || obj.lng == null) {
                continue;
            }
            var id = obj.id;
            var lat = obj.lat;
            var lng = obj.lng;
            var iconClass = obj.iconClass;
            var popupText = obj.description;
            var title = obj.title;
            var open = obj.open;
            marker = this.createMarker(id, lat, lng, iconClass, popupText, title, open);

            // Add this marker to the list of markers
            this.LMmarkers.push(marker);
        }
    },

    // Adds a marker to the map and optionally puts it in the cache
    addMarkerToMap: function(marker, cache) {
        if (cache) {
            // Add this marker to the list of markers
            this.LMmarkers.push(marker);
        }
        this.LMmap.addLayer(marker);
    },

    // Removes a marker from the map and removes it from the cache
    // if it is stored there
    removeMarkerFromMap: function(marker) {
        markers = new Array();
        for (var i = 0; i < this.LMmarkers.length; i++) {
            if (marker == this.LMmarkers[i]) {
                continue;
            } else {
                markers.push(this.LMmarkers[i]);
            }
        }
        this.LMmarkers = markers;
        this.LMmap.removeLayer(marker);
    },

    // Removes markers with an id matching the input string
    removeMatchingMarkers: function(match) {
        markers = new Array();
        for (var i = 0; i < this.LMmarkers.length; i++) {
            var marker = this.LMmarkers[i];
            var id = marker.id;
            if (id != null && id.indexOf(match) != -1) {
                this.LMmap.removeLayer(marker);
                continue;
            } else {
                markers.push(marker);
            }
        }
        this.LMmarkers = markers;
    },

    /*
     *
     */
    addCircles: function(arr) {
        for (var i = 0; i < arr.length; i++) {
            var obj = arr[i];
            var lat = obj.lat;
            var lng = obj.lng;
            var radius = obj.radius;
            var options = {};
            if (obj.options) {
                options = obj.options;
            }
            this.addCircle(lat, lng, radius, options);
        }
    },


    /*
     *
     */
    addMultipolygons: function(arr) {
        for (var i = 0; i < arr.length; i++) {
            var obj = arr[i];
            var id = obj.id;
            var geom = obj.geom;
            var options = {};
            if (obj.options) {
                options = obj.options;
            }
            this.addMultipolygon(geom, options);
        }
    },

    /*
     *
     */
    addPolylines: function(arr) {
        for (var i = 0; i < arr.length; i++) {
            var obj = arr[i];
            var id = obj.id;
            var geom = obj.geom;
            var options = {};
            if (obj.options) {
                options = obj.options;
            }
            this.addPolyline(geom, options);
        }
    },

    selectMarkerById: function(id) {
        marker = this.findMarkerById(id);
        if (marker) {
            this.selectMarker(marker);
        }
    },

    selectMarkerByName: function(name) {
        marker = this.findMarkerByName(name);
        if (marker) {
            this.selectMarker(marker);
        }
    },

    findMarkerInStorage: function(id) {
        var json = localStorage.getItem('marker:' + id);

        if (json) {
            var data = JSON.parse(json);
            return this.createMarker(data.id, data.lat, data.lng, data.iconClass, data.popupText, data.name, data.open)
        }
    },

    findMarkerById: function(id) {
        var marker;

        this.LMmarkers.forEach(function(marker) {
            if (marker.id == id) return marker;
        });

        if (marker = this.findMarkerInStorage(id)) return marker;
    },

    findMarkerByName: function(name) {
        for (var i = 0; i < this.LMmarkers.length; i++) {
            if (this.LMmarkers[i].name === name) {
                return this.LMmarkers[i];
            }
        }
    },

    /*
     * Creates a single marker and returns it. If the iconClass is set
     * then the iconClass must be defined in the page
     */
    createMarker: function(id, lat, lng, iconClass, popupText, name, open, options) {
        //alert(id + "," + lat + "," + lng + "," + popupText + "," + title + "," + open);
        if(!options || typeof options != 'object') {
            options = {};
        }

        if (name) {
            options.title = name;
        }
        var latlng = new L.LatLng(lat, lng);
        var marker = L.marker(latlng, options);
        marker.id = id;
        marker.name = name;
        if (iconClass) {
            //alert(iconClass);
            marker.setIcon(eval(iconClass));
        }
        // Add the popup text and mark for open on init if needed
        if (popupText) {
            marker.bindPopup(popupText).openPopup();
            if (open) {
                marker.openPopup();
            }
        }

        localStorage.setItem('marker:' + id, JSON.stringify({
            id: id,
            lat: lat,
            lng: lng,
            iconClass: iconClass,
            popupText: popupText,
            name: name,
            open: open
        }));

        return marker;
    },

    /*
     * Adds a polyline from a json hash. arr is an array of arrays
     * where each sub array has length 2
     */
    addPolyline: function(arr, options) {

        var latlngs = new Array();
        for (var i = 0; i < arr.length; i++) {
            var pnt = arr[i];
            var ll = new L.LatLng(pnt[0], pnt[1]);
            latlngs.push(ll);
        }
        var pline = L.polyline(latlngs, options);

        // Add this polyline to the list of polylines
        this.LMpolylines.push(pline);

    },

    /*
     *
     */
    addCircle: function(lat, lng, radius, options) {
        var latlng = new L.LatLng(lat, lng);
        var circle = L.circle(latlng, radius, options);

        // Add this circle to the list of circles
        this.LMcircles.push(circle);
    },

    /*
     *
     */
    addMultipolygon: function(arr, options) {

        var multiPolygon = new Array();
        for (var i = 0; i < arr.length; i++) {
            var polygon = new Array();
            for (var j = 0; j < arr[i].length; j++){
                var ring = new Array();
                for(var k = 0; k < arr[i][j].length; k++){
                    var pnt = arr[i][j][k];
                    var ll = new L.LatLng(pnt[0], pnt[1]);
                    ring.push(ll);
                }
                polygon.push(ring);
            }
            multiPolygon.push(polygon);
        }
        var mpgon = L.multiPolygon(multiPolygon, options);

        // Add this multipolygon to the list of multipolygons
        this.LMmultipolygons.push(mpgon);
    },

    /*
  var Selection = * function for a marker. This function opens the marker popup,
  * closes any other popups and pans the map so the marker is centered
  */
    selectMarker: function(marker) {
        if (marker) {
            marker.openPopup();
            this.LMmap.panTo(marker.getLatLng());
        }
    },

    /**
     * Calculate the maximum geographic extent of the marker set
     * Needs at least 2 markers
     */
    calcMapBounds: function(marker_array) {
        if (marker_array == null || marker_array.length < 1 || marker_array[0] == null) {
            return nil;
        }
        var minLat = marker_array[0].getLatLng().lat;
        var minLng = marker_array[0].getLatLng().lng;
        var maxLat = marker_array[0].getLatLng().lat;
        var maxLng = marker_array[0].getLatLng().lng;

        if (marker_array.length > 1) {
            for (var i = 1; i < marker_array.length; i++) {
                minLat = minLat < marker_array[i].getLatLng().lat ? minLat : marker_array[i].getLatLng().lat;
                minLng = minLng < marker_array[i].getLatLng().lng ? minLng : marker_array[i].getLatLng().lng;
                maxLat = maxLat > marker_array[i].getLatLng().lat ? maxLat : marker_array[i].getLatLng().lat;
                maxLng = maxLng > marker_array[i].getLatLng().lng ? maxLng : marker_array[i].getLatLng().lng;
            }
        }

        return [[minLat, minLng], [maxLat, maxLng]];
    },

    calcMarkerBounds: function(marker) {
        if (marker == null)
            return nil;
        return [[marker.getLatLng().lat, marker.getLatLng().lng], [marker.getLatLng().lat, marker.getLatLng().lng]];
    },

    setMapToBounds: function(marker_array) {
        if (marker_array == null) {
            marker_array = this.LMmarkers;
        }
        if (marker_array.length > 0) {
            this.LMbounds = this.calcMapBounds(marker_array);
            this.LMmap.fitBounds(this.LMbounds);
        }
    },

    setMapToMarkerBounds: function(marker) {
        if (marker)
            this.LMmap.fitBounds(this.calcMarkerBounds(marker));
    },

    setMapBounds: function(minLat, minLon, maxLat, maxLon) {
        this.LMbounds = [
            [minLat, minLon],
            [maxLat, maxLon]
        ];
    },

    cacheMapBounds: function(minLat, minLon, maxLat, maxLon) {
        this.LMcacheBounds = [
            [minLat, minLon],
            [maxLat, maxLon]
        ];
    },

    closePopup: function() {
        if (this.LMcurrent_popup) {
            this.LMcurrent_popup._source.closePopup();
        }
    },

    invalidateMap: function() {
        //L.Util.requestAnimFrame(this.LMmap.invalidateSize, this.LMmap,!1, this.LMmap._container);
        this.LMmap.invalidateSize(false);
    },

    resetMap: function() {
        this.removeMarkers();
        this.removeCircles();
        this.removePolylines();
        //this.LMmap.remove();
    },

    // Wrapper for _resetView()
    resetMapView: function() {
        this.LMmap._resetView(this.LMmap.getCenter(), this.LMmap.getZoom(), true);
    },

    getFormattedAddrForMarker: function(addr) {
        return "<div class='well well-small'><div class='row'>" +
            "<div class='col-sm-3'><i class='fa fa-3x fa-building-o'></i></div>" +
            "<div class='col-sm-9'><div class='caption'><h4>" + addr + "</h4></div></div>" +
            "</div></div>";
    },

    refresh: function() {
        // this.LMmap.setView(bounds.getCenter(), map.getBoundsZoom(bounds), true)
        this.LMmap.invalidateSize(false);
        this.LMmap.fitBounds(this.LMbounds);
    },

    getMapControlTooltips: function() {
        var options = this._options ? this._options : {};
        return options.map_control_tooltips || {};
    },

    addZoomControl: function() {
        var tooltips = this.getMapControlTooltips();
        //explicitly add zoom control to display localized tooltip
        new L.Control.Zoom({ zoomInTitle: tooltips.zoom_in, zoomOutTitle: tooltips.zoom_out }).addTo(this.LMmap);
    },

    /*
     * customized map controls
     */
    registerCustomControl: function() {
        L.Control.CustomButton = L.Control.extend({
            _pressed: false,
            _button: null,
            options: {
                position: 'topleft',
                title: '',
                iconCls: '',
                toggleable: false,
                ignorePopupWhenClick: false, //if clicks at a marker with a popup, whether continue finishing control_click_event
                pressedCls: 'leaflet-button-pressed',
                depressedCursorType: '',
                pressedCursorType: 'crosshair',
                disabled: false,
                disabledCls: 'leaflet-disabled',
                clickCallback: function() {}
            },
            initialize: function (controlId, options) {
                this.id = controlId;
                L.Util.setOptions(this, options);
            },
            checkIfIgnorePopupWhenClick: function() {
                return this.options.ignorePopupWhenClick;
            },
            getToggleable: function() {
                return this.options.toggleable;
            },
            getDisabled: function() {
                return this._disabled === true || false;
            },
            setDisabled: function(disabled) {
                disabled = disabled === true || false;
                this._disabled = disabled;
                var button = this._button || {};
                if(disabled) {
                    L.DomUtil.addClass(button, this.options.disabledCls);
                } else {
                    L.DomUtil.removeClass(button, this.options.disabledCls);
                }
            },
            getPressed: function() {
                return this._pressed;
            },
            setPressed: function(pressed) {
                if(!this.getToggleable()) {
                    return;
                }
                this._pressed = pressed;
                var map = this._map;
                if(this._pressed) {
                    L.DomUtil.addClass(this._button, this.options.pressedCls);
                    if(map) {
                        //depress other controls
                        var customControls = map.customControls;
                        if(customControls instanceof Array) {
                            var currentIndex = customControls.indexOf(this);
                            customControls.forEach( function(ctrl) {
                                if(currentIndex != customControls.indexOf(ctrl)) {
                                    ctrl.setPressed(false);
                                }
                            });
                        }

                        L.DomUtil.get(map.getContainer().id).style.cursor = this.options.pressedCursorType || 'crosshair';
                    }
                } else {
                     L.DomUtil.removeClass(this._button, this.options.pressedCls);
                     if(map) {
                        L.DomUtil.get(map.getContainer().id).style.cursor = this.options.depressedCursorType || '';
                    }
                }
            },

            onAdd: function (map) {
                var container = L.DomUtil.create('div', 'leaflet-bar leaflet-control');

                this._button = L.DomUtil.create('a', 'leaflet-bar-part', container);
                L.DomUtil.create('i', this.options.iconCls, this._button);
                this._button.href = '#';
                this._button.title = this.options.title;

                L.DomEvent.on(this._button, 'click', this._click, this);

                this.setDisabled(this.options.disabled);

                //add current control into map
                if(!map.customControls) {
                    map.customControls = [];
                }
                map.customControls.push(this);

                return container;
            },

            _click: function (e) {
                L.DomEvent.stopPropagation(e);
                L.DomEvent.preventDefault(e);
                if(!this.getDisabled()) {
                    if(this.options.toggleable) {
                        this.setPressed(!this._pressed);
                    }
                    this.options.clickCallback();
                }
            }
        })
    },

    addCurrentLocationControl: function() {
        if (!("geolocation" in navigator)) { //if geolocation is not supported, then not display this control on map
            return;
        }

        if(!L.Control.CustomButton) {
            this.registerCustomControl();
        }

        var tooltips = this.getMapControlTooltips();
        var currentMap = this.LMmap;
        var currentLocataionControl = new L.Control.CustomButton(this.CURRENT_LOCATION, {
            title: tooltips.my_location,
            iconCls: 'fa fa-lg fa-location-arrow',
            clickCallback: function() {
                currentMap.locate({setView: true});
            }
        });

        currentLocataionControl.addTo(currentMap);
    },

    addStreetViewControl: function() {

        if(!L.Control.CustomButton) {
            this.registerCustomControl();
        }

        var tooltips = this.getMapControlTooltips();
        var currentMap = this.LMmap;
        var streetViewControl = new L.Control.CustomButton(this.STREET_VIEW, {
            title: tooltips.display_street_view,
            iconCls: 'fa fa-lg leaflet-street-view-icon',
            toggleable: true,
            ignorePopupWhenClick: true
        });

        streetViewControl.addTo(currentMap);
    },

    //oepn a new street view page
    openStreetView: function(latlng) {
        var options = this._options ? this._options : {};
        var streetViewUrl = options.street_view_url || '';
        var latlng = latlng || {};
        //redirect to street view page
        window.open(streetViewUrl + '?lat=' + latlng.lat + '&lng=' + latlng.lng, '_blank');
    },

    addLocationSelectControl: function() {

        if(!L.Control.CustomButton) {
            this.registerCustomControl();
        }

        var tooltips = this.getMapControlTooltips();
        var currentMap = this.LMmap;
        var locationSelectControl = new L.Control.CustomButton(this.LOCATION_SELECT, {
            title: tooltips.select_location_on_map,
            iconCls: 'fa fa-lg fa-map-marker',
            toggleable: true
        });

        locationSelectControl.addTo(currentMap);
    },

    getActiveCustomControl: function() {
        var currentMap = this.LMmap;
        var customControls =  currentMap.customControls;
        if(customControls instanceof Array) {
            for(var i=0, ctrlCount=customControls.length; i<ctrlCount; i++) {
                var ctrl = customControls[i];
                if(ctrl.getToggleable() && ctrl.getPressed()) {
                    return ctrl;
                }
            }
        }

        return null;
    },

    executeActiveCustomControl: function(latlng) {
        var currentMap = this.LMmap;
        var customControls =  currentMap.customControls;
        var activeControl = this.getActiveCustomControl();
        if(activeControl){
            switch(activeControl.id) {
                case this.STREET_VIEW:
                    this.openStreetView(latlng);
                    break;
                case this.LOCATION_SELECT:
                    currentMap.fire('placechange', {
                        latlng: latlng
                    });
                    break;
                case this.SIDEWALK_FEEDBACK:
                    currentMap.fire('newsidewalkfeedback', {
                        latlng: latlng
                    });
                    break;
                default:
                    break;
            }
        }
    },

    registerMapClickEvent: function() {
        var scope = this;
        var currentMap = scope.LMmap;
        var clickCounter = 0;
        currentMap.on('click', function(e){
            clickCounter ++;
            setTimeout(function(){ //Leaflet triggers click in doubleclick event, using a timeout to separate them
                if(clickCounter === 1) {
                    scope.executeActiveCustomControl(e.latlng);
                }
                clickCounter = 0;
            }, 200);
        });
    },

    registerPopupOpenEvent: function() {
        var scope = this;
        // install a popup listener
        scope.LMmap.on('popupopen', function(e) {

            //alert('popup opened');
            scope.LMcurrent_popup = e.popup;

            var activeControl = scope.getActiveCustomControl();
            if(activeControl && activeControl.checkIfIgnorePopupWhenClick()) {
                scope.executeActiveCustomControl(e.popup.getLatLng());
            }
        });
    }


}