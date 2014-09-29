/*
 * global function to implement a delay timer
 * only execute callback when the final event is detected
 */
var waitForFinalEvent = (function() {
    var timers = {};
    return function(callback, ms, uniqueId) {
        if (!uniqueId) {
            uniqueId = "Don't call this twice without a uniqueId";
        }
        if (timers[uniqueId]) {
            clearTimeout(timers[uniqueId]);
        }
        timers[uniqueId] = setTimeout(callback, ms);
    };
})();

/*
 * show loading mask
 */
(function($) {
    $.fn.overlayMask = function(action) {
        var mask = this.find('.overlay-mask');
        var maskSpinner = this.find('.overlay-mask-spinner');

        // Create the required mask

        if (!mask.length) {
            this.css({
                position: 'relative'
            });
            this.append('<i class="fa fa-spinner fa-spin overlay-mask-spinner"></i><div class="overlay-mask"></div>');
        }

        // Act based on params

        if (!action || action === 'show') {
            mask.show();
            maskSpinner.show();
        } else if (action === 'hide') {
            mask.hide();
            maskSpinner.hide();
        } else if (action === 'remove') {
            mask.remove();
            maskSpinner.remove();
        }

        return this;
    };
})(jQuery)
/*
 * MultiODGridPageRenderer class: a self-contained class to render grid page for multi origin-destination trip planning
 * @param {Object}: tripResponse
 * @param {Object}: localeDictFinder, a hash of localized texts
 * @method processTripResponse: public method to process trip results
 */
function MultiODGridPageRenderer(tripResponse, localeDictFinder) {
    localeDictFinder = isValidObject(localeDictFinder) ? localeDictFinder : {};
    var _tripResponse = tripResponse; //trip json

    var _isInitial = true; //a flag whether this is initial trip response
    var _totalModeRequestCounter = 0; //a counter that keeps track of all itinerary requests for each mode_trip_part;
    // when _totalModeRequestCounter > 0, then show loading mask; when 0, hide;

    //page document width
    //be used to detect width change -> resize charts
    var documentWidth = $(document.body).width();

    var baseContainerId = 'gridBaseContainer'; //id of review page base container
    /**
     * Process trip results response from service
     */
    function processTripResponse() {
        if (!verifyTripJsonValid()) {
            return;
        }

        var tripParts = _tripResponse.trip_parts;
        //process each trip
        for (var i = 0, tripCount = tripParts.length; i < tripCount; i++) {
            tripParts[i] = processTripTimeRange(tripParts[i]);
            tripParts[i] = formatTripData(tripParts[i]);
        }

        //if modes[] available then fetch itineraries of each trip_part_mode
        if (_isInitial) {
            _isInitial = false;

            //dispatch requests to get itineraries
            _tripResponse.modes.forEach(function(modeObj) {
                if (isValidObject(modeObj) && modeObj.urls instanceof Array) {
                    modeObj.urls.forEach(function(urlObj) {
                        if (isValidObject(urlObj)) {
                            asyncRequestItinerariesForMode(urlObj.url, urlObj.trip_part_id, modeObj.mode);
                        }
                    });
                }
            });

            if (_totalModeRequestCounter === 0) {
                executeWhenDataReady();
            }
        }
    }

    function verifyTripJsonValid() {

        //check if response is object
        if (typeof _tripResponse != 'object' || _tripResponse === null) {
            return false;
        }

        //check response status
        if (_tripResponse.status === 0) {
            //console.log('something went wrong');
            return false;
        }

        var tripParts = _tripResponse.trip_parts;
        //check if trip_parts is Array
        if (!tripParts instanceof Array) {
            return false;
        }

        return true;
    }

    /*
     * ajax request to get list of itineraries
     * @param {string} url
     * @param {number} tripPartId
     * @param {string} mode
     */
    function asyncRequestItinerariesForMode(url, tripPartId, mode) {
        _totalModeRequestCounter++;
        checkLoadingMask();

        $.ajax({
            url: url
        })
            .done(function(response) {
                //update _tripResponse
                if (isValidObject(response) && response.itineraries instanceof Array) {
                    updateTripPartItineraries(tripPartId, response.itineraries);
                    //redraw
                    processTripResponse();
                }
                _totalModeRequestCounter--;
                checkLoadingMask();
            })
            .fail(function(response) {
                _totalModeRequestCounter--;
                checkLoadingMask();
                //console.log(response);
            });
    }

    /**
     * execute a list of things when data is fianlly ready, i.e., async loading is finished
     */
    function executeWhenDataReady() {
        var tripParts = _tripResponse.trip_parts;
        if(tripParts.length > 0) {
            var outboundPart = _tripResponse.trip_parts[0];
            var outboundSummary = '<b>' + localeDictFinder["outbound"] + '</b><br>' +
                getTripPartSummary(outboundPart);
            var returnSummary = '';
            if(tripParts.length > 1) {
                var returnPart = _tripResponse.trip_parts[tripParts.length - 1];
                returnSummary = '<br><b>' + localeDictFinder["return"] + '</b><br>' +
                    getTripPartSummary(returnPart);
            }

            var tdSelector =  '#' + baseContainerId + ' table td[data-trip-id=' + _tripResponse.id + '] .trip-summary';
            $(tdSelector).html(outboundSummary + returnSummary);
        }
    }

    function getTripPartSummary(trip) {
        var summary = '';

        if (!isValidObject(trip)) {
            return '';
        }
        var tripPlans = trip.itineraries;

        var filterValues = getTripPartFilterValues(trip);
        summary = '<span class="grid-summary-item">' + tripPlans.length + ' ' + (localeDictFinder["routes"] || '').toLowerCase() + '</span>';

        if(filterValues.isAvailable) {
            var minDuration = filterValues.duration[0];
            var maxDuration = filterValues.duration[1];
            if(maxDuration > minDuration) {
                summary += '<br><span class="grid-summary-item">' +  getRoundMinValue(minDuration) + ' - ' + getRoundMaxValue(maxDuration) + ' ' + localeDictFinder["minutes"] + '</span>';
            } else {
                summary += '<br><span class="grid-summary-item">' +  minDuration.toFixed(2) + ' ' + localeDictFinder["minutes"] + '</span>';
            }

            var minCost = filterValues.cost[0];
            var maxCost = filterValues.cost[1];
            if(maxCost > minCost) {
                summary += '<br><span class="grid-summary-item">$' +  getRoundMinValue(minCost) + ' - $' + getRoundMaxValue(maxCost) + '</span>';
            } else {
                summary += '<br><span class="grid-summary-item">$' +  minCost.toFixed(2) + '</span>';
            }

        }

        return summary;
    }

    function checkLoadingMask() {
        var tdSelector = '#' + baseContainerId + ' table td[data-trip-id=' + _tripResponse.id + ']';
        if (_totalModeRequestCounter > 0) {
            //show loading mask
            $(tdSelector).overlayMask();
        } else {
            //hide loading mask
            $(tdSelector).overlayMask('remove');

            executeWhenDataReady();

        }
    }

    function findTripPartById(tripPartId) {
        var tripPartData = null;

        var tripParts = _tripResponse.trip_parts;
        //process each trip
        for (var i = 0, tripCount = tripParts.length; i < tripCount; i++) {
            if (tripParts[i].id === tripPartId) {
                tripPartData = tripParts[i];
                break;
            }
        }

        return tripPartData;
    }

    /*
     * append new incoming itineraries
     */
    function updateTripPartItineraries(tripPartId, itineraries) {
        if (!verifyTripJsonValid()) {
            return;
        }

        var tripParts = _tripResponse.trip_parts;
        //process each trip
        for (var i = 0, tripCount = tripParts.length; i < tripCount; i++) {
            if (tripParts[i].id === tripPartId) {
                tripParts[i].itineraries = tripParts[i].itineraries.concat(itineraries);
                break;
            }
        }
    }

    /*
     * trip -> itineraries -> legs
     * iterate legs to check if itinerary time range covers all known legs' time ranges
     * iterate itineraries to check if trip time range covers all known itineraries' time ranges
     */
    function processTripTimeRange(trip) {
        if (typeof trip != 'object' || trip === null) {
            return null;
        }

        if (!trip.itineraries instanceof Array) {
            return trip;
        }

        var rawTripStartTime = parseDate(trip.start_time); //original start time selected by user
        var rawTripEndTime = parseDate(trip.end_time); //original end time selected by user
        var is_depart_at = trip.is_depart_at;
        var isStartTimeInvalid = isNaN(rawTripStartTime);
        var isEndTimeInvalid = isNaN(rawTripEndTime);

        var tripStartTime = parseDate(trip.start_time);
        var tripEndTime = parseDate(trip.end_time);


        for (var i = 0, planCount = trip.itineraries.length; i < planCount; i++) {
            var plan = trip.itineraries[i];

            var is_valid = true; //if plan time range fits trip time range, then valid;
            var planStartTime = parseDate(plan.start_time);
            var planEndTime = parseDate(plan.end_time);
            if (plan.legs instanceof Array) {
                plan.legs.forEach(function(leg) {
                    var legStartTime = parseDate(leg.start_time);
                    var legEndTime = parseDate(leg.end_time);
                    if (!isNaN(planStartTime)) {
                        if (!isNaN(legStartTime)) {
                            if (legStartTime < planStartTime) {
                                planStartTime = legStartTime;
                            }
                        }
                        if (!isNaN(legEndTime)) {
                            if (legEndTime < planStartTime) {
                                planStartTime = legEndTime;
                            }
                        }
                    }

                    if (!isNaN(planEndTime)) {
                        if (!isNaN(legStartTime)) {
                            if (legStartTime > planEndTime) {
                                planEndTime = legStartTime;
                            }
                        }
                        if (!isNaN(legEndTime)) {
                            if (legEndTime > planEndTime) {
                                planEndTime = legEndTime;
                            }
                        }
                    }
                });
            }

            if (!isNaN(planStartTime)) {
                plan.start_time = planStartTime.toISOString();
                if (is_depart_at && !isStartTimeInvalid && planStartTime < rawTripStartTime) {
                    is_valid = false;
                }
            }
            if (!isNaN(planEndTime)) {
                plan.end_time = planEndTime.toISOString();
                if (!is_depart_at && !isEndTimeInvalid && planEndTime > rawTripEndTime) {
                    is_valid = false;
                }
            }

            //if not valid, then remove this itinerary
            if (!is_valid) {
                trip.itineraries.splice(i, 1);
                i--;
                planCount--;
                continue;
            }

            if (!isNaN(planStartTime)) {
                if (isNaN(tripStartTime) || planStartTime < tripStartTime) {
                    tripStartTime = planStartTime;
                }
            }
            if (!isNaN(planEndTime)) {
                if (isNaN(tripStartTime) || planEndTime < tripStartTime) {
                    tripStartTime = planEndTime;
                }
            }

            if (!isNaN(planStartTime)) {
                if (isNaN(tripEndTime) || planStartTime > tripEndTime) {
                    tripEndTime = planStartTime;
                }
            }
            if (!isNaN(planEndTime)) {
                if (isNaN(tripEndTime) || planEndTime > tripEndTime) {
                    tripEndTime = planEndTime;
                }
            }
        }

        if (!isNaN(tripStartTime)) {
            trip.actual_start_time = tripStartTime.toISOString();
        }
        if (!isNaN(tripEndTime)) {
            trip.actual_end_time = tripEndTime.toISOString();
        }
        return trip;
    }

    /**
     * adjust trip part's time range when itineraries are responded
     * only applicable if we deal with UI display window for each trip part
     * default min ui duration is 1hr
     * default max ui duration is 2hrs
     * not being used
     * @param {object} trip
     * @return {bool}: if false, then something wrong with time range, should not render this trip
     */
    function adjustTripTimeRangeWithUIDipslayWindow(trip) {
        var strTripStartTime = trip.start_time;
        var strTripEndTime = trip.end_time;
        var minUIDuration = typeof(trip.min_ui_duration) === 'number' ? trip.min_ui_duration : 60; //default 1 hr
        var maxUIDuration = typeof(trip.max_ui_duration) === 'number' ? trip.max_ui_duration : 2 * 60; //default 2 hrs

        var tripStartTime = parseDate(strTripStartTime);
        var tripEndTime = parseDate(strTripEndTime);

        var actualTripStartTime = parseDate(trip.actual_start_time); //min time by iterating all legs in all itineraries
        var actualTripEndTime = parseDate(trip.actual_end_time); //max time by iterating all legs in all itineraries

        if (!isNaN(actualTripStartTime) && !isNaN(actualTripEndTime)) {
            var actualTimeRange = (actualTripEndTime - actualTripStartTime) / (1000 * 60);
            if (actualTimeRange > maxUIDuration) {
                maxUIDuration = actualTimeRange;
            }
        }

        var isStartTimeInvalid = isNaN(tripStartTime);
        var isEndTimeInvalid = isNaN(tripEndTime);
        if (isStartTimeInvalid && isEndTimeInvalid) {
            return false;
        } else if (isStartTimeInvalid) { //check max_ui_duration restriction
            tripEndTime = moment(tripEndTime).toDate();

            tripStartTime = moment(tripEndTime).subtract('minutes', maxUIDuration).toDate();

            if (!isNaN(actualTripStartTime) && tripStartTime > actualTripStartTime) {
                tripStartTime = moment(actualTripStartTime).subtract('minutes', intervalStep).toDate();
            }
        } else if (isEndTimeInvalid) {
            tripStartTime = moment(tripStartTime).toDate();
            tripEndTime = moment(tripStartTime).add('minutes', maxUIDuration).toDate();

            if (!isNaN(actualTripEndTime) && tripEndTime < actualTripEndTime) {
                tripEndTime = moment(actualTripEndTime).add('minutes', intervalStep).toDate();
            }
        }

        if (tripEndTime <= tripStartTime) {
            return false;
        }

        var timeRangeMins = (tripEndTime - tripStartTime) / (1000 * 60);
        if (timeRangeMins < minUIDuration) { //check min_ui_duration restriction
            tripStartTime = moment(tripStartTime).subtract('minutes', (minUIDuration - timeRangeMins) / 2).toDate();
            tripEndTime = moment(tripEndTime).add('minutes', (minUIDuration - timeRangeMins) / 2).toDate();
        }

        trip.start_time = tripStartTime.toISOString();
        trip.end_time = tripEndTime.toISOString();

        trip.min_ui_duration = minUIDuration;
        trip.max_ui_duration = maxUIDuration;

        return true;
    }

    /**
     * adjust trip part's time range when itineraries are responded
     * @param {object} trip
     * @return {bool}: if false, then something wrong with time range, should not render this trip
     */
    function adjustTripTimeRangeWithoutUIDipslayWindow(trip) {
        var strTripStartTime = trip.start_time;
        var strTripEndTime = trip.end_time;

        var tripStartTime = parseDate(strTripStartTime);
        var tripEndTime = parseDate(strTripEndTime);

        var actualTripStartTime = parseDate(trip.actual_start_time); //min time by iterating all legs in all itineraries
        var actualTripEndTime = parseDate(trip.actual_end_time); //max time by iterating all legs in all itineraries

        var actualTimeRange = 1 * 60; //1hr as default
        if (!isNaN(actualTripStartTime) && !isNaN(actualTripEndTime)) {
            actualTimeRange = (actualTripEndTime - actualTripStartTime) / (1000 * 60);
        }

        var is_depart_at = trip.is_depart_at;
        var isStartTimeInvalid = isNaN(tripStartTime);
        var isEndTimeInvalid = isNaN(tripEndTime);
        if (isStartTimeInvalid && isEndTimeInvalid) {
            return false;
        } else if (is_depart_at || isEndTimeInvalid) {
            tripStartTime = moment(tripStartTime).toDate();
            tripEndTime = moment(tripStartTime).add('minutes', actualTimeRange).toDate();

            if (!isNaN(actualTripEndTime) && tripEndTime < actualTripEndTime) {
                tripEndTime = moment(actualTripEndTime).add('minutes', intervalStep).toDate();
            }
        } else if (!is_depart_at || isStartTimeInvalid) {
            tripEndTime = moment(tripEndTime).toDate();

            tripStartTime = moment(tripEndTime).subtract('minutes', actualTimeRange).toDate();

            if (!isNaN(actualTripStartTime) && tripStartTime > actualTripStartTime) {
                tripStartTime = moment(actualTripStartTime).subtract('minutes', intervalStep).toDate();
            }
        }

        if (tripEndTime <= tripStartTime) {
            return false;
        }

        trip.start_time = tripStartTime.toISOString();
        trip.end_time = tripEndTime.toISOString();

        return true;
    }

    /*
     * re-format data in trip object
     * - leg type formatting: only allow Walk, Transfer, Vehicle
     * - legs [] is empty: then need to put itinerary data into legs array
     * - start_time or end_time: if null then use trip's start_time or end_time
     */
    function formatTripData(trip) {
        if (typeof trip != 'object' || trip === null) {
            return null;
        }

        if (!adjustTripTimeRangeWithoutUIDipslayWindow(trip)) {
            return null;
        }

        if (!trip.itineraries instanceof Array) {
            return trip;
        }

        trip.itineraries.forEach(function(plan) {
            if (isNaN(parseDate(plan.start_time))) {
                plan.start_time = trip.start_time;
                plan.start_time_estimated = true;
            } else {
                plan.start_time_estimated = false;
            }

            if (isNaN(parseDate(plan.end_time))) {
                plan.end_time = trip.end_time;
                plan.end_time_estimated = true;
            } else {
                plan.end_time_estimated = false;
            }

            if (plan.legs instanceof Array) {
                if (plan.legs.length === 0) {

                    var legDescription = '';
                    if (plan.service_name != null) {
                        if (plan.provider_name != null) {
                            legDescription = toCamelCase(plan.mode_name) + ': ' + plan.service_name + ' (' + plan.provider_name + ')';
                        } else {
                            legDescription = toCamelCase(plan.mode_name) + ': ' + plan.service_name;
                        }
                    } else {
                        legDescription = toCamelCase(plan.mode_name);
                    }

                    var tripDescription = trip.hasOwnProperty('description_without_direction') ? trip.description_without_direction : trip.description;
                    legDescription += ' - ' + tripDescription;
                    plan.legs.push({
                        "type": getLegTypeFromPlanMode(plan.mode),
                        "description": legDescription,
                        "start_time": plan.start_time,
                        "end_time": plan.end_time,
                        "start_time_estimated": plan.start_time_estimated,
                        "end_time_estimated": plan.end_time_estimated
                    });
                }

                plan.legs.forEach(function(leg) {
                    if (!(typeof(leg.type) === 'string' && leg.type.trim().length > 0)) {
                        leg.type = 'unknown';
                    }

                    if (isNaN(parseDate(leg.start_time))) {
                        leg.start_time = trip.start_time;
                        leg.start_time_estimated = true;
                    }

                    if (isNaN(parseDate(leg.end_time))) {
                        leg.end_time = trip.end_time;
                        leg.end_time_estimated = true;
                    }
                });
            }
        });

        return trip;
    }

    /*
     * get filters (Mode, duration, cost, No of transfer)
     * @param {object} trip
     */
    function getTripPartFilterValues(trip) {
        var modes = [];
        var minTransfer = 0;
        var maxTransfer = 0;
        var minCost = -1;
        var maxCost = -1;
        var minDuration = -1;
        var maxDuration = -1;

        if (typeof(trip) != 'object' || trip === null || !trip.itineraries instanceof Array) {
            return;
        }
        var tripPlans = trip.itineraries;
        tripPlans.forEach(function(tripPlan) {
            if (typeof(tripPlan) != 'object' || tripPlan === null) {
                return;
            }

            //transfers
            var transfer = parseInt(tripPlan.transfers);
            if (transfer >= 0 && transfer > maxTransfer) {
                maxTransfer = transfer;
            }

            //cost
            var costInfo = tripPlan.cost;
            if (isValidObject(costInfo)) {
                var cost = parseFloat(costInfo.price);
                if (cost >= 0) {
                    if (minCost < 0 || cost < minCost) {
                        minCost = cost;
                    }

                    if (maxCost < 0 || cost > maxCost) {
                        maxCost = cost;
                    }
                }
            }

            //duration
            var durationInfo = tripPlan.duration;
            if (isValidObject(durationInfo)) {
                var duration = parseFloat(durationInfo.sortable_duration) / 60;
                if (duration >= 0) {
                    if (minDuration < 0 || duration < minDuration) {
                        minDuration = duration;
                    }

                    if (maxDuration < 0 || duration > maxDuration) {
                        maxDuration = duration;
                    }
                }
            }

            //modes
            var modeName = tripPlan.mode_name;
            if (modes.indexOf(modeName) < 0) {
                modes.push(modeName);
            }
        });

        var filterAvailable = (modes.length > 0 || (maxTransfer > minTransfer) || (maxCost > minCost) || (maxDuration > minDuration));

        return {
            isAvailable: filterAvailable,
            modes: modes,
            transfer: [minTransfer, maxTransfer],
            duration: [minDuration, maxDuration],
            cost: [minCost, maxCost]
        }
    }


    function getLegTypeFromPlanMode(mode) {
        //if mode starts with 'mode_', then leg type is the text after 'mode_'
        return typeof(mode) != 'string' ? '' : (mode.indexOf('mode_') >= 0 ? mode.substr(mode.indexOf('mode_') + 5) : mode);
    }

    /*
     * get round value
     * e.g., 75 -> 75
     *    (75, 76] -> 76
     * @param {number}
     */
    function getRoundMaxValue(rawValue) {
        if (typeof(rawValue) != 'number') {
            return null;
        }

        var roundValue = parseInt(rawValue);
        return (rawValue === roundValue) ? roundValue : (roundValue + 1);
    }

    /*
     * get round value
     * e.g., [75, 76) -> 75
     * @param {number}
     */
    function getRoundMinValue(rawValue) {
        if (typeof(rawValue) != 'number') {
            return null;
        }

        return parseInt(rawValue);
    }

    /*
     * Generate Camel case
     * @param {string} str
     * @return {string}
     */
    function toCamelCase(str) {
        if (typeof(str) != 'string') {
            return '';
        }
        return str.replace(/(?:^|\s)\w/g, function(match) {
            return match.toUpperCase();
        });
    }

    /*
     * remove spaces within a string
     * @param {string} str
     * @return {string}
     */
    function removeSpace(str) {
        if (typeof(str) != 'string') {
            return '';
        }
        return str.replace(/\s+/g, '');
    }

    /*
     * check a variable is a valid object (is Object type, not null)
     * @param {object} obj
     * @return {bool}
     */
    function isValidObject(obj) {
        return typeof(obj) === 'object' && obj != null;
    }

    //public methods
    this.processTripResponse = processTripResponse;
}