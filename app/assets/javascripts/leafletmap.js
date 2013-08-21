// Leaflet map rendering functions


/*
 * Add a set of markers to the map. Markers are defined as an array of json hashes. Each
 * JSON hash has values latitude, longitude, iconClass, popupText, open
 */
var LMmarkers = new Array();
var LMcircles = new Array();
var LMmap;

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
init = function(mapId, options) {
	LMmap = L.map(mapId);
	//alert(options.tile_provider);
	//alert(options.min_zoom);
	//alert(options.max_zoom);
	if (options.tile_provider == 'OPENSTREETMAP') {
		var mapUrl = OPENSTREETMAP_URL;
		var mapAttrib = OPENSTREETMAP_ATTRIB;
		L.tileLayer(mapUrl, {minZoom: options.min_zoom, maxZoom: options.max_zoom, attribution: mapAttrib}).addTo(LMmap);		
	} else if (options.tile_provider == 'GOOGLEMAP') {
		var googleLayer = new L.Google('ROADMAP');
      	LMmap.addLayer(googleLayer);
	} else {
		var mapUrl = CLOUDMADE_URL;
		var mapAttrib = CLOUDMADE_ATTRIB;		
		L.tileLayer(mapUrl, {minZoom: options.min_zoom, maxZoom: options.max_zoom, attribution: mapAttrib, styleId: options.tile_style_id}).addTo(LMmap);
	}	
};
/**
 * Centers the map on a specified marker without changing the zoom level
 */
centerOnMarker = function(markerId) {
	var marker = findMarkerById(markerId);
	if (marker) {
		var latlng = marker.getLatLng();
		panTo(latlng.lat, latlng.lng);
	}
};
/*
 * Pans the map to a gven coordinate without changing the zoom level
 */
panTo = function(lat, lng) {
	var latlng = new L.LatLng(lat, lng); 
	LMmap.panTo(latlng);
};
/*
 * Called last after the map has been configured.
 */
showMap = function() {
	// Add the markers to the map
	for (var i=0;i<LMmarkers.length;i++) {
		LMmap.addLayer(LMmarkers[i]);
	}
	// Add the circles to the map
	for (var i=0;i<LMcircles.length;i++) {
		LMmap.addLayer(LMcircles[i]);
	}
	var mapBounds = calcMapBounds();
	//alert(mapBounds);
	LMmap.fitBounds(mapBounds);
};
/*
 * Replaces the markers on the map with a new set
 */
replaceMarkers = function(data, updateMap) {
	//alert('Replacing Markers');
	removeMarkers();
	addMarkers(data);
	if (updateMap) {
		//alert('Updating map');
		showMap();
	} else {
		// Add the markers to the map
		for (var i=0;i<LMmarkers.length;i++) {
			LMmap.addLayer(LMmarkers[i]);
		}
	}
};
/*
 * Removes the markers from the map and re-draws them from
 * the markers array
 */
refreshMarkers = function() {
	for(var i=0;i<LMmarkers.length;i++){
		LMmap.removeLayer(LMmarkers[i]);
	}	
	// Add the markers to the map
	for (var i=0;i<LMmarkers.length;i++) {
		LMmap.addLayer(LMmarkers[i]);
	}
};
/*
 * Replaces the circles on the map with a new set
 */
replaceCircles = function(data, updateMap) {
	//alert('Replacing Circles');
	removeCircles();
	addCircles(data);
	if (updateMap) {
		//alert('Updating map');
		showMap();
	} else {
		for (var i=0;i<LMcircles.length;i++) {
		LMmap.addLayer(LMcircles[i]);
		}
	}
};
/*
 * 
 */
removeMarkers = function() {
	// Loop through the markers and remove them from the map
	//alert('Removing markers from map');
	for(var i=0;i<LMmarkers.length;i++){
		//alert('Removing Marker ' + LMmarkers[i].id);
		LMmap.removeLayer(LMmarkers[i]);
	}	
	LMmarkers = new Array();
};
/*
 * 
 */
removeCircles = function() {
	// Loop through the markers and remove them from the map
	for(var i=0;i<LMcircles.length;i++){
		LMmap.removeLayer(LMcircles[i]);
	}		
	LMcircles = new Array();
};
/*
 * Processes an array of json objects containing marker definitions and adds them
 * to the array of markers
 */
addMarkers = function(data) {
	//alert('Adding ' + data.length + ' markers');
	
	for(var i=0;i<data.length;i++){
        var obj = data[i];
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
addMarkerToMap = function(marker) {
	LMmap.addLayer(marker);	
};
removeMarkerFromMap = function(marker) {
	LMmap.removeLayer(marker);	
};
/*
 * 
 */
addCircles = function(data) {
	for(var i=0;i<data.length;i++) {
        var obj = data[i];
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

selectMarkerById = function(id) {
	marker = findMarkerById(id);
	//alert(marker);
	selectMarker(marker);
};

findMarkerById = function(id) {
	for (var i=0;i<LMmarkers.length;i++) {
		if (LMmarkers[i].id == id) {
			return LMmarkers[i];
		}
	}
};

/*
 * Creates a single marker and returns it. If the iconClass is set 
 * then the iconClass must be defined in the page
 */
createMarker = function(id, lat, lng, iconClass, popupText, title, open) {
	var options = {};
	if (title) {
		options = {
			"title" : title
		};
	}
	var latlng = new L.LatLng(lat, lng); 
	var marker = L.marker(latlng, options);
	marker.id = id;
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

	return marker;
};
/*
 * 
 */
addCircle = function(lat, lng, radius, options) {
	var latlng = new L.LatLng(lat, lng); 
	var circle = L.circle(latlng, radius, options);

	// Add this circle to the list of circles
	LMcircles.push(circle);
};

/*
 * Selection function for a marker. This function opens the marker popup,
 * closes any other popups and pans the map so the marker is centered
 */
selectMarker = function(marker) {
	if (marker) {
		marker.openPopup();
		LMmap.panTo(marker.getLatLng());	
	}
};
/**
 * Calculate the maximum geographic extent of the marker set
 * Needs at least 2 markers
 */
calcMapBounds = function() {
	var minLat = LMmarkers[0].getLatLng().lat;
	var minLng = LMmarkers[0].getLatLng().lng;
	var maxLat = LMmarkers[0].getLatLng().lat;
	var maxLng = LMmarkers[0].getLatLng().lng;
	
	if (LMmarkers.length > 1) {
		for(var i=1; i<LMmarkers.length;i++) {
			minLat = minLat < LMmarkers[i].getLatLng().lat ? minLat : LMmarkers[i].getLatLng().lat;
			minLng = minLng < LMmarkers[i].getLatLng().lng ? minLng : LMmarkers[i].getLatLng().lng;
			maxLat = maxLat > LMmarkers[i].getLatLng().lat ? maxLat : LMmarkers[i].getLatLng().lat;
			maxLng = maxLng > LMmarkers[i].getLatLng().lng ? maxLng : LMmarkers[i].getLatLng().lng;
		}		
	}
	
	return [[minLat, minLng], [maxLat, maxLng]];
};

