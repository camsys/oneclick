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

var baseRouteIcon = L.Icon.extend({
        options: {
            shadowUrl: 'http://maps.google.com/mapfiles/shadow50.png',
            iconSize:     [24, 34],
            //shadowSize:   [32, 32],
            iconAnchor:   [12, 34],
            shadowAnchor: [12, 34],
            popupAnchor:  [0, -24]
        }
    });

var startIcon = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/dd-start.png'});
var stopIcon = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/dd-end.png'});

var startCandidateA = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenA.png'});
var startCandidateB = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenB.png'});
var startCandidateC = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenC.png'});
var startCandidateD = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenD.png'});
var startCandidateE = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenE.png'});
var startCandidateF = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenF.png'});
var startCandidateG = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenG.png'});
var startCandidateH = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenH.png'});
var startCandidateI = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenI.png'});
var startCandidateJ = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenJ.png'});
var startCandidateK = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenK.png'});
var startCandidateL = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenL.png'});
var startCandidateM = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenK.png'});
var startCandidateN = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenN.png'});
var startCandidateO = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenO.png'});
var startCandidateP = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenP.png'});
var startCandidateQ = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenQ.png'});
var startCandidateR = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenR.png'});
var startCandidateS = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenS.png'});
var startCandidateT = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/marker_greenT.png'});

var stopCandidateA = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerA.png'});
var stopCandidateB = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerB.png'});
var stopCandidateC = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerC.png'});
var stopCandidateD = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerD.png'});
var stopCandidateE = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerE.png'});
var stopCandidateF = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerF.png'});
var stopCandidateG = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerG.png'});
var stopCandidateH = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerH.png'});
var stopCandidateI = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerI.png'});
var stopCandidateJ = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerJ.png'});
var stopCandidateK = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerK.png'});
var stopCandidateL = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerL.png'});
var stopCandidateM = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerK.png'});
var stopCandidateN = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerN.png'});
var stopCandidateO = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerO.png'});
var stopCandidateP = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerP.png'});
var stopCandidateQ = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerQ.png'});
var stopCandidateR = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerR.png'});
var stopCandidateS = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerS.png'});
var stopCandidateT = new baseRouteIcon({iconUrl: 'http://maps.google.com/mapfiles/markerT.png'});

