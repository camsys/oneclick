// Leaflet map rendering functions


/*
 * Add a set of markers to the map. Markers are defined as an array of json hashes. Each
 * JSON hash has values latitude, longitude, iconClass, popupText, open
 */
var LMmarkers = new Array();
var LMcircles = new Array();
var LMpolylines = new Array();
var LMmap;
var LMbounds;
var LMcacheBounds;
var LMcurrent_popup;

var OPENSTREETMAP_URL = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
var OPENSTREETMAP_ATTRIB = 'Map data © OpenStreetMap contributors';

var CLOUDMADE_URL = 'http://{s}.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/{styleId}/256/{z}/{x}/{y}.png';
var CLOUDMADE_ATTRIB = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
    '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
    'Imagery © <a href="http://cloudmade.com">CloudMade</a>';

/*
 * Must be called first. Pass the Id of the div containing the map and any options
 * that should be passed to the map constructor
 */
function init(mapId, options) {
    LMmap = L.map(mapId);
    //alert(options.tile_provider);
    //alert(options.min_zoom);
    //alert(options.max_zoom);
    if (options.tile_provider == 'OPENSTREETMAP') {
        var mapUrl = OPENSTREETMAP_URL;
        var mapAttrib = OPENSTREETMAP_ATTRIB;
        L.tileLayer(mapUrl, {
            minZoom: options.min_zoom,
            maxZoom: options.max_zoom,
            attribution: mapAttrib
        }).addTo(LMmap);
    } else if (options.tile_provider == 'GOOGLEMAP') {
        var googleLayer = new L.Google('ROADMAP');
        LMmap.addLayer(googleLayer);
    } else {
        var mapUrl = CLOUDMADE_URL;
        var mapAttrib = CLOUDMADE_ATTRIB;
        L.tileLayer(mapUrl, {
            minZoom: options.min_zoom,
            maxZoom: options.max_zoom,
            attribution: mapAttrib,
            styleId: options.tile_style_id
        }).addTo(LMmap);
    }
    // install a popup listener
    LMmap.on('popupopen', function(event) {
        //alert('popup opened');
        LMcurrent_popup = event.popup;
    });
};

/**
 * Centers the map on a specified marker without changing the zoom level
 */
function centerOnMarker(markerId) {
    var marker = findMarkerById(markerId);
    if (marker) {
        var latlng = marker.getLatLng();
        panTo(latlng.lat, latlng.lng);
    }
};
/*
 * Pans the map to a gven coordinate without changing the zoom level
 */
function panTo(lat, lng) {
    var latlng = new L.LatLng(lat, lng);
    LMmap.panTo(latlng);
};
/*
 * Called last after the map has been configured.
 */
function showMap() {
    // Add the markers to the map
    for (var i = 0; i < LMmarkers.length; i++) {
        LMmap.addLayer(LMmarkers[i]);
    }
    // Add the circles to the map
    for (var i = 0; i < LMcircles.length; i++) {
        LMmap.addLayer(LMcircles[i]);
    }
    // Add the polylines to the map
    for (var i = 0; i < LMpolylines.length; i++) {
        LMmap.addLayer(LMpolylines[i]);
    }
    var mapBounds;
    if (LMmarkers.length > 0) {
        mapBounds = calcMapBounds(LMmarkers);
    } else {
        mapBounds = LMbounds;
    }
    LMmap.fitBounds(mapBounds);
};

function showMapOriginal() {
    mapBounds = LMcacheBounds;
    LMmap.fitBounds(mapBounds);
}

/*
 * Replaces the markers on the map with a new set
 */
function replaceMarkers(arr, updateMap) {
    //alert('Replacing Markers');
    removeMarkers();
    addMarkers(arr);
    if (updateMap) {
        //alert('Updating map');
        showMap();
    } else {
        // Add the markers to the map
        for (var i = 0; i < LMmarkers.length; i++) {
            LMmap.addLayer(LMmarkers[i]);
        }
    }
};
/*
 * Removes the markers from the map and re-draws them from
 * the markers array
 */
function refreshMarkers() {
    for (var i = 0; i < LMmarkers.length; i++) {
        LMmap.removeLayer(LMmarkers[i]);
    }
    // Add the markers to the map
    for (var i = 0; i < LMmarkers.length; i++) {
        LMmap.addLayer(LMmarkers[i]);
    }
};
/*
 * Replaces the circles on the map with a new set
 */
function replaceCircles(arr, updateMap) {
    //alert('Replacing Circles');
    removeCircles();
    addCircles(arr);
    if (updateMap) {
        //alert('Updating map');
        showMap();
    } else {
        for (var i = 0; i < LMcircles.length; i++) {
            LMmap.addLayer(LMcircles[i]);
        }
    }
};
/*
 * Replaces the polylines on the map with a new set
 */
function replacePolylines(arr, updateMap) {
    //alert('Replacing Polylines');
    removePolylines();
    addPolylines(arr);
    if (updateMap) {
        //alert('Updating map');
        showMap();
    } else {
        for (var i = 0; i < LMpolylines.length; i++) {
            LMmap.addLayer(LMpolylines[i]);
        }
    }
};

function removeMarkersKeepCache() {
    for (var i = 0; i < LMmarkers.length; i++) {
        LMmap.removeLayer(LMmarkers[i]);
    }
}

/*
 *
 */
function removeMarkers() {
    // Loop through the markers and remove them from the map
    //alert('Removing markers from map');
    for (var i = 0; i < LMmarkers.length; i++) {
        //alert('Removing Marker ' + LMmarkers[i].id);
        LMmap.removeLayer(LMmarkers[i]);
    }
    LMmarkers = new Array();
};
/*
 *
 */
function removeCircles() {
    // Loop through the circles and remove them from the map
    for (var i = 0; i < LMcircles.length; i++) {
        LMmap.removeLayer(LMcircles[i]);
    }
    LMcircles = new Array();
};
/*
 *
 */
function removePolylines() {
    // Loop through the polylines and remove them from the map
    for (var i = 0; i < LMpolylines.length; i++) {
        LMmap.removeLayer(LMpolylines[i]);
    }
    LMpolylines = new Array();
};
/*
 * Processes an array of json objects containing marker definitions and adds them
 * to the array of markers
 */
function addMarkers(arr) {
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
        marker = createMarker(id, lat, lng, iconClass, popupText, title, open);

        // Add this marker to the list of markers
        LMmarkers.push(marker);
    }
};
// Adds a marker to the map and optionally puts it in the cache
function addMarkerToMap(marker, cache) {
    if (cache) {
        // Add this marker to the list of markers
        LMmarkers.push(marker);
    }
    LMmap.addLayer(marker);
};
// Removes a marker from the map and removes it from the cache
// if it is stored there
function removeMarkerFromMap(marker) {
    markers = new Array();
    for (var i = 0; i < LMmarkers.length; i++) {
        if (marker == LMmarkers[i]) {
            continue;
        } else {
            markers.push(LMmarkers[i]);
        }
    }
    LMmarkers = markers;
    LMmap.removeLayer(marker);
};
// Removes markers with an id matching the input string
function removeMatchingMarkers(match) {
    markers = new Array();
    for (var i = 0; i < LMmarkers.length; i++) {
        var marker = LMmarkers[i];
        var id = marker.id;
        if (id != null && id.indexOf(match) != -1) {
            LMmap.removeLayer(marker);
            continue;
        } else {
            markers.push(marker);
        }
    }
    LMmarkers = markers;
}
/*
 *
 */
function addCircles(arr) {
    for (var i = 0; i < arr.length; i++) {
        var obj = arr[i];
        var lat = obj.lat;
        var lng = obj.lng;
        var radius = obj.radius;
        var options = {};
        if (obj.options) {
            options = obj.options;
        }
        addCircle(lat, lng, radius, options);
    }
};
/*
 *
 */
function addPolylines(arr) {
    for (var i = 0; i < arr.length; i++) {
        var obj = arr[i];
        var id = obj.id;
        var geom = obj.geom;
        var options = {};
        if (obj.options) {
            options = obj.options;
        }
        addPolyline(geom, options);
    }
};

function selectMarkerById(id) {
    marker = findMarkerById(id);
    if (marker) {
        selectMarker(marker);
    }
};

function selectMarkerByName(name) {
    marker = findMarkerByName(name);
    if (marker) {
        selectMarker(marker);
    }
};

function findMarkerInStorage(id) {
    var json = localStorage.getItem('marker:' + id);

    if (json) {
        var data = JSON.parse(json);
        return createMarker(data.id, data.lat, data.lng, data.iconClass, data.popupText, data.name, data.open)
    }
}

function findMarkerById(id) {
    var marker;

    LMmarkers.forEach(function(marker) {
        if (marker.id == id) return marker;
    });

    if (marker = findMarkerInStorage(id)) return marker;
};

function findMarkerByName(name) {
    for (var i = 0; i < LMmarkers.length; i++) {
        if (LMmarkers[i].name === name) {
            return LMmarkers[i];
        }
    }
};

/*
 * Creates a single marker and returns it. If the iconClass is set
 * then the iconClass must be defined in the page
 */
function createMarker(id, lat, lng, iconClass, popupText, name, open) {
    //alert(id + "," + lat + "," + lng + "," + popupText + "," + title + "," + open);

    var options = {};
    if (name) {
        options = {
            "title": name
        };
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
};
/*
 * Adds a polyline from a json hash. arr is an array of arrays
 * where each sub array has length 2
 */
function addPolyline(arr, options) {

    var latlngs = new Array();
    for (var i = 0; i < arr.length; i++) {
        var pnt = arr[i];
        var ll = new L.LatLng(pnt[0], pnt[1]);
        latlngs.push(ll);
    }
    var pline = L.polyline(latlngs, options);

    // Add this polyline to the list of polylines
    LMpolylines.push(pline);

}
/*
 *
 */
function addCircle(lat, lng, radius, options) {
    var latlng = new L.LatLng(lat, lng);
    var circle = L.circle(latlng, radius, options);

    // Add this circle to the list of circles
    LMcircles.push(circle);
};

/*
 * Selection function for a marker. This function opens the marker popup,
 * closes any other popups and pans the map so the marker is centered
 */
function selectMarker(marker) {
    if (marker) {
        marker.openPopup();
        LMmap.panTo(marker.getLatLng());
    }
};
/**
 * Calculate the maximum geographic extent of the marker set
 * Needs at least 2 markers
 */
function calcMapBounds(marker_array) {
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
};

function calcMarkerBounds(marker) {
    if (marker == null)
        return nil;
    return [[marker.getLatLng().lat, marker.getLatLng().lng], [marker.getLatLng().lat, marker.getLatLng().lng]];
}

function setMapToBounds(marker_array) {
    if (marker_array == null) {
        marker_array = LMmarkers;
    }
    if (marker_array.length > 0) {
        LMbounds = calcMapBounds(marker_array);
        LMmap.fitBounds(LMbounds);
    }
};

function setMapToMarkerBounds(marker) {
    if (marker)
        LMmap.fitBounds(calcMarkerBounds(marker));
}

function setMapBounds(minLat, minLon, maxLat, maxLon) {
    LMbounds = [
        [minLat, minLon],
        [maxLat, maxLon]
    ];
};

function cacheMapBounds(minLat, minLon, maxLat, maxLon) {
    LMcacheBounds = [
        [minLat, minLon],
        [maxLat, maxLon]
    ];
}

function closePopup() {
    if (LMcurrent_popup) {
        LMcurrent_popup._source.closePopup();
    }
};

function invalidateMap() {
    //L.Util.requestAnimFrame(LMmap.invalidateSize, LMmap,!1, LMmap._container);
    LMmap.invalidateSize(false);
};

function resetMap() {
    removeMarkers();
    removeCircles();
    removePolylines();
    //LMmap.remove();
};

// Wrapper for _resetView()
function resetMapView() {
    LMmap._resetView(LMmap.getCenter(), LMmap.getZoom(), true);
}

function getFormattedAddrForMarker(addr) {
    return "<div class='well well-small'><div class='row'>" +
        "<div class='span3'><i class='fa fa-3x fa-building-o'></i></div>" +
        "<div class='span9'><div class='caption'><h4>" + addr + "</h4></div></div>" +
        "</div></div>";
}