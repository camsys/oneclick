function create_or_update_typeahead_marker(item, key, iconStyle) {
    marker = create_or_update_marker(key, item.lat, item.lon, item.name, item.desc, iconStyle);
    setMapToBounds();
    selectMarker(marker);
};

function restore_marker_from_local_storage(key) {
    var marker = CsMaps.lmap.findMarkerById(key);

    if (marker) {
        CsMaps.lmap.addMarkerToMap(marker, true);
    }
}

function create_or_update_marker(key, lat, lon, name, desc, iconStyle) {
    // See if we can find this existing marker

    marker = CsMaps.lmap.findMarkerById(key);
    if (marker) {
        CsMaps.lmap.removeMarkerFromMap(marker);
    }
    var marker = CsMaps.lmap.createMarker(key, lat, lon, iconStyle, desc, name, true);
    CsMaps.lmap.addMarkerToMap(marker, true);
    return marker;
};

// Add a list of candidate markers to the map
var alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'Z', 'Y', 'Z'];

function add_candidate_marker(index, lat, lon, addr, desc, type) {
    var iconStyle;
    var key_template;
    if (type == 'from') {
        iconStyle = 'startCandidate';
        key_template = 'start_candidate';
    } else if (type == 'to') {
        iconStyle = 'stopCandidate';
        key_template = 'stop_candidate';
    } else {
        iconStyle = 'placeCandidate';
        key_template = 'place_candidate';
    }
    var icon = iconStyle + alphabet[index];
    var key = key_template + index;
    var marker = cCsMaps.lmap.createMarker(key, lat, lon, icon, desc, addr, false);
    CsMaps.lmap.addMarkerToMap(marker, true);
}

// Add the candidate locations to the map
function create_candidate_markers(from_to_type) {
    $('.address-select').each(function() {
        var t = $(this);
        var id = t.data('id');
        var index = t.data('index');
        var type = t.data('type');
        var addr = t.data('addr');
        var desc = t.data('desc');
        var latlon = eval(t.data('latlon'));
        if (type === from_to_type) {
            add_candidate_marker(index, latlon[0], latlon[1], addr, desc, type);
        }
    });
};

// Selects the first matching from or to candidate in the list of alternate
// addresses.
function select_first_candidate_address(from_to) {
    $('.address-select').each(function(idx) {
        var candidate = $(this);
        var type = candidate.data('type');
        if (type == from_to) {
            select_candidate_address(candidate);
            return;
        }
    });
};

// Select a candidate address
function select_candidate_address(candidate) {
    var id = candidate.data('id');
    var index = candidate.data('index');
    var type = candidate.data('type');
    var addr = candidate.data('addr');
    var desc = candidate.data('desc');
    var latlon = eval(candidate.data('latlon'));

    var update_target;
    var hidden_val;
    var hidden_type;
    var panel;
    var key = 'start';
    var iconStyle = 'startIcon';

    if (type == 'from') {
        update_target = $('#trip_proxy_from_place');
        hidden_val = $('#from_place_selected');
        hidden_type = $('#from_place_selected_type');
        panel = $('#from_place_candidates');
    } else {
        update_target = $('#trip_proxy_to_place');
        hidden_val = $('#to_place_selected');
        hidden_type = $('#to_place_selected_type');
        panel = $('#to_place_candidates');
        key = 'stop';
        iconStyle = 'stopIcon';
    }

    hidden_val.val(index);
    hidden_type.val(4);
    panel.hide();
    update_target.val(addr);

    // Remove any candidate markers from the map
    CsMaps.lmap.removeMatchingMarkers(key);
    // replace the markers with the end point marker
    marker = create_or_update_marker(key, latlon[0], latlon[1], addr, desc, iconStyle);
    CsMaps.lmap.setMapToBounds();
    CsMaps.lmap.selectMarker(marker);
};