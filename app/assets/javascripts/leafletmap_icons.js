/*
 * Icons based on Google Map icons for Leaflet
 */

var baseIcon = L.Icon.extend({
        options: {
            shadowUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/msmarker.shadow.png',
            iconSize:     [32, 32],
            //shadowSize:   [32, 32],
            iconAnchor:   [16, 32],
            shadowAnchor: [16, 32],
            popupAnchor:  [0, -24]
        }
    });

var redIcon = new baseIcon({iconUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png'});
var blueIcon = new baseIcon({iconUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png'});
var purpleIcon = new baseIcon({iconUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/purple-dot.png'});
var yellowIcon = new baseIcon({iconUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/yellow-dot.png'});
var greenIcon = new baseIcon({iconUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png'});
var orangeIcon = new baseIcon({iconUrl: 'http://maps.google.com/intl/en_us/mapfiles/ms/micons/orange-dot.png'});
