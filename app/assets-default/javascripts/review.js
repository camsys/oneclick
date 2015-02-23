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
 * parse date
 * require moment.js
 * @param {string} dateStr
 * @return {Date}
 */
function parseDate(dateStr) {
    if (typeof(dateStr) != 'string') {
        dateStr = null;
    }

    return moment(dateStr).toDate();
}

function formatDate(dateToFormat) {
    if (dateToFormat instanceof Date) {
        if (dateToFormat.getFullYear() === (new Date()).getFullYear()) {
            return moment(dateToFormat).format("dddd, MMMM D") //Sunday, June 8
        } else {
            return moment(dateToFormat).format("dddd, MMMM D YYYY") //Sunday, June 8 2014
        }
    }

    return '';
}

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
 * TripReviewPageRenderer class: a self-contained class to render dynamic items on trip review page
 * @param {number}: intervalStep (minutes)
 * @param {number}: barHeight (pixel)
 * @param {Object}: tripResponse
 * @param {Object}: filterConfigs, each item specifies default min/max filter value
 * @param {Object}: localeDictFinder, a hash of localized texts
 * @method processTripResponse: public method to process trip results
 */
function TripReviewPageRenderer(intervalStep, barHeight, tripResponse, filterConfigs, localeDictFinder) {
    localeDictFinder = isValidObject(localeDictFinder) ? localeDictFinder : {};
    filterConfigs = isValidObject(filterConfigs) ? filterConfigs : {};
    var _tripResponse = tripResponse; //trip json

    var _isInitial = true; //a flag whether this is initial trip response
    var _totalModeRequestCounter = 0; //a counter that keeps track of all itinerary requests for each mode_trip_part;
    // when _totalModeRequestCounter > 0, then show loading mask; when 0, hide;

    //trip restriction missing_info lookup
    //format: [{trip_restriction_modal_id: {data: missing_info_array, clearCode: 0(init), 1(all pass), -1(not pass)}}]
    var _missingInfoLookup = {};

    if (typeof(intervalStep) != 'number' || intervalStep < 0) {
        intervalStep = 30; //30min as default
    }

    if (typeof(barHeight) != 'number' || barHeight < 0) {
        barHeight = 20; //20px as default
    }

    var baseContainerId = 'reviewBaseContainer'; //id of review page base container
    var tripContainerId = 'tripContainer'; //id of trip container Div
    var accessoryContainerId = "accessoryContainer"; //id of accessory container div (legends, filters)
    var legendContainerId = "legendDiv"; //id of legend container div
    var legendButtonId = 'legendButton'; //id of Show/Hide Legend button
    var filterContainerId = "filterDiv"; //id of filter container div
    var filterButtonId = 'filterButton'; //id of Show/Hide Filter button
    var modeContainerId = "modeContainer"; //id of mode filter container div
    var transferSliderId = "transferSlider"; //id of transfer filter slider
    var costSliderId = "costSlider"; //id of cost filter slider
    var durationSliderId = "durationSlider"; //id of duration filter slider
    var walkDistSliderId = "walkDistSlider"; //id of walk distance filter slider
    var waitTimeSliderId = "waitTimeSlider"; //id of wait time filter slider
    var paratransitCountSliderId = "paratransitCountSlider"; //id of paratransit count filter slider

    var tripPlanDivPrefix = "tripPlan_"; //prefix of each trip plan div
    var missInfoDivAffix = "_restriction"; //affix of each trip restriction modal dialog

    //page document width
    //be used to detect width change -> resize charts
    var documentWidth = $(document.body).width();

    var METERS_TO_MILES = 0.000621371192;

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

        var tripPartIndex = 0;
        tripParts.forEach(function(trip) {
            var inlineHelperKey = '';
            if (tripPartIndex === 0) { //outbound
                inlineHelperKey = 'trip_outbound_help';
            } else if (tripPartIndex === tripParts.length - 1) { //return
                inlineHelperKey = 'trip_return_help';
            }
            addTripHtml(trip, inlineHelperKey);

            tripPartIndex ++;
        });


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

        //in case there is chart layout issue
        resizeChartsWhenDocumentWidthChanges();
    }

    /**
     * -30 | +30 was clicked, then refresh associated trip part plans
     */
    function executePeriodChangeQuery(tripPartId, isNext) {
        $.ajax({
            url: window.location.href + '/trip_parts/' + tripPartId + '/reschedule.json?minutes=' + (isNext ? '' : '-') + intervalStep
        })
            .done(function(response) {
                if (response.status === 200) { //valid response, then refresh page
                    window.location.reload();
                } else {
                    show_alert(response.responseJSON.message);
                }
            })
            .fail(function(response) {
                if (response.status === 409) {
                    show_alert(response.responseJSON.message);
                } else {
                    //console.log(response);
                    show_alert(localeDictFinder['something_went_wrong']);
                }
            });
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
        //register event listener for -30 | +30 nav buttons
        $('.next-period').on('click', function() {
            var tripPartObj = $(this).parents('.single-trip-part');
            if (tripPartObj.length > 0) {
                var tripPartId = tripPartObj.attr('data-trip-id');
                executePeriodChangeQuery(tripPartId, true);
            }
        });
        $('.prev-period').on('click', function() {
            var tripPartObj = $(this).parents('.single-trip-part');
            if (tripPartObj.length > 0) {
                var tripPartId = tripPartObj.attr('data-trip-id');
                executePeriodChangeQuery(tripPartId, false);
            }
        });

        //add sorting dropdown change listener
        $('.single-trip-part select').on('change', function(e) {
            sortItineraryBy(e.currentTarget);
        });

        //windows resize needs to update charts
        window.onresize = function(event) {
            waitForFinalEvent(function() {
                resizeChartsWhenDocumentWidthChanges();
            }, 100, 'window resize');
        };

        //clicking Select button to change styles
        $('.single-plan-review .single-plan-select').click(function() {
            selectItineraryByClickingSelectButton(this);
        });

        //clicking ? button to pop up eligibility questions
        $('.single-plan-review .single-plan-question').click(function() {
            onClickSinglePlanQuestionButton(this);
        });

        //check if no itineraries in any trip part
        checkIfNoItineraries(_tripResponse.trip_parts);

        registerChartContainerEvents();

        //render legend & filter
        addLegendHtml(_tripResponse.trip_parts);
        addFilterHtml(_tripResponse.trip_parts);

        resizePlanColumns();
        resizeAllCharts();

        $('.ui-slider-handle').empty();

        createPopover(".single-plan-chart-container rect, .trip-mode-cost, .label-help");

        $('.label-help').addClass('fa-2x');
    }

    function checkLoadingMask() {
        if (_totalModeRequestCounter > 0) {
            //show loading mask
            $('#' + baseContainerId).overlayMask();
        } else {
            //hide loading mask
            $('#' + baseContainerId).overlayMask('remove');

            executeWhenDataReady();

            // Set specific tab order for inline help in filter panels
            setHelperTabIndex('9');
            setHelperTabIndex('10');
            setHelperTabIndex('11');
            setHelperTabIndex('12');
            setHelperTabIndex('13');
            setHelperTabIndex('14');

            // Include slider handles in tab order
            setSliderHandleTabIndex('#transferSlider', '11');
            setSliderHandleTabIndex('#costSlider', '12');
            setSliderHandleTabIndex('#durationSlider', '13');
            setSliderHandleTabIndex('#walkDistSlider', '14');

            // Set aria-labels for outbound/return midTripTime
            setMidTripAriaLabel();
        }
    }

    function setHelperTabIndex(tabindex) {
        $("h2[tabindex='" + tabindex + "'] > .label-help").attr('tabindex', tabindex);
    }

    function setSliderHandleTabIndex(obj, tabindex) {
        $(obj + ' > .ui-slider-handle').attr('tabindex', tabindex);
    }

    function setMidTripAriaLabel() {
        var tripPartDivIds = [];
        $('.single-trip-part').each(function(){
            tripPartDivIds.push($(this).attr('id'));
        });
        for (i=0; i < tripPartDivIds.length; i++) {
            selector = "#" + tripPartDivIds[i] + " .single-plan-header";
            ticks = $(selector).children('.col-xs-12:last').children('.tick-labels').children();
            heading = $(selector).children('.col-xs-12:nth-child(2)').children('.panel-heading');
            tripMidTime = heading.children('span');
            invisibleLabel = heading.children('label');

            first = ticks.first().text();
            last = ticks.last().text();
            label = tripMidTime.text() + ", " + localeDictFinder['from'] + " " + first + " " + localeDictFinder['to'] + " " + last;
            invisibleLabel.text(label);
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
     * bring up plan details dialog in respond to chart container events (press SPACE bar, double click, and mobile double-tap)
     */
    function registerChartContainerEvents() {
        $('.single-trip-part').on("keydown", ".single-plan-chart-container", function(e) { //click to show details in modal dialog
            var planId = $(this).parent('.single-plan-review').data('plan-id');
            if(e.keyCode === 32) {
                showItineraryModal(planId);
            }
        });

        $('.single-trip-part').on("dblclick", ".single-plan-chart-container", function() { //click to show details in modal dialog
            var planId = $(this).parent('.single-plan-review').data('plan-id');
            showItineraryModal(planId);
        });

        $('.single-trip-part').on("touchstart", ".single-plan-chart-container", function() { //for mobile
            $(this).focus();
            if(event) {
                var planId = $(this).parent('.single-plan-review').data('plan-id');
                var t2 = event.timeStamp;
                var t1 = $(this).data('lastTouch') || t2;
                var dt = t2 - t1;
                var fingers = event.touches.length;
                $(this).data('lastTouch', t2);
                if (!dt || dt > 500 || fingers > 1) return; // not double-tap
                showItineraryModal(planId);
                event.preventDefault ? event.preventDefault() : event.returnValue = false;
            }
        });
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
     * event listener of clicking question ? button in a specific itinerary
     */
    function onClickSinglePlanQuestionButton(questionButton) {
        var planDiv = $(questionButton).parents('.single-plan-review');
        var tripPlanChartDivId = tripPlanDivPrefix + planDiv.attr('data-trip-id') + '_' + planDiv.attr('data-plan-id');
        var missInfoDivId = tripPlanChartDivId + missInfoDivAffix;
        var missingInfoNode = _missingInfoLookup[tripPlanChartDivId];
        addTripRestrictionDialogHtml(missingInfoNode.data, missInfoDivId);
        addTripStrictionFormValidatiaonListener(missInfoDivId);
        addTripStrictionFormSubmissionListener(missingInfoNode.data, tripPlanChartDivId);
    }

    /*
     * event listener of clicking Select button in a specific itinerary
     */
    function selectItineraryByClickingSelectButton(planSelectButton) {
        $(planSelectButton).parents('.single-trip-part').find('.single-plan-review')
            .removeClass('single-plan-selected')
            .addClass('single-plan-unselected');
        $(planSelectButton).parents('.single-plan-review')
            .removeClass('single-plan-unselected')
            .addClass('single-plan-selected');
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
                        "logo_url": plan.mode_logo_url,
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

    /**
     * Given each trip part, render to UI
     * @param {object} trip
     */
    function addTripHtml(trip, inlineHelperKey) {
        //check if trip is object
        if (typeof trip != 'object' || trip === null) {
            return;
        }

        var isDepartAt = trip.is_depart_at; //departing at or arriving at??
        var tripId = trip.id;
        var strTripStartTime = trip.start_time;
        var strTripEndTime = trip.end_time;

        var tripStartTime = parseDate(strTripStartTime);
        var tripEndTime = parseDate(strTripEndTime);

        var isStartTimeInvalid = isNaN(tripStartTime);
        var isEndTimeInvalid = isNaN(tripEndTime);
        if (isStartTimeInvalid || isEndTimeInvalid || tripEndTime <= tripStartTime) {
            return;
        }

        var tripPartDivId = "trip_part_" + tripId;

        var tickLabels = getTickLabels(tripStartTime, tripEndTime, intervalStep);
        if ($('#' + tripPartDivId).length === 0) { //new trip part
            var tripTags = "<div id='" + tripPartDivId + "'class='col-xs-12 well single-trip-part' data-trip-id='" + tripId + "'>";
            isDepartAt ? (header = localeDictFinder['return']) : (header = localeDictFinder['outbound']);
            var tripHeaderTags = addTripHeaderHtml(header, tickLabels, intervalStep, isDepartAt, tripStartTime, tripEndTime, inlineHelperKey, trip.description_without_direction);
            tripTags += tripHeaderTags;

            //process each trip plan
            var tripPlans = trip.itineraries;
            var paratransitTotalCounter = 0;
            tripPlans.forEach(function(tripPlan) {
                if (isValidObject(tripPlan)) {
                    var paratransitCounter = null;
                    if(tripPlan.mode === 'mode_paratransit') {
                        paratransitTotalCounter += 1;
                        paratransitCounter = paratransitTotalCounter;
                    }

                    tripTags += addTripPlanHtml(
                        tripId,
                        tripPlan,
                        strTripStartTime,
                        strTripEndTime,
                        isDepartAt,
                        tripPlan.selected,
                        paratransitCounter
                    );
                }
            });

            tripTags += "</div>";

            //render HTML
            $('#' + tripContainerId).append(tripTags);

            //render Chart
            tripPlans.forEach(function(tripPlan) {
                if (isValidObject(tripPlan)) {

                    var tripPlanChartId = tripPlanDivPrefix + tripId + "_" + tripPlan.id;
                    createChart(
                        tripPlanChartId,
                        tripStartTime,
                        tripEndTime,
                        tripPlan
                    );

                    addTripStrictionFormSubmissionListener(tripPlan.missing_information, tripPlanChartId);
                }
            });
        } else {
            //update tick labels
            var tickLabelTags = getTickLabelHtmlTags(tickLabels);
            $('#' + tripPartDivId + " .tick-labels").html(tickLabelTags);

            //process each trip plan
            var tripPlans = trip.itineraries;
            var paratransitTotalCounter = 0;
            tripPlans.forEach(function(tripPlan) {
                if (isValidObject(tripPlan)) {
                    var paratransitCounter = null;
                    if(tripPlan.mode === 'mode_paratransit') {
                        paratransitTotalCounter += 1;
                        paratransitCounter = paratransitTotalCounter;
                    }
                    var tripPlanChartId = tripPlanDivPrefix + tripId + "_" + tripPlan.id;
                    if ($('#' + tripPlanChartId).length === 0) { //new itinerary
                        var itinTags = addTripPlanHtml(
                            tripId,
                            tripPlan,
                            strTripStartTime,
                            strTripEndTime,
                            isDepartAt,
                            tripPlan.selected,
                            paratransitCounter
                        );

                        $('#' + tripPartDivId).append(itinTags);

                        createChart(
                            tripPlanChartId,
                            tripStartTime,
                            tripEndTime,
                            tripPlan
                        );

                        addTripStrictionFormSubmissionListener(tripPlan.missing_information, tripPlanChartId);
                    } else {
                        var $plan = $('#' + tripPlanChartId).parents('.single-plan-review');
                        $plan.attr('data-trip-start-time', strTripStartTime);
                        $plan.attr('data-trip-end-time', strTripEndTime);
                    }
                }
            });

            //resize chart
            resizeAllCharts();
        }


        //sort
        sortItineraryBy($('#' + tripPartDivId + " .trip-sorter")[0]);
        return;
    }

    /*
     * attach text-only itinerary description as aria-label; attach html-version itinerary description as tooltip
     * @param {string} tripId
     * @param {object} tripPlan: itinerary object
     */
    function appendItineraryTooltip(chart, tripId, tripPlan) {
        var tipTextOnly = getHoverTipText(tripPlan, true);
        var tipHtml = getHoverTipText(tripPlan, false);

        chart.selectAll("rect")
            .attr('data-original-title', tipHtml)
            .attr('aria-label', tipTextOnly);
    }

    /*
     * trip restiction form validation
     * @param {string} tripPlanChartDivId
     */
    function addTripStrictionFormValidatiaonListener(missInfoDivId) {
        $('#' + missInfoDivId + ' input[data-eligibility-code=age]').on('focusin', function() {
            if ($(this).siblings('.help-block').length === 0) {
                var helpMsg = localeDictFinder['four_digit_year'] + ' ' + $(this).attr('min') + '-' + $(this).attr('max');
                $(this).after('<span class="help-block with-errors">' + helpMsg + '</span>');
            }
        });

        $('#' + missInfoDivId + ' input[data-eligibility-code=age]').on('focusout', function() {
            var rawVal = $(this).val();
            var val = parseInt(rawVal);
            var min = parseInt($(this).attr('min'));
            var max = parseInt($(this).attr('max'));
            var isValid = !isNaN(val) &&
                (isNaN(min) || val >= min) &&
                (isNaN(max) || val <= max);


            if (!isValid) {
                $(this).parent('div').addClass('has-error');
            } else {
                $(this).parent('div').removeClass('has-error');
            }
        });
    }

    /*
     * trip restiction form submission
     * add on-click listener for Update button in each trip restriction modal dialog
     * @param {Array} missingInfoArray
     * @param {string} tripPlanChartDivId
     */
    function addTripStrictionFormSubmissionListener(missingInfoArray, tripPlanChartDivId) {
        if (!missingInfoArray instanceof Array || missingInfoArray.length === 0) {
            return;
        }

        var missInfoDivId = tripPlanChartDivId + missInfoDivAffix;

        $('#' + missInfoDivId + '_form').submit(function(e) {
            if ($('#' + missInfoDivId + ' form .has-error').length > 0) {
                return false;
            }
            var dialog = $('#' + missInfoDivId);
            var formVals = dialog.find('form').serializeArray();

            var infoCount = missingInfoArray.length;
            for (var i = infoCount - 1; i >= 0; i--) {
                var missingInfo = missingInfoArray[i];

                if (typeof(missingInfo) != 'object' || missingInfo === null || !missingInfo.hasOwnProperty('success_condition')) {
                    continue;
                }

                var questionText = missingInfo.question;
                var controlName = missingInfo.controlName;
                var questionVal = findQuestionValue(controlName, formVals);
                var valueToApply = (questionVal != null ? questionVal.value : null)
                updateTripRestrictions(questionText, valueToApply);

        		if (missingInfo.code === 'age') {
        		    new_age = parseInt(missingInfo.year);
                    if(!isNaN(new_age) && valueToApply === 'false') {
                        new_age -= 1;
                        valueToApply = new_age;
                    }
        		}
                $.ajax({
                    type: "POST",
                    url: _tripResponse.characteristics_update_url,
                    data: {
                        user_answer: valueToApply,
                        code: missingInfo.code
                    }
                }).fail(function() {
                    show_alert(localeDictFinder['failed_to_update_profile']);
                })

            }

            applyChangesAfterTripRestrictionFormSubmission();

            dialog.modal('hide');

            e.preventDefault ? e.preventDefault() : e.returnValue = false;
        });

        $('#' + missInfoDivId + ' button[type=submit]').click(function() {
            $('#' + missInfoDivId + '_form').submit();
        });
    }

    /*
     * find the value associated with question
     */
    function findQuestionValue(name, values) {
        var targetVal = null;
        if (values instanceof Array) {
            for (var i = 0, valCount = values.length; i < valCount; i++) {
                var val = values[i];
                if (isValidObject(val) && val.name === name) {
                    targetVal = val;
                    break;
                }
            }
        }

        return targetVal;
    }

    /*
     * check if user_answer is empty
     */
    function isUserAnswerEmpty(value) {
        return (value === undefined || value === '' || value === null);
    }

    /*
     * update all missing info data of all itineraries
     * @param {string} questionText
     * @param {string} answer
     */
    function updateTripRestrictions(questionText, answer) {
        for (var tripPlanChartDivId in _missingInfoLookup) {
            var infoArray = _missingInfoLookup[tripPlanChartDivId].data;
            if (infoArray instanceof Array) {
                for (var i = 0, infoCount = infoArray.length; i < infoCount; i++) {
                    var missInfo = infoArray[i];
                    if (isValidObject(missInfo) && missInfo.question === questionText) {
                        if (!isUserAnswerEmpty(answer)) {
                            missInfo.user_answer = answer;
                        } else {
                            delete missInfo.user_answer;
                        }
                        break;
                    }
                }
            }
        }
    }

    /*
     * check if a specific itinerary is visible or not; if visible, then need to resize chart
     * @param {Object} plan: jQuery select result
     */
    function detectPlanVisibilityChange(plan) {
        if (plan.attr('data-eligibility-visible') == '1' && plan.attr('data-filter-visible') == '1') {
            plan.show();
            resizeChartViaPlan(plan);
        } else {
            plan.hide();
        }

        resizeChartsWhenDocumentWidthChanges();
    }

    function getSelectButtonHtml(isDepartAt) {
        if (isDepartAt === undefined) { isDepartAt = false; }
        var tags =
            ("<button role='button' class='btn btn-default single-plan-select action-button select-column-button' aria-label='Select this option.' tabindex=" + (isDepartAt ? '16' : '15') + ">" +
                "<span class='hidden-xs'>" + localeDictFinder['select'] + "</span>" +
                "<span class='visible-xs'>&#10004;</span>" +
                "</button>");
        return tags;
    }

    /*
     * apply changes: if pass all questions, then make itinerary select-able; if fail one question, then remove this itinerary; otherwise, re-render restriction dialog
     */
    function applyChangesAfterTripRestrictionFormSubmission() {
        for (var tripPlanChartDivId in _missingInfoLookup) {
            var missingInfoNode = _missingInfoLookup[tripPlanChartDivId];
            var questionClearCode = checkEligibility(missingInfoNode.data);
            var tripPlanDiv = $('#' + tripPlanChartDivId).parents('.single-plan-review');
            if (questionClearCode === -1) { //not pass
                tripPlanDiv.attr('data-eligibility-visible', 0);
                detectPlanVisibilityChange(tripPlanDiv);
            } else {
                tripPlanDiv.attr('data-eligibility-visible', 1);
                detectPlanVisibilityChange(tripPlanDiv);
                if (questionClearCode === 1) { //all pass
                    tripPlanDiv.find('.single-plan-question').remove();
                    if (tripPlanDiv.find('.single-plan-select').length === 0) {
                        tripPlanDiv.find('.select-column').append(getSelectButtonHtml()).click(function() {
                            selectItineraryByClickingSelectButton(this);
                        });
                    }
                } else {
                    tripPlanDiv
                        .removeClass('single-plan-selected')
                        .addClass('single-plan-unselected'); //in case was selected
                    tripPlanDiv.find('.single-plan-select').remove();
                    if (tripPlanDiv.find('.single-plan-question').length === 0) {
                        tripPlanDiv.find('.select-column').append("<button role='button' class='btn btn-default single-plan-question action-button select-column-button'>?</button>").click(function() {
                            onClickSinglePlanQuestionButton(this);
                        });
                    }
                }
            }
        }

        updateChartsIfDatetimeRangeChanged();
    }

    /*
     * given a list of eligibility questions, check if eligible or not
     * questions are in groups: AND relationship to eval within group; OR relationship among group eligibility;
     * @return {number} clearCode: 1 - eligible; -1 - not eligible; 0 - Status not change.
     */
    function checkEligibility(missingInfoArray) {
        var clearCode = 0;
        if (!missingInfoArray instanceof Array) {
            clearCode = 1;
            return clearCode;
        }

        var infoGroups = {}; //by group_id
        missingInfoArray.forEach(function(missInfo) {
            var infoGroupId = missInfo.group_id;
            if (!infoGroups.hasOwnProperty(infoGroupId)) {
                infoGroups[infoGroupId] = [];
            }
            infoGroups[infoGroupId].push(missInfo);
        });

        var eligible = null; //default
        var notEligible = null; //default
        var groupCount = 0;
        var hasIncompleteGroup = false;
        for (var infoGroup in infoGroups) {
            var groupEligible = null; //default
            var isSameGroupAllEligible = true;
            infoGroups[infoGroup].forEach(function(info) {
                if (groupEligible === false) {
                    return;
                }
                var infoEligible = null;
                if (!isUserAnswerEmpty(info.user_answer)) {
                    infoEligible = evalSuccessCondition(formatQuestionAnswer(info.data_type, info.user_answer), info.success_condition);
                }

                if (infoEligible != true) { //AND relationship within group
                    isSameGroupAllEligible = false;
                    if (infoEligible === false) {
                        groupEligible = infoEligible;
                    }
                }
            });

            if (isSameGroupAllEligible) {
                groupEligible = true;
            }

            if (groupEligible === true || groupEligible === false) {
                if (eligible === null) {
                    eligible = false;
                }
                if (notEligible === null) {
                    notEligible = true;
                }
                eligible = eligible || groupEligible; // OR relationship among group
                notEligible = notEligible && !groupEligible;
            } else {
                hasIncompleteGroup = true;
            }
            groupCount++;
        }

        if (groupCount === 0) {
            eligible = true;
            notEligible = false;
        }

        if (eligible === true) {
            clearCode = 1;
        }
        if (notEligible === true && !hasIncompleteGroup) {
            clearCode = -1;
        }

        return clearCode;
    }

    /*
     * eval success condition for each question during form submission
     * @param {string} value
     * @param {string} successCondition
     * @return {bool}
     */
    function evalSuccessCondition(value, successCondition) {
        try {
            return eval(value + successCondition);
        } catch (evalError) {
            //console.log(evalError);
        }

        return false;
    }


    /*
     * format question answer so can eval with answer correctly
     */
    function formatQuestionAnswer(type, value) {
        switch (type) {
            case 'date':
            case 'datetime':
                value = "parseDate('" + value + "')";
                break;
            case 'integer':
                value = "parseInt('" + value + "')";
                break;
            default:
                break;
        }

        return value;
    }

    /**
     * Render trip header
     * @param {string} tripDescription
     * @param {number} intervelStep
     * @param {Array} tickLabels
     * @param {bool} isDepartAt: true if departing at, false if arriving at
     * @param {datetime} tripStartTime: trip part start time
     * @param {datetime} tripEndTime: trip part end time
     * @param {string} tripHeaderTags: html tags of the whole trip header
     */
    function addTripHeaderHtml(tripDescription, tickLabels, intervelStep, isDepartAt, tripStartTime, tripEndTime, inlineHelperKey, tripDescriptionWithoutDirection) {
        var tripDatetimeDescritpion = isDepartAt ?
            localeDictFinder['departing_at'] + ' ' + formatDate(tripStartTime) + ' ' + formatTime(tripStartTime) :
            localeDictFinder['arriving_by'] + ' ' + formatDate(tripEndTime)  + ' ' + formatTime(tripEndTime);
        //var headerAriaLabel = tripDescription + "; " + tripDatetimeDescritpion;
        //trip description
        var tripDescTag = "<div class='panel-heading'><h2 class='panel-title' tabindex=" + (isDepartAt ? '16' : '15') + ">" + addReviewTooltip(inlineHelperKey) + tripDescription + " - " + tripDescriptionWithoutDirection + "</h2></div>";

        var tickLabelTags = getTickLabelHtmlTags(tickLabels);

        var sorterLabelTags = "<span style='margin-left:15px;'>" + localeDictFinder['sort_by'] + ': </span>';
        var tripMidTime = new Date((tripStartTime.getTime() + tripEndTime.getTime()) / 2);
        var midDateLabelTags = "<label class='sr-only' tabindex='" + (isDepartAt ? "16" : "15") + "'>" + "</label><span style='line-height:2;' aria-hidden='true'>" + formatDate(tripMidTime) + '</span>';

        var sorterTags =
            '<select style="display: inline-block;" class="trip-sorter" tabindex=' + (isDepartAt ? "16" : "15") + '>"' +
            '<option value="start-time" ' + (isDepartAt ? ' selected' : '') + '>' + localeDictFinder["departure_time_sorter"] + '</option>' +
            '<option value="end-time" ' + (isDepartAt ? '' : ' selected') + '>' + localeDictFinder["arrival_time_sorter"] + '</option>' +
            '<option value="cost" >' + localeDictFinder['fare_sorter'] + '</option>' +
            '<option value="duration" >' + localeDictFinder['travel_time_sorter'] + '</option>' +
            '<option value="walk-dist" >' + localeDictFinder['walk_dist_sorter'] + '</option>' +
            '<option value="wait-time" >' + localeDictFinder['wait_time_sorter'] + '</option>' +
            '</select>';

        var tripHeaderTags = tripDescTag +
            "<div class='col-xs-12 single-plan-header' style='background-color:white;'>" +
            // "<div class='text-center' style='font-weight:500;' tabindex=" + (isDepartAt ? '16' : '15') + ">" +
            // tripDescriptionWithoutDirection +
            // "</div>" +
            "<div class='col-xs-12' style='padding:5px 0px;'>" +
            sorterLabelTags + sorterTags +
            "</div>" +
            "<div class='col-xs-12' style='padding:0px;'>" +
            "<div class='trip-plan-first-column' style='padding: 0px; vertical-align: top;'>" +
            (isDepartAt ? ("<button role='button' class='btn  btn-primary btn-single-arrow-left pull-right prev-period' aria-label='Move trip time back 30 minutes.' tabindex='16'> -" + intervelStep + "</button>") : "") +
            "</div>" +
            "<div class='" + (isDepartAt ? "highlight-left-border" : "highlight-right-border") + " trip-plan-main-column panel-heading' style='padding: 0px;white-space: nowrap; text-align: center; background-color: whitesmoke;'>" +
            (isDepartAt ? '' : midDateLabelTags) +
            (
                isDepartAt ?
                ("<button role='button' class='btn  btn-primary btn-single-arrow-right pull-left next-period' aria-label='Move trip time forward 30 minutes.' tabindex='16'> +" + intervelStep + "</button>") :
                ("<button role='button' class='btn  btn-primary btn-single-arrow-left pull-right prev-period' aria-label='Move trip time back 30 minutes.' tabindex='15'> -" + intervelStep + "</button>")
            ) +
            (isDepartAt ? midDateLabelTags : '') +
            "</div>" +
            "<div class='select-column' style='padding: 0px;'>" +
            (isDepartAt ? "" : ("<button role='button' class='btn  btn-primary btn-single-arrow-right pull-left next-period' aria-label='Move trip time forward 30 minutes.' tabindex='15'> +" + intervelStep + "</button>")) +
            "</div>" +
            "</div>" +
            "<div class='col-xs-12' style='padding:0px;' aria-hidden='true'>" +
            "<div class='trip-plan-first-column' style='padding: 0px;'>" +
            "</div>" +
            "<div class='tick-labels " + (isDepartAt ? "highlight-left-border" : "highlight-right-border") + " trip-plan-main-column' style='padding: 0px;white-space: nowrap;'>" +
            tickLabelTags +
            "</div>" +
            "<div class='select-column' style='padding: 0px;'>" +
            "</div>" +
            "</div>" +
            "</div>";
        return tripHeaderTags;
    }


    /*
     * given labels Array, return the html tags of label elements
     */
    function getTickLabelHtmlTags(tickLabels) {
        var tickLabelTags = '';
        //display 3 labels for xs; 7 for sm & md; 10 for lg
        if (tickLabels instanceof Array && tickLabels.length > 1) {
            var labelCount = tickLabels.length;

            var xsShowIndexArray = [0, labelCount - 1];
            var smShowIndexArray = [0];
            var lgShowIndexArray = [0];

            var midIndex = parseInt(labelCount / 2);
            if (xsShowIndexArray.indexOf(midIndex) < 0) {
                xsShowIndexArray.push(midIndex);
            }

            var smBaseUnit = parseInt(labelCount / 7) + 1;
            var smBase = smBaseUnit;
            while (smBase <= labelCount - 1) {
                if (smShowIndexArray.indexOf(smBase) <= 0) {
                    smShowIndexArray.push(smBase);
                }

                smBase += smBaseUnit;
            }

            var lgBaseUnit = parseInt(labelCount / 10) + 1;
            var lgBase = lgBaseUnit;
            while (lgBase <= labelCount - 1) {
                if (lgShowIndexArray.indexOf(lgBase) <= 0) {
                    lgShowIndexArray.push(lgBase);
                }

                lgBase += lgBaseUnit;
            }

            var labelWidthPct = 1 / (labelCount - 1) * 100 + '%';
            var labelIndex = 0;
            tickLabels.forEach(function(tickLabel) {
                var className = '';
                if (xsShowIndexArray.indexOf(labelIndex) < 0) {
                    className = ' tick-label-hidden-xs';
                }

                if (smShowIndexArray.indexOf(labelIndex) < 0) {
                    className += ' tick-label-hidden-sm-md';
                }

                if (lgShowIndexArray.indexOf(labelIndex) < 0) {
                    className += ' tick-label-hidden-lg';
                } else {
                    className += ' tick-label-visible-lg';
                }

                var marginTag = '';
                if (labelIndex === 0) {
                    marginTag = 'margin: 0px 0px 0px -20px';
                } else {
                    marginTag = 'margin: 0px;';
                }
                tickLabelTags +=
                    '<span class="' + className + '" style="display:inline-block;' + (labelIndex < (labelCount - 1) ? ('width:' + labelWidthPct) : '') + ';border: none;text-align:left;' + marginTag + ';">' + tickLabel + '</span>';
                labelIndex++;
            });
        }

        return tickLabelTags;
    }

    /**
     * Render trip part
     * @param {number} tripId
     * @param {Object} tripPlan
     * @param {string} strTripStartTime: trip start time
     * @param {string} strTripEndTime: trip end time
     * @param {bool} isDepartAt: true if departing at, false if arriving at
     * @param {bool} isSelected: true if this itinerary was selected previously
     * @param {bool} paratransitCounter: the number of paratransit plan within same trip part
     * @return {string} HTML tags of each trip plan
     */
    function addTripPlanHtml(tripId, tripPlan, strTripStartTime, strTripEndTime, isDepartAt, isSelected, paratransitCounter) {
        if (typeof(tripPlan) != 'object' || tripPlan === null) {
            return "";
        }
        var planId = tripPlan.id;
        var mode = tripPlan.mode ? tripPlan.mode : '';
        var modeName = tripPlan.mode_name ? tripPlan.mode_name : '';
        var serviceName = tripPlan.service_name ? tripPlan.service_name : '';
        var contact_information = tripPlan.contact_information;
        var cost = tripPlan.cost;
        var missingInfoArray = tripPlan.missing_information;
        var transfers = tripPlan.transfers;
        var duration = tripPlan.duration;
        var strPlanStartTime = tripPlan.start_time;
        var strPlanEndTime = tripPlan.end_time;
        var isPlanStartTimeEstimated = tripPlan.start_time_estimated;
        var isPlanEndTimeEstimated = tripPlan.end_time_estimated;
        var logoUrl = tripPlan.logo_url;
        var iconStyle = "background-image: url(" + logoUrl + ");"

        var modeServiceUrl = "";
        if (isValidObject(contact_information)) {
            modeServiceUrl = contact_information.url;
        }

        var chartDivId = tripPlanDivPrefix + tripId + "_" + planId;
        var missInfoDivId = chartDivId + missInfoDivAffix; //id of missing info modal dialog

        //check if missing info found; if so, need to us Question button instead of Select button
        var isMissingInfoFound = (missingInfoArray instanceof Array && missingInfoArray.length > 0);
        //add missing_info into page look_up
        var eligibleCode = 0;
        if (isMissingInfoFound) {
            _missingInfoLookup[chartDivId] = {
                data: missingInfoArray
            };
            eligibleCode = checkEligibility(missingInfoArray);

            //if not eligible, then set as not_selectable
            if (eligibleCode != 1) {
                isSelected = false;
            }
        }

        //assign data values to each plan div
        var dataTags =
            " data-trip-id='" + tripId + "'" +
            " data-plan-id='" + planId + "'" +
            " data-trip-start-time='" + strTripStartTime + "'" +
            " data-trip-end-time='" + strTripEndTime + "'" +
            " data-start-time='" + strPlanStartTime + "'" +
            " data-start-time-estimated='" + isPlanStartTimeEstimated + "'" +
            " data-end-time='" + strPlanEndTime + "'" +
            " data-end-time-estimated='" + isPlanEndTimeEstimated + "'" +
            " data-mode='" + modeName + "'" +
            " data-mode-code='" + mode + "'" +
            " data-transfer='" + (typeof(transfers) === 'number' ? transfers.toString() : '0') + "'" +
            " data-cost='" + ((isValidObject(cost) && (typeof(cost.price) === 'number')) ? cost.price : '') + "'" +
            " data-duration='" + (isValidObject(duration) ? parseFloat(duration.sortable_duration) / 60 : '') + "'" +
            " data-walk-dist='" + (isValidObject(duration) ? parseInt(duration.total_walk_dist) * METERS_TO_MILES: '') + "'" +
            " data-wait-time='" + (isValidObject(duration) ? parseFloat(duration.total_wait_time) / 60 : '') + "'" +
            " data-filter-visible = 1" +
            " data-eligibility-visible = " + (eligibleCode != -1 ? '1' : '0');

        if(typeof(paratransitCounter) === 'number' && paratransitCounter > 0) {
            dataTags +=
            " data-paratransit-number='" + paratransitCounter + "'";
        }

        var costTooltip = cost.comments;
        var costDisplay = (isValidObject(cost) ? cost.price_formatted : '');
        var costAriaLabel = costDisplay + ' ' + costTooltip;
        var isServiceAvailable = typeof(modeServiceUrl) === 'string' && modeServiceUrl.trim().length > 0;

        var tripPlanTags =
            "<div class='col-xs-12 single-plan-review " + (isSelected ? "single-plan-selected" : "single-plan-unselected") + "' style='padding: 0px;" + (eligibleCode === -1 ? "display: none;" : "") + "'" + dataTags + ">" +
            "<div class='trip-plan-first-column' style='padding: 0px; height: 100%;'>" +
            "<table style='width: 100%;'>" +
            "<tbody>" +
            "<tr>" +
            "<td tabindex=" + (isDepartAt ? '16' : '15') + " class='trip-mode-icon' aria-label='" + modeName + "' style='" + iconStyle + "'>" +
            (
                isServiceAvailable ?
                "<a aria-label='" + modeName + " " + serviceName + "' href='" + modeServiceUrl + "' target='_blank'</a>" : ""
            ) +
            "</td>" +
            "<td tabindex=" + (isDepartAt ? '16' : '15') + " class='trip-mode-cost' aria-label='" + costAriaLabel + "' title='" + costTooltip + "'>" +
            "<div class='itinerary-text'>" +
                costDisplay +
            "</div>" +
            "</td>" +
            "</tr>" +
            "</tbody>" +
            "</table>" +
            "</div>" +
            "<div tabindex=" + (isDepartAt ? '16' : '15') + " class='" +
            (isDepartAt ? "highlight-left-border regular-right-border" : "highlight-right-border regular-left-border") +
            " single-plan-chart-container trip-plan-main-column' style='padding: 0px; height: 100%;' id='" + tripPlanDivPrefix + tripId + "_" + planId + "'>" +
            "</div>" +
            "<div class='select-column' style='padding: 0px; height: 100%;'>" +
            (
                (isMissingInfoFound && eligibleCode != 1) ?
                (
                    "<button role='button' class='btn btn-default single-plan-question action-button select-column-button' " +
                    "data-toggle='modal' data-target='#" + missInfoDivId + "' tabindex=" + (isDepartAt ? '16' : '15') + ">?</button>"
                ) :
                getSelectButtonHtml(isDepartAt)
            ) +
            "</div>" +
            "</div>";

        return tripPlanTags;
    }

    /*
     * generate html tags for trip restrictions dialog
     * @param {Array} missingInfoArray
     * @param {string} missInfoDivId
     * @return {string} html tags
     */
    function addTripRestrictionDialogHtml(missingInfoArray, missInfoDivId) {
        $('#' + missInfoDivId).remove(); //clean previous one if any

        if (!missingInfoArray instanceof Array || missingInfoArray.length === 0 || typeof(missInfoDivId) != 'string') {
            return '';
        }

        var missInfoTags =
            '<div class="modal fade" data-backdrop="static" id="' + missInfoDivId + '" tabindex="-1" role="dialog" aria-labelledby="' + missInfoDivId + '_title" aria-hidden="true">' +
            addTripRestrictionDialogContentHtml(missingInfoArray, missInfoDivId) +
            '</div>';

        return $(document.body).append(missInfoTags);
    }

    function addTripRestrictionDialogContentHtml(missingInfoArray, missInfoDivId) {
        var questionTags = '';
        var questionIndex = 1;
        missingInfoArray.forEach(function(missingInfo) {
            var controlName = missInfoDivId + '_question_' + (questionIndex++);
            questionTags += addSingleTripRestrictionQuestion(missingInfo, controlName);
        });

        var contentTags =
            '<div class="modal-dialog">' +
            '<div class="modal-content">' +
            '<div class="modal-header">' +
            '<div class="pull-right">' +
            '<button role="button" type="submit" style="margin-right: 5px;" class="btn action-button">' + localeDictFinder['update'] + '</button>' +
            '<button role="button" type="button" class="btn action-button" data-dismiss="modal">' + localeDictFinder['cancel'] + '</button>' +
            '</div>' +
            '<b class="modal-title" id="' + missInfoDivId + '_title">' + localeDictFinder['trip_restrictions'] + '</b>' +
            '</div>' +
            '<div class="modal-body">' +
            '<form class="form-inline" role="form" id="' + missInfoDivId + '_form">' +
            questionTags +
            '</form>' +
            '</div>' +
            '</div>' +
            '</div>';

        return contentTags;
    }

    /*
     * generate html tags for each trip restriction question
     * @param {Object} missingInfo
     * @param {string} controlName
     * @return {string}
     */
    function addSingleTripRestrictionQuestion(missingInfo, controlName) {
        var isMissingInfoFound = (isValidObject(missingInfo) && missingInfo.hasOwnProperty('success_condition'));

        if (!isMissingInfoFound) {
            return '';
        }

        var infoLongDesc = missingInfo.question;
        var infoType = missingInfo.data_type;
        var successCondition = missingInfo.success_condition;
        var code = missingInfo.code;
        missingInfo.controlName = controlName;

        var answersTags = '';
        switch (infoType) {
            case 'bool':
            case 'boolean':
                var infoOptions = missingInfo.options;
                if (infoOptions instanceof Array && infoOptions.length > 0) {
                    infoOptions.forEach(function(infoOption) {
                        if (isValidObject(infoOption)) {
                            answersTags +=
                                '<label class="radio-inline">' +
                                '<input type="radio" name="' + controlName + '" ' +
                                'value="' + infoOption.value + '" ' +
                                (('value' in infoOption) && evalSuccessCondition(infoOption.value, " == " + missingInfo.user_answer) ? 'checked' : '') +
                                ' />' + infoOption.text +
                                '</label>';
                        }
                    });
                }
                break;
            case 'integer':
                answersTags += '<input type="number" class="form-control" id="' + controlName + '_number" label="false" name="' + controlName +
                    '"' + (isUserAnswerEmpty(missingInfo.user_answer) ? '' : (' value=' + missingInfo.user_answer)) +
                    (code === 'age' ? ' min="1900" max="' + new Date().getFullYear() + '" data-eligibility-code="age"' : '') +
                    ' />';
                break;
            case 'date':
                answersTags += '<input type="text" class="form-control" id="' + controlName + '_date" label="false" name="' + controlName + '" />' +
                    '<script type="text/javascript">' +
                    '$(function () {' +
                    '$("#' + controlName + '_date").datetimepicker({' +
                    'defaultDate: ' + (isNaN(parseDate(missingInfo.user_answer)) ? 'new Date()' : missingInfo.user_answer) + ',' +
                    'pickTime: false, ' +
		    "format: 'YYYY-MM-DD'" +
                    '});' +
                    '});' +
                    '</script>';
                break;
            case 'datetime':
                answersTags += '<input type="text" class="form-control" id="' + controlName + '_datetime" label="false" name="' + controlName + '" />' +
                    '<script type="text/javascript">' +
                    '$(function () {' +
                    '$("#' + controlName + '_datetime").datetimepicker({' +
                    'defaultDate: ' + (isNaN(parseDate(missingInfo.user_answer)) ? 'new Date()' : missingInfo.user_answer)
                '});' +
                    '});' +
                    '</script>';
                break;
            default:
                break;
        }

        return (
            '<div>' +
            '<label class="control-label"style="margin-right: 10px;">' + infoLongDesc + '</label>' +
            answersTags +
            '</div>'
        );
    }

    /**
     * check if no itineraries in any trip part; if so, render a message to alert user
     */
    function checkIfNoItineraries(trips) {
        if (!trips instanceof Array) {
            return;
        }

        trips.forEach(function(trip) {
            if (!isValidObject(trip)) {
                return;
            }
            var tripPlans = trip.itineraries;
            if (!trip.itineraries instanceof Array || tripPlans.length === 0) {
                var tripPartDivId = "trip_part_" + trip.id;
                var noItineraryTags = '<div class="col-xs-12 alert alert-danger trip-part-no-itinerary-alert">' + localeDictFinder['no_itineraries_found'] + '</div>';
                $('#' + tripPartDivId).append(noItineraryTags);
            }
        });
    }

    /**
     * Html of legends
     * @param {Array} trips
     */
    function addLegendHtml(trips) {
        if (!trips instanceof Array) {
            return;
        }

        var legendTags = "";
        var legendNameIndex = {};
        var legendNames = [];
        trips.forEach(function(trip) {
            if (typeof(trip) != 'object' || trip === null || !trip.itineraries instanceof Array) {
                return;
            }
            var tripPlans = trip.itineraries;
            tripPlans.forEach(function(tripPlan) {
                if (typeof(tripPlan) != 'object' || tripPlan === null || !tripPlan.legs instanceof Array) {
                    return;
                }
                var legs = tripPlan.legs;
                legs.forEach(function(leg) {
                    if (typeof(leg) != 'object' || leg === null || typeof(leg.type) != 'string') {
                        return;
                    }

                    var legType = leg.type.toLowerCase();
                    var className = "travel-legend-" + removeSpace(legType);
                    var legendText = (localeDictFinder[legType] || toCamelCase(legType));

                    if ($("." + className).length === 0 && !legendNameIndex[legendText]) {
                        legendNameIndex[legendText] = legendText;
                        legendNames.push({
                            cls: className,
                            name: legendText
                        });

                    }
                });
            });
        });

        legendNames = legendNames.sort(function(sortItem1, sortItem2) {
            if (sortItem1.name < sortItem2.name) return -1;
            if (sortItem1.name > sortItem2.name) return 1;
            return 0;
        });

        if (legendNames.length > 0) { //only show legend container when legend(s) are available
            if ($('#' + legendContainerId).length === 0) {
                var legendPanelTags =
                    "<div id='" + legendContainerId + "' class='panel panel-default col-xs-12 hidden-xs-sm' style='padding: 0px;'>" +
                    "<div class='panel-heading'><h2 class='panel-title legend-label' tabindex='9'>" + addReviewTooltip("legend_help")+ localeDictFinder['legend'] + "</h2></div>" +
                    "<div class='panel-body'></div>";
                $('#' + accessoryContainerId).append(legendPanelTags);
            }
            legendNames.forEach(function(el) {
                legendTags +=
                    "<div class='travel-legend-container'>" +
                    "<div class='travel-legend " + el.cls + "'/>" +
                    "<span class='travel-legend-text'>" + el.name + "</span>" +
                    "</div>";
            });
            $('#' + legendContainerId + ' .panel-body').append(legendTags);
        } else { //remove Show/Hide legend button
            $('#' + legendButtonId).remove();
        }
    }

    /*
     * Html of filters
     * @param {Array} trips
     */
    function addFilterHtml(trips) {
        if (!trips instanceof Array) {
            return;
        }

        var modes = [];
        var minTransfer = 0;
        var maxTransfer = 0;
        var minCost = -1;
        var maxCost = -1;
        var minDuration = -1;
        var maxDuration = -1;
        var minWalkDist = 0;
        var maxWalkDist = 0;
        var minWaitTime = 0;
        var maxWaitTime = 0;
        var minParatransitCount = 0;
        var maxParatransitCount = 0;

        trips.forEach(function(trip) {
            if (typeof(trip) != 'object' || trip === null || !trip.itineraries instanceof Array) {
                return;
            }
            var tripPlans = trip.itineraries;
            var tripPartParantransitCount = $.grep(tripPlans, function(plan) { return plan.mode === 'mode_paratransit';}).length;
            if(tripPartParantransitCount > maxParatransitCount) {
                maxParatransitCount = tripPartParantransitCount;
            }
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
                    var duration = parseFloat(durationInfo.sortable_duration);
                    if (duration >= 0) {
                        if (minDuration < 0 || duration < minDuration) {
                            minDuration = duration;
                        }

                        if (maxDuration < 0 || duration > maxDuration) {
                            maxDuration = duration;
                        }
                    }

                    //walking distance
                    var walkDist = parseInt(durationInfo.total_walk_dist);
                    if (walkDist >= 0) {
                        if (minWalkDist < 0 || walkDist < minWalkDist) {
                            minWalkDist = walkDist;
                        }

                        if (maxWalkDist < 0 || walkDist > maxWalkDist) {
                            maxWalkDist = walkDist;
                        }
                    }

                    //waiting time
                    var waitTime = parseFloat(durationInfo.total_wait_time);
                    if (waitTime >= 0) {
                        if (minWaitTime < 0 || waitTime < minWaitTime) {
                            minWaitTime = waitTime;
                        }

                        if (maxWaitTime < 0 || waitTime > maxWaitTime) {
                            maxWaitTime = waitTime;
                        }
                    }
                }

                //modes
                var modeName = tripPlan.mode_name;
                if (modes.indexOf(modeName) < 0) {
                    modes.push(modeName);
                }
            });
        });

        var filterAvailable = (modes.length > 0 ||
            (maxTransfer > minTransfer) ||
            (maxCost > minCost) ||
            (maxDuration > minDuration) ||
            (maxWalkDist > minWalkDist) ||
            (maxWaitTime > minWaitTime) ||
            (maxParatransitCount > minParatransitCount));

        if (filterAvailable) {
            if ($('#' + filterContainerId).length === 0) {
                $('#' + accessoryContainerId).append("<div id='" + filterContainerId + "' class='col-xs-12 hidden-xs-sm' style='padding: 0px;'></div>");
            }

            //render
            adjustModeFilters(modes);
            adjustTransferFilters(minTransfer, maxTransfer);
            adjustCostFilters(minCost, maxCost);
            adjustDurationFilters(minDuration, maxDuration);
            adjustWalkDistFilters(minWalkDist, maxWalkDist);
            adjustWaitTimeFilters(minWaitTime, maxWaitTime);
            adjustParatransitCountFilters(minParatransitCount, maxParatransitCount);

            // Add aria labels to slider handles for improved accessibility in JAWS
            addAriaToSliderHandle('#transferSlider', "Number of transfers slider. ", minTransfer, maxTransfer);
            addAriaToSliderHandle('#costSlider', "Fare slider. ", minCost, maxCost);
            addAriaToSliderHandle('#durationSlider', "Trip time slider. ", $('#durationSlider').attr('aria-valuemin'), $('#durationSlider').attr('aria-valuemax'));
            addAriaToSliderHandle('#walkDistSlider', "Walk distance slider. ", $('#walkDistSlider').attr('aria-valuemin'), $('#walkDistSlider').attr('aria-valuemax'));
            addAriaToSliderHandle('#waitTimeSlider', "Wait time slider. ", $('#waitTimeSlider').attr('aria-valuemin'), $('#waitTimeSlider').attr('aria-valuemax'));
            addAriaToSliderHandle('#paratransitSlider', "Paratransit count slider. ", $('#paratransitCountSlider').attr('aria-valuemin'), $('#paratransitCountSlider').attr('aria-valuemax'));

            //enable mode checkbox event
            $('#' + modeContainerId + ' .checkbox').on('change', function() {
                waitForFinalEvent(filterPlans, 100, 'mode change');
            });
        } else {
            $('#' + filterButtonId).remove();
        }
    }

    function addAriaToSliderHandle(slider_id, text, min, max) {
        if (slider_id === '#costSlider'){
            min = '$' + min;
            max = '$' + max;
        } else if (slider_id === '#durationSlider' || slider_id === '#waitTimeSlider') {
            min = min + " minutes";
            max = max + " minutes";
        } else if (slider_id === '#walkDistSlider') {
            min = min + " miles";
            max = max + " miles";
        }
        $(slider_id + ' > .ui-slider-handle:first').attr('aria-label', (text + min + " to " + max + "."));
    }

    /*
     * create html tags for mode filter
     * @param {Object}: modes
     * @return {string} modeFilterTags
     */
    function getModeFilterHtml(modes) {
        var isFirstMode = true;
        var modeFilterTags = '';
        modes.forEach(function(mode) {
            if (isFirstMode) {
                modeFilterTags +=
                    "<div class = 'col-sm-12 panel panel-default' style='padding: 0px;'>" +
                    "<div class = 'panel-heading'>" +
                    "<h2 class='panel-title modes-label' tabindex='10'>" + addReviewTooltip("modes_help") +  localeDictFinder['modes'] + "</h2>" +
                    "</div>" +
                    "<div class='panel-body' id='" + modeContainerId + "'>";
                isFirstMode = false;
            }
            modeFilterTags += getModeCheckboxHtml(mode);
        });

        if (!isFirstMode) {
            modeFilterTags +=
                '</div></div>';
        }

        return modeFilterTags;
    }

    /*
     * insert mode checkbox filter
     * @param {Object}: modes
     * @return {string} filterInnerContainerId
     */
    function adjustModeFilters(modes) {
        modes.sort();

        if ($('#' + modeContainerId).length === 0) {
            $('#' + filterContainerId).prepend(getModeFilterHtml(modes));
        } else {
            modes.forEach(function(mode) {
                if ($('#' + modeContainerId + ' :checkbox[value=' + modeId + ']').length === 0) {
                    $('#' + modeContainerId).append(getModeCheckboxHtml(mode));
                }
            });
        }
    }

    /*
     * get html checkbox tag for one mode
     * @param {string}: mode
     */
    function getModeCheckboxHtml(mode) {
        var modeTag =
            '<div class="checkbox" style="margin:0px 0px 0px 10px;">' +
            '<label>' +
            '<input type="checkbox" checked=true value="' + mode + '" tabindex="10">' +
            mode +
            '</label>' +
            '</div>';
        return modeTag;
    }

    /*
     * create html tags for transfer filter
     * @param {number}: minTransfer
     * @param {number}: maxTransfer
     */
    function getTransferFilterHtml(minTransfer, maxTransfer) {
        var tags = '';
        var sliderConfig = null;
        if (typeof(maxTransfer) === 'number' && minTransfer === 0 && maxTransfer > minTransfer) {
            tags =
                '<div class = "col-sm-12 panel panel-default" style="padding: 0px;">' +
                '<div class = "panel-heading">' +
                '<h2 class="panel-title num-transfers-label" tabindex="11">' + addReviewTooltip("number_of_transfers_help") + localeDictFinder['number_of_transfers'] + '</h2>' +
                '</div>' +
                '<div class="panel-body">' +
                '<div id="' + transferSliderId + '" aria-valuemin="' + minTransfer + '" aria-valuemax="' + maxTransfer + '">' +
                '</div>' +
                '<div class="col-sm-12">' +
                '<span id="' + transferSliderId + '_min_val_label" class="pull-left">' + minTransfer.toString() + '</span>' +
                '<span id="' + transferSliderId + '_max_val_label" class="pull-right">' + maxTransfer.toString() + '</span>' +
                '</div></div></div>';
            sliderConfig = {
                id: transferSliderId,
                value: maxTransfer,
                min: minTransfer,
                max: maxTransfer,
                step: 1,
                range: "min"
            };
        }

        return {
            tags: tags,
            sliderConfig: sliderConfig
        };
    }


    /*
     * adjust existing transfer filter slider
     */
    function adjustTransferFilters(minTransfer, maxTransfer) {
        var filterObj = getTransferFilterHtml(minTransfer, maxTransfer);
        if (isValidObject(filterObj)) {
            if ($('#' + transferSliderId).length === 0) {
                $('#' + filterContainerId).append(filterObj.tags);
            } else {
                $('#' + transferSliderId).attr('aria-valuemin', minTransfer);
                $('#' + transferSliderId).attr('aria-valuemax', maxTransfer);
                $('#' + transferSliderId + '_min_val_label').text(minTransfer);
                $('#' + transferSliderId + '_max_val_label').text(maxTransfer);
            }

            addSliderTooltip(filterObj.sliderConfig);
            $('#' + transferSliderId).slider('value',
                getDefaultMaxFilterValue(maxTransfer, filterConfigs.default_max_transfers)
            );
        }
    }

    /*
     * create html tags for parantransit_count filter
     * @param {number}: minParatransitCount
     * @param {number}: maxParatransitCount
     */
    function getParatransitCountFilterHtml(minParatransitCount, maxParatransitCount) {
        var tags = '';
        var sliderConfig = null;
        if (typeof(maxParatransitCount) === 'number' && minParatransitCount === 0 && maxParatransitCount > minParatransitCount) {
            tags =
                '<div class = "col-sm-12 panel panel-default" style="padding: 0px;">' +
                '<div class = "panel-heading">' +
                '<h2 class="panel-title num-paratransit-count-label" tabindex="11">' + addReviewTooltip("number_of_paratransit_count_help") + localeDictFinder['number_of_paratransit_count'] + '</h2>' +
                '</div>' +
                '<div class="panel-body">' +
                '<div id="' + paratransitCountSliderId + '" aria-valuemin="' + minParatransitCount + '" aria-valuemax="' + maxParatransitCount + '">' +
                '</div>' +
                '<div class="col-sm-12">' +
                '<span id="' + paratransitCountSliderId + '_min_val_label" class="pull-left">' + minParatransitCount.toString() + '</span>' +
                '<span id="' + paratransitCountSliderId + '_max_val_label" class="pull-right">' + maxParatransitCount.toString() + '</span>' +
                '</div></div></div>';
            sliderConfig = {
                id: paratransitCountSliderId,
                value: maxParatransitCount,
                min: minParatransitCount,
                max: maxParatransitCount,
                step: 1,
                range: "min"
            };
        }

        return {
            tags: tags,
            sliderConfig: sliderConfig
        };
    }


    /*
     * adjust existing paratransitCount filter slider
     */
    function adjustParatransitCountFilters(minParatransitCount, maxParatransitCount) {
        if(typeof(filterConfigs.default_max_paratransit_count) != 'number' || filterConfigs.default_max_paratransit_count <0 || maxParatransitCount <= filterConfigs.default_max_paratransit_count) {
            return;
        }

        var filterObj = getParatransitCountFilterHtml(minParatransitCount, maxParatransitCount);
        if (isValidObject(filterObj)) {
            if ($('#' + paratransitCountSliderId).length === 0) {
                $('#' + filterContainerId).append(filterObj.tags);
            } else {
                $('#' + paratransitCountSliderId).attr('aria-valuemin', minParatransitCount);
                $('#' + paratransitCountSliderId).attr('aria-valuemax', maxParatransitCount);
                $('#' + paratransitCountSliderId + '_min_val_label').text(minParatransitCount);
                $('#' + paratransitCountSliderId + '_max_val_label').text(maxParatransitCount);
            }

            addSliderTooltip(filterObj.sliderConfig);
            $('#' + paratransitCountSliderId).slider('value',
                getDefaultMaxFilterValue(maxParatransitCount, filterConfigs.default_max_paratransit_count)
            );
        }
    }

    /*
     * create html tags for cost filter
     * @param {number}: minCost
     * @param {number}: maxCost
     */
    function getCostFilterHtml(minCost, maxCost) {
        var tags = '';
        var sliderConfig = null;
        if (typeof(maxCost) === 'number' && typeof(minCost) === 'number' && maxCost > minCost) {
            minCost = getRoundMinValue(minCost);
            maxCost = getRoundMaxValue(maxCost);
            tags =
                '<div class = "col-sm-12 panel panel-default" style="padding: 0px;">' +
                '<div class = "panel-heading">' +
                '<h2 class="panel-title fare-label" tabindex="12">' + addReviewTooltip("fare_help") + localeDictFinder['fare'] + '</h2>' +
                '</div>' +
                '<div class="panel-body">' +
                '<div id="' + costSliderId + '" aria-valuemin="' + minCost + '" aria-valuemax="' + maxCost + '">' +
                '</div>' +
                '<div class="col-sm-12">' +
                '<span id="' + costSliderId + '_min_val_label" class="pull-left">$' + minCost.toString() + '</span>' +
                '<span id="' + costSliderId + '_max_val_label" class="pull-right">$' + maxCost.toString() + '</span>' +
                '</div></div></div>';
            sliderConfig = {
                id: costSliderId,
                value: maxCost,
                min: minCost,
                max: maxCost,
                step: 1,
                range: "min"
            };
        }

        return {
            tags: tags,
            sliderConfig: sliderConfig
        };
    }

    /*
     * adjust existing cost filter slider
     */
    function adjustCostFilters(minCost, maxCost) {
        var filterObj = getCostFilterHtml(minCost, maxCost);
        if (isValidObject(filterObj)) {
            if ($('#' + costSliderId).length === 0) {
                $('#' + filterContainerId).append(filterObj.tags);
            } else {
                minCost = getRoundMinValue(minCost);
                maxCost = getRoundMaxValue(maxCost);
                $('#' + costSliderId).attr('aria-valuemin', minCost);
                $('#' + costSliderId).attr('aria-valuemax', maxCost);
                $('#' + costSliderId + '_min_val_label').text('$' + minCost);
                $('#' + costSliderId + '_max_val_label').text('$' + maxCost);
            }

            addSliderTooltip(filterObj.sliderConfig);
            $('#' + costSliderId).slider('value', 
                getDefaultMaxFilterValue(maxCost, filterConfigs.default_max_fare)
            );
        }
    }

    /*
     * create html tags for durtion filter
     * @param {number}: minDuration
     * @param {number}: maxDuration
     */
    function getDurationFilterHtml(minDuration, maxDuration) {
        var tags = '';
        var sliderConfig = null;
        if (typeof(maxDuration) === 'number' && typeof(minDuration) === 'number' && maxDuration > minDuration) {
            minDuration = getRoundMinValue(minDuration / 60);
            maxDuration = getRoundMaxValue(maxDuration / 60);
            tags =
                '<div class = "col-sm-12 panel panel-default" style="padding: 0px;">' +
                '<div class = "panel-heading">' +
                '<h2 class="panel-title trip-time-label" tabindex="13">' + addReviewTooltip("trip_time_help") + localeDictFinder['trip_time'] + '</h2>' +
                '</div>' +
                '<div class="panel-body">' +
                '<div id="' + durationSliderId + '" aria-valuemin="' + minDuration + '" aria-valuemax="' + maxDuration + '">' +
                '</div>' +
                '<div class="col-sm-12">' +
                '<span id="' + durationSliderId + '_min_val_label" class="pull-left">' + minDuration.toString() + localeDictFinder['minute_abbr'] + '</span>' +
                '<span id="' + durationSliderId + '_max_val_label" class="pull-right">' + maxDuration.toString() + localeDictFinder['minute_abbr'] + '</span>' +
                '</div></div></div>';
            sliderConfig = {
                id: durationSliderId,
                values: maxDuration,
                min: minDuration,
                max: maxDuration,
                step: 1,
                range: "min"
            };
        }

        return {
            tags: tags,
            sliderConfig: sliderConfig
        };
    }

    /*
     * adjust existing duration filter slider
     */
    function adjustDurationFilters(minDuration, maxDuration) {
        var filterObj = getDurationFilterHtml(minDuration, maxDuration);
        if (isValidObject(filterObj)) {
            minDuration = getRoundMinValue(minDuration / 60);
            maxDuration = getRoundMaxValue(maxDuration / 60);

            if ($('#' + durationSliderId).length === 0) {
                $('#' + filterContainerId).append(filterObj.tags);
            } else {
                $('#' + durationSliderId).attr('aria-valuemin', minDuration);
                $('#' + durationSliderId).attr('aria-valuemax', maxDuration);
                $('#' + durationSliderId + '_min_val_label').text(minDuration + localeDictFinder['minute_abbr'] );
                $('#' + durationSliderId + '_max_val_label').text(maxDuration + localeDictFinder['minute_abbr'] );
            }

            addSliderTooltip(filterObj.sliderConfig);
            $('#' + durationSliderId).slider('value',
                getDefaultMaxFilterValue(maxDuration, filterConfigs.default_max_duration)
            );
        }
    }

    /*
     * create html tags for waiting time filter
     * @param {number}: minWaitTime
     * @param {number}: maxWaitTime
     */
    function getWaitTimeFilterHtml(minWaitTime, maxWaitTime) {
        var tags = '';
        var sliderConfig = null;
        if (typeof(maxWaitTime) === 'number' && typeof(minWaitTime) === 'number' && maxWaitTime > minWaitTime) {
            minWaitTime = getRoundMinValue(minWaitTime / 60);
            maxWaitTime = getRoundMaxValue(maxWaitTime / 60);
            tags =
                '<div class = "col-sm-12 panel panel-default" style="padding: 0px;">' +
                '<div class = "panel-heading">' +
                '<h2 class="panel-title trip-time-label" tabindex="13">' + addReviewTooltip("wait_time_help") + localeDictFinder['wait_time'] + '</h2>' +
                '</div>' +
                '<div class="panel-body">' +
                '<div id="' + waitTimeSliderId + '" aria-valuemin="' + minWaitTime + '" aria-valuemax="' + maxWaitTime + '">' +
                '</div>' +
                '<div class="col-sm-12">' +
                '<span id="' + waitTimeSliderId + '_min_val_label" class="pull-left">' + minWaitTime.toString() + localeDictFinder['minute_abbr'] + '</span>' +
                '<span id="' + waitTimeSliderId + '_max_val_label" class="pull-right">' + maxWaitTime.toString() + localeDictFinder['minute_abbr'] + '</span>' +
                '</div></div></div>';
            sliderConfig = {
                id: waitTimeSliderId,
                values: maxWaitTime,
                min: minWaitTime,
                max: maxWaitTime,
                step: 1,
                range: "min"
            };
        }

        return {
            tags: tags,
            sliderConfig: sliderConfig
        };
    }

    /*
     * adjust existing waiting time filter slider
     */
    function adjustWaitTimeFilters(minWaitTime, maxWaitTime) {
        var filterObj = getWaitTimeFilterHtml(minWaitTime, maxWaitTime);
        if (isValidObject(filterObj)) {
            minWaitTime = getRoundMinValue(minWaitTime / 60);
            maxWaitTime = getRoundMaxValue(maxWaitTime / 60);

            if ($('#' + waitTimeSliderId).length === 0) {
                $('#' + filterContainerId).append(filterObj.tags);
            } else {
                $('#' + waitTimeSliderId).attr('aria-valuemin', minWaitTime);
                $('#' + waitTimeSliderId).attr('aria-valuemax', maxWaitTime);
                $('#' + waitTimeSliderId + '_min_val_label').text(minWaitTime + localeDictFinder['minute_abbr'] );
                $('#' + waitTimeSliderId + '_max_val_label').text(maxWaitTime + localeDictFinder['minute_abbr'] );
            }

            addSliderTooltip(filterObj.sliderConfig);

            var slider_max = maxWaitTime;
            var default_max = filterConfigs.default_max_wait_time;
            if(typeof(default_max) === 'number' && default_max >= minWaitTime && default_max <= slider_max) {
                slider_max = default_max;
            }

            $('#' + waitTimeSliderId).slider('value',
                getDefaultMaxFilterValue(maxWaitTime, slider_max)
            );
        }
    }

     /*
     * create html tags for walk distance filter
     * @param {number}: minWalkDist
     * @param {number}: maxWalkDist
     */
    function getWalkDistFilterHtml(minWalkDist, maxWalkDist) {
        var tags = '';
        var sliderConfig = null;
        if (typeof(maxWalkDist) === 'number' && typeof(minWalkDist) === 'number' && maxWalkDist > minWalkDist) {
            minWalkDist = Math.round(minWalkDist * METERS_TO_MILES * 100 - 0.5) / 100;
            maxWalkDist = Math.round(maxWalkDist * METERS_TO_MILES * 100 + 0.5) / 100;
            tags =
                '<div class = "col-sm-12 panel panel-default" style="padding: 0px;">' +
                '<div class = "panel-heading">' +
                '<h2 class="panel-title walk-dist-label" tabindex="14">' + addReviewTooltip("walk_dist_help") + localeDictFinder['walk_dist'] + '</h2>' +
                '</div>' +
                '<div class="panel-body">' +
                '<div id="' + walkDistSliderId + '" aria-valuemin="' + minWalkDist + '" aria-valuemax="' + maxWalkDist + '">' +
                '</div>' +
                '<div class="col-sm-12">' +
                '<span id="' + walkDistSliderId + '_min_val_label" class="pull-left">' + minWalkDist.toString() + localeDictFinder['miles'] + '</span>' +
                '<span id="' + walkDistSliderId + '_max_val_label" class="pull-right">' + maxWalkDist.toString() + localeDictFinder['miles'] + '</span>' +
                '</div></div></div>';
            sliderConfig = {
                id: walkDistSliderId,
                values: maxWalkDist,
                min: minWalkDist,
                max: maxWalkDist,
                step: 0.01,
                range: "min"
            };
        }

        return {
            tags: tags,
            sliderConfig: sliderConfig
        };
    }

    /*
     * adjust existing walk_distance filter slider
     */
    function adjustWalkDistFilters(minWalkDist, maxWalkDist) {
        var filterObj = getWalkDistFilterHtml(minWalkDist, maxWalkDist);
        if (isValidObject(filterObj)) {
            minWalkDist = Math.round(minWalkDist * METERS_TO_MILES * 100 - 0.5) / 100;
            maxWalkDist = Math.round(maxWalkDist * METERS_TO_MILES * 100 + 0.5) / 100;

            if ($('#' + walkDistSliderId).length === 0) {
                $('#' + filterContainerId).append(filterObj.tags);
            } else {
                $('#' + walkDistSliderId).attr('aria-valuemin', minWalkDist);
                $('#' + walkDistSliderId).attr('aria-valuemax', maxWalkDist);
                $('#' + walkDistSliderId + '_min_val_label').text(minWalkDist + localeDictFinder['miles'] );
                $('#' + walkDistSliderId + '_max_val_label').text(maxWalkDist + localeDictFinder['miles'] );
            }

            addSliderTooltip(filterObj.sliderConfig);

            var slider_max = maxWalkDist;
            var default_max = filterConfigs.default_max_walk_dist;
            if(typeof(default_max) === 'number' && default_max >= minWalkDist && default_max <= slider_max) {
                slider_max = default_max;
            }

            $('#' + walkDistSliderId).slider('value',
                getDefaultMaxFilterValue(maxWalkDist, slider_max)
            );
        }
    }


    // Note: actualMin is parseInt & min_round-ed
    function getDefaultMinFilterValue(actualMin, configMin) {
        var min = getRoundMinValue(actualMin);
        if(typeof(configMin) === 'number' && configMin > actualMin) {
            min = configMin;
        }

        return min;
    }

    // Note: actualMax is parseInt & max_round-ed
    function getDefaultMaxFilterValue(actualMax, configMax) {
        var max = getRoundMaxValue(actualMax);
        if(typeof(configMax) === 'number' && configMax < actualMax) {
            max = configMax;
        }

        return max;
    }

    /*
     * add tooltip for each slider
     * @param {Object} slider
     */
    function addSliderTooltip(slider) {
        if (typeof(slider) != 'object' || slider === null) {
            return;
        }

        var sliderId = "#" + slider.id;
        $(sliderId).slider(slider);

        $(sliderId).on('slidechange', function(event, ui) {
            var minVal = ui.value;
            // var maxVal = ui.values[1];
            $(sliderId + ' .ui-slider-handle:first').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + minVal + '</div></div>');
            // $(sliderId + ' .ui-slider-handle:last').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + maxVal + '</div></div>');

            waitForFinalEvent(filterPlans, 100, slider.Id + ' sliding');
        });

        $(sliderId + " .ui-slider-handle").mouseleave(function() {
            $(sliderId + ' .ui-slider-handle').empty();
        });
        $(sliderId + " .ui-slider-handle").mouseenter(function() {
            var values = $(sliderId).slider("option", "value");
            var minVal = values;
            // var maxVal = values[1];
            $(sliderId + ' .ui-slider-handle:first').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + minVal + '</div></div>');
            // $(sliderId + ' .ui-slider-handle:last').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + maxVal + '</div></div>');
        });

    }

    /*
     * given time range, create tick labels
     * @param {Date} tripStartTime
     * @param {Date} tripEndTime
     * @param {number} intervalStep
     * @return {Array} tickLabels
     */
    function getTickLabels(tripStartTime, tripEndTime, intervalStep) {
        var tickLabels = [];
        var labelFormat = d3.time.format('%_I:%M %p');
        var ticks = d3.time.scale()
            .domain([tripStartTime, tripEndTime])
            .nice(d3.time.minute, intervalStep)
            .ticks(d3.time.minute, intervalStep)
            .forEach(function(tick) {
                tickLabels.push(labelFormat(tick));
            });

        return tickLabels;
    }

    function formatTime(toFormatTime) {
        return d3.time.format('%_I:%M %p')(toFormatTime);
    }

    function getHoverTipText(tripPlan, isTextOnly) {
        var tipText = '';
        if (!isValidObject(tripPlan)) {
            return tipText;
        }

        var lineWrapStartSymbol = '<p>';
        var lineWrapEndSymbol = '</p>';
        var tipToShowDetailsDialog = localeDictFinder['press_space_or_dblclick_for_details'];
        if(isTextOnly) {
            lineWrapStartSymbol = '';
            lineWrapEndSymbol = '';
            tipToShowDetailsDialog = localeDictFinder['press_space_for_details'];
        }

        var lineWrapper = function(rawLine) {
            return lineWrapStartSymbol + rawLine + lineWrapEndSymbol;
        }

        var mode = tripPlan.mode;
        var modeName = tripPlan.mode_name;
        var serviceName = tripPlan.service_name;
        var durationText = isValidObject(tripPlan.duration) ? tripPlan.duration.duration_in_words : localeDictFinder['unknown'];

        switch (mode) {
            case 'mode_transit':
                tipText = lineWrapper(localeDictFinder['depart_at'] + ' ' + formatTime(parseDate(tripPlan.start_time))) +
                    (tripPlan.legs.length > 0 ? (lineWrapper(tripPlan.legs[0].description)) : '') +
                    (tripPlan.legs.length > 1 ? (lineWrapper(tripPlan.legs[1].description)) : '') +
                    lineWrapper(localeDictFinder['arrive_in'] + ' ' + durationText);
                break;
            case 'mode_bicycle':
                tipText = lineWrapper(localeDictFinder['bicycle'] + ' ' + durationText);
                break;
            case 'mode_bikeshare':
                tipText = (tripPlan.legs.length > 0 ? (lineWrapper(tripPlan.legs[0].description)) : '') +
                    lineWrapper(localeDictFinder['arrive_in'] + ' ' + durationText);
                break;
            case 'mode_drive':
            case 'mode_car':
                tipText = lineWrapper(localeDictFinder['drive'] + ' ' + durationText);
                break;
            case 'mode_walk':
                tipText = localeDictFinder['walk'] + ' ' + durationText;
                if (isValidObject(tripPlan.duration) && typeof(tripPlan.duration.total_walk_dist) === 'number') {
                    tipText += ' (' + (tripPlan.duration.total_walk_dist * METERS_TO_MILES).toFixed(2) + ' ' + localeDictFinder['miles'].toLowerCase() + ')';
                }

                tipText = lineWrapper(tipText);
                break;
            default:
                tipText = lineWrapper((serviceName || modeName));
                break;
        }

        tipText += lineWrapper(tipToShowDetailsDialog);
        return tipText;
    }

    function getLegTypeFromPlanMode(mode) {
        //if mode starts with 'mode_', then leg type is the text after 'mode_'
        return typeof(mode) != 'string' ? '' : (mode.indexOf('mode_') >= 0 ? mode.substr(mode.indexOf('mode_') + 5) : mode);
    }

    // get bar height value in chart based on leg type
    function getBarHeight(legType) {
        if(legType === 'wait') {
            return 4;
        } else {
            return barHeight;
        }
    }

    /**
     * render paratransit lines (the rect is handled in regular chart rendering)
     * @param {Array} paratransitLegs
     * @param {DOM object} chart: d3 selector 
     * @param {object} x: x-axis scalor
     * @param {number} divHeight: the total height of bar container
     * @param {number} barHeight
     */
    function renderParatransitLines(paratransitLegs, chart, x, divHeight, barHeight) {
        // center line across start_time to end_time
        chart.selectAll(".paratransit-center-line")
            .data(paratransitLegs)
            .enter()
            .append("line")
            .attr("class", "paratransit-center-line")
            .attr("start_time", function(d) {
                return parseDate(d.start_time);
            })
            .attr("end_time", function(d) {
                return parseDate(d.end_time);
            })
            .attr("x1", function(d) {
                return x(parseDate(d.start_time));
            })
            .attr("y1", function(d) {
                return divHeight/2;
            })
            .attr("x2", function(d) {
                return x(parseDate(d.end_time));
            })
            .attr("y2", function(d) {
                return divHeight/2;
            });

        // boundary vertical lines at start_time and end_time
        var paratransitLegBoundaries = [];
        paratransitLegs.forEach(function(leg){
            paratransitLegBoundaries.push({
                time: leg.start_time
            });
            paratransitLegBoundaries.push({
                time: leg.end_time
            });
        });
        chart.selectAll(".paratransit-boundary-line")
            .data(paratransitLegBoundaries)
            .enter()
            .append("line")
            .attr("class", "paratransit-boundary-line")
            .attr("time", function(d) {
                return parseDate(d.time);
            })
            .attr("x1", function(d) {
                return x(parseDate(d.time));
            })
            .attr("y1", function(d) {
                return (divHeight-barHeight)/2;
            })
            .attr("x2", function(d) {
                return x(parseDate(d.time));
            })
            .attr("y2", function(d) {
                return (divHeight+barHeight)/2;
            });
    }

    /**
     * Create a timeline chart
     * @param {string} chartDivId
     * @param {Date} tripStartTime
     * @param {Date} tripEndTime
     * @param {object} tripPlan
     */
    function createChart(chartDivId, tripStartTime, tripEndTime, tripPlan) {
        if (!isValidObject(tripPlan)) {
            return;
        }

        var tripLegs = tripPlan.legs || [];
        //planId, chartDivId, tripLegs, tripStartTime, tripEndTime, intervalStep, barHeight, serviceName
        if (!tripStartTime instanceof Date || !tripEndTime instanceof Date || !tripLegs instanceof Array || typeof(intervalStep) != 'number' || typeof(barHeight) != 'number') {
            return;
        }

        var planId = tripPlan.id;
        var serviceName = tripPlan.service_name;

        var $chart = $('#' + chartDivId);
        if ($chart.length === 0) { //this chart div doesnt exist
            return;
        }

        var width = $chart.width();
        var height = $chart.height();
        var chart = d3.select('#' + chartDivId)
            .append('svg')
            .attr('class', 'chart')
            .attr('role', 'chart')
            .attr('width', width)
            .attr('height', height);

        //create d3 time scale
        var xScale = d3.time.scale()
            .domain([tripStartTime, tripEndTime])
            .nice(d3.time.minute, intervalStep);
        var x = xScale
            .range([0, width]);

        var y = d3.scale.linear()
            .domain([0, 2])
            .range([0, height]);

        //generate ticks
        drawChartTickLines(chart, xScale, x);

        //draw paratransit line
        var paratransitLegs = $.grep(tripLegs, function(leg) { return leg.type.toLowerCase() === 'paratransit';});
        if(paratransitLegs.length > 0) {
            renderParatransitLines(paratransitLegs, chart, x, height, barHeight);
        }
        
        //draw trip legs in rectangles
        chart.selectAll("rect")
            .data(tripLegs)
            .enter().append("rect")
            .attr('class', function(d) {
                return "travel-type-" + d.type.toLowerCase();
            })
            .attr("x", function(d) {
                var tmpX =  d.start_time_estimated ? 0 : x(parseDate(d.start_time));
                if(d.type.toLowerCase() === 'paratransit') {
                    var tmpWidth = (d.end_time_estimated ? width : x(parseDate(d.end_time))) - (d.start_time_estimated ? 0 : x(parseDate(d.start_time)));
                    return tmpX + tmpWidth/4;
                } else {
                    return tmpX;
                }
            })
            .attr("y", function(d) {
                return (y(1) - getBarHeight(d.type.toLowerCase()) / 2);
            })
            .attr("width", function(d) {
                var tmpWidth = (d.end_time_estimated ? width : x(parseDate(d.end_time))) - (d.start_time_estimated ? 0 : x(parseDate(d.start_time)));
                if(d.type.toLowerCase() === 'paratransit') {
                    return tmpWidth/2;
                } else {
                    return tmpWidth;
                }    
            })
            .attr("height", function(d) {
                return getBarHeight(d.type.toLowerCase());
            });


        // add service name
        // except for transit
        if (['mode_paratransit', 'mode_rideshare'].indexOf(tripPlan.mode) >= 0 && tripLegs.length > 0 && typeof(serviceName) === 'string' && serviceName.trim().length > 0) {
            chart.selectAll(".itinerary-chart-service-name")
                .data([serviceName])
                .enter()
                .append("text")
                .attr('class', 'itinerary-chart-service-name')
                .attr("x", (
                    x(parseDate(tripPlan.start_time)) +
                    x(parseDate(tripPlan.end_time))
                ) / 2)
                .attr("y", barHeight)
                .attr("dy", '0.5ex')
                .text(function(d) {
                    return d;
                });
        } else {
            // add mode icons
            chart.selectAll(".mode-icons")
                .data(tripLegs)
                .enter().append("image")
                .attr("class", "mode-icons")
                .attr("xlink:href", function(d){
                    return d.logo_url
                })
                .attr("x", function(d){
                    return (x(parseDate(d.start_time)) + x(parseDate(d.end_time)))/2 - barHeight / 2;
                })
                .attr("y", (height-barHeight)/2)
                .attr("width", function(d) {
                    if (d.type.toLowerCase() === 'paratransit' || (x(parseDate(d.end_time)) - x(parseDate(d.start_time))) < barHeight)
                        return 0;
                    else
                        return barHeight;
                })
                .attr("height", barHeight);
        }

        // add tooltips to rect, make sure text doesn't disrupt hover action
        appendItineraryTooltip(chart, planId, tripPlan);
        $('.itinerary-chart-service-name').css('pointer-events', 'none');
        $('.mode-icons').css('pointer-events', 'none');
    }

    /*
     * ajax request to get itinerary details modal dialog (rendered in back-end)
     * @param {number} planId
     */
    function showItineraryModal(planId) {
        $.getScript(window.location.href + '/itinerary' + '?itin=' + planId)
            .done(function() {})
            .fail(function(jqxhr, settings, exception) {
                //console.log(jqxhr);
                //console.log(settings);
                //console.log(exception);
                show_alert(localeDictFinder['something_went_wrong']);
            });
    }

    /*
     * pass an plan object, then resize its chart based on plan attributes
     * @param {object} plan
     */
    function resizeChartViaPlan(plan) {
        if (typeof(plan) != 'object' || plan === null) {
            return;
        }

        var tmpTripStartTime = parseDate(plan.attr('data-trip-start-time'));
        var tmpTripEndTime = parseDate(plan.attr('data-trip-end-time'));
        var tmpPlanStartTime = parseDate(plan.attr('data-start-time'));
        var tmpPlanEndTime = parseDate(plan.attr('data-end-time'));
        var tmpChartDivId = $(plan).find('.single-plan-chart-container').attr('id');
        resizeChart(tmpChartDivId, tmpTripStartTime, tmpTripEndTime, tmpPlanStartTime, tmpPlanEndTime, intervalStep, barHeight);
    }

    /*
     * resize all charts via plans
     */
    function resizeAllCharts() {
        $('.single-plan-review').each(function() {
            resizeChartViaPlan($(this));
        });
    }

    /*
     * resize all charts when document width change is detected
     */
    function resizeChartsWhenDocumentWidthChanges() {
        if ($(document.body).width() != documentWidth) {
            resizePlanColumns();
            resizeAllCharts();
            documentWidth = $(document.body).width();
        }
    }

    /*
     * draw chart tick lines
     * @param {Object}chart: d3 chart
     * @param {Object}xScale: d3 x axis scale
     * @param {Function}x : x-axis mapping function to calculate chart x-axis tick position based on input raw value
     */
    function drawChartTickLines(chart, xScale, x) {
        //generate ticks
        var ticks = xScale
            .ticks(d3.time.minute, intervalStep);

        //draw tick lines without first and last (this is styled by border)
        if (ticks.length > 0) {
            ticks.splice(0, 1);

            if (ticks.length > 0) {
                ticks.splice(ticks.length - 1, 1);
            }
        }

        chart.selectAll(".tick-line")
            .data(ticks)
            .enter()
            .insert("line", "rect")
            .attr("class", "tick-line")
            .attr("x1", function(d) {
                return x(d);
            })
            .attr("x2", function(d) {
                return x(d);
            })
            .attr("y1", 0)
            .attr("y2", chart.attr('height'));
    }

    function resizePlanColumns() {
        var planWidth = $('.single-plan-review').outerWidth();
        if (planWidth > 0) {
            var extraWidthForLastColumn = 10; //px; first column width will be width of the select button + extra_width
            var minMainColumnWidthPct = 50; //percentage;
            var minFirstColumnWidth = 50; //px; min width of first column

            var firstColumnWidth = Math.max.apply(null, $('.trip-plan-first-column table').map(function() {
                return $(this).outerWidth(true);
            }).get());

            var selectButtonWidth = $('.single-plan-review .single-plan-select').outerWidth();
            var questionButtonWidth = $('.single-plan-review .single-plan-question').outerWidth();
            var lastColumnWidth = (Math.max(selectButtonWidth, questionButtonWidth) + extraWidthForLastColumn);

            var mainColumnWidth = planWidth - firstColumnWidth - lastColumnWidth;

            var firstColumnWidthPct = firstColumnWidth / planWidth * 100;
            var lastColumnWidthPct = lastColumnWidth / planWidth * 100;
            var mainColumnWidthPct = mainColumnWidth / planWidth * 100;

            if (mainColumnWidthPct < minMainColumnWidthPct) {
                firstColumnWidthPct -= (minMainColumnWidthPct - mainColumnWidthPct) / 2;
                lastColumnWidthPct -= (minMainColumnWidthPct - mainColumnWidthPct) / 2;
                mainColumnWidthPct = minMainColumnWidthPct;
            }
            if ($(document.body).width() > documentWidth) {
                $('.trip-plan-first-column').css('width', firstColumnWidthPct + '%');
                $('.select-column').css('width', lastColumnWidthPct + '%');
                $('.trip-plan-main-column').css('width', mainColumnWidthPct + '%');
            } else {
                $('.trip-plan-main-column').css('width', mainColumnWidthPct + '%');
                $('.trip-plan-first-column').css('width', firstColumnWidthPct + '%');
                $('.select-column').css('width', lastColumnWidthPct + '%');
            }
        }
    }

    /**
     * Create a timeline chart
     * @param {string} chartDivId
     * @param {Date} tripStartTime
     * @param {Date} tripEndTime
     * @param {Date} planStartTime
     * @param {Date} planEndTime
     * @param {number} intervalStep
     * @param {number} barHeight
     */
    function resizeChart(chartDivId, tripStartTime, tripEndTime, planStartTime, planEndTime, intervalStep, barHeight) {
        if (!tripStartTime instanceof Date || !tripEndTime instanceof Date ||
            typeof(intervalStep) != 'number' || typeof(barHeight) != 'number') { //type check
            return;
        }
        var $chart = $('#' + chartDivId);
        if ($chart.length === 0) { //this chart div doesnt exist
            return;
        }

        var width = $chart.width();
        var height = $chart.height();
        var svgSelector = '#' + chartDivId + ">svg";
        var chart = d3.select(svgSelector)
            .attr('width', width);

        //create d3 time scale
        var xScale = d3.time.scale()
            .domain([tripStartTime, tripEndTime])
            .nice(d3.time.minute, intervalStep);
        var x = xScale
            .range([0, width]);

        var y = d3.scale.linear()
            .domain([0, 2])
            .range([0, height]);

        //redraw tick lines
        chart.selectAll('.tick-line').remove();
        drawChartTickLines(chart, xScale, x);

        //redraw paratransit lines
        chart.selectAll(".paratransit-center-line")
                .attr("x1", function(d) {
                    return x(parseDate($(this).attr('start_time')));
                })
                .attr("y1", function(d) {
                    return height/2;
                })
                .attr("x2", function(d) {
                    return x(parseDate($(this).attr('end_time')));
                })
                .attr("y2", function(d) {
                    return height/2;
                });

        //redraw paratransit lines
        chart.selectAll(".paratransit-boundary-line")
                .attr("x1", function(d) {
                    return x(parseDate($(this).attr('time')));
                })
                .attr("y1", function(d) {
                    return (height-barHeight)/2;
                })
                .attr("x2", function(d) {
                    return x(parseDate($(this).attr('time')));
                })
                .attr("y2", function(d) {
                    return (height+barHeight)/2;;
                });

        //update chart items
        chart.selectAll("rect")
            .attr("x", function(d) {
                var tmpX =  d.start_time_estimated ? 0 : x(parseDate(d.start_time));
                if(d.type.toLowerCase() === 'paratransit') {
                    var tmpWidth = (d.end_time_estimated ? width : x(parseDate(d.end_time))) - (d.start_time_estimated ? 0 : x(parseDate(d.start_time)));
                    return tmpX + tmpWidth/4;
                } else {
                    return tmpX;
                }
            })
            .attr("y", function(d){
                return (y(1) - getBarHeight(d.type.toLowerCase()) / 2);
            })
            .attr("width", function(d) {
                var tmpWidth = (d.end_time_estimated ? width : x(parseDate(d.end_time))) - (d.start_time_estimated ? 0 : x(parseDate(d.start_time)));
                if(d.type.toLowerCase() === 'paratransit') {
                    return tmpWidth/2;
                } else {
                    return tmpWidth;
                }
            })
            .attr("height", function(d){
                return getBarHeight(d.type.toLowerCase());
            });


        // update mode icons
        chart.selectAll(".mode-icons")
            .attr("x", function(d){
                return (x(parseDate(d.start_time)) + x(parseDate(d.end_time)))/2 - barHeight /2;
            })
            .attr("y", (height-barHeight)/2)
            .attr("width", function(d) {
                if (d.type.toLowerCase() === 'paratransit' || (x(parseDate(d.end_time)) - x(parseDate(d.start_time))) < barHeight)
                    return 0;
                else
                    return barHeight;
            })
            .attr("height", barHeight);

        // update labels
        chart.selectAll("itinerary-chart-service-name")
            .attr("x", (
                    x(planStartTime) +
                    x(planEndTime)
                ) / 2)
            .attr("y", barHeight)
    }

    /*
     * main filtering function that handles modes, transfer, cost, and duration
     */
    function filterPlans() {
        var modes = [];
        var modeCheckboxs = $('#' + modeContainerId + ' .checkbox :checked');
        for (var i = 0, modeCount = modeCheckboxs.length; i < modeCount; i++) {
            var modeCheckbox = modeCheckboxs[i];
            var modeVal = modeCheckbox.attributes['value'].value;

            modes.push(modeVal);
        }

        var transferValues = $('#' + transferSliderId).slider("option", "value");


        var costValues = $('#' + costSliderId).slider("option", "value");


        var durationValues = $('#' + durationSliderId).slider("option", "value");

        var walkDistValues = $('#' + walkDistSliderId).slider("option", "value");

        var waitTimeValues = $('#' + waitTimeSliderId).slider("option", "value");

        var paratransitCountValues = $('#' + paratransitCountSliderId).slider("option", "value");


        $('.single-plan-review').each(function() {
            var plan = $(this);
            processPlanFiltering(modes, transferValues, costValues, durationValues, walkDistValues, waitTimeValues, paratransitCountValues, plan);
            detectPlanVisibilityChange(plan);
        });

        // update chart if datetime range of visible plans has changed
        updateChartsIfDatetimeRangeChanged();
        setMidTripAriaLabel();
    }

    function updateChartsIfDatetimeRangeChanged() {
        $('.single-trip-part').each(function(){
            var tripPartDivId = $(this).attr('id');
            
            var prevStartTime = null;
            var prevEndTime = null;
            var currentStartTime = null;
            var currentEndTime = null;
            $('#' + tripPartDivId + ' .single-plan-review[data-filter-visible=1][data-eligibility-visible=1]').each(function(){
                var plan = $(this);

                if(!prevStartTime) {
                    prevStartTime = parseDate(plan.attr('data-trip-start-time'));
                }
                if(!prevEndTime) {
                    prevEndTime = parseDate(plan.attr('data-trip-end-time'));
                }

                var tmpPlanStartTime = parseDate(plan.attr('data-start-time'));
                if(tmpPlanStartTime && (!currentStartTime || currentStartTime > tmpPlanStartTime)) {
                    currentStartTime = tmpPlanStartTime;
                }
                var tmpPlanEndTime = parseDate(plan.attr('data-end-time'));
                if(tmpPlanEndTime && (!currentEndTime || currentEndTime < tmpPlanEndTime)) {
                    currentEndTime = tmpPlanEndTime;
                }
            });   

            if(
                (prevStartTime && currentStartTime && currentStartTime != prevStartTime) ||
                (prevEndTime && currentEndTime && currentEndTime != prevEndTime)) {
                var tickLabels = getTickLabels(currentStartTime, currentEndTime, intervalStep);
                var tickLabelTags = getTickLabelHtmlTags(tickLabels);
                $('#' + tripPartDivId + " .tick-labels").html(tickLabelTags);

                // update all plan's attributes
                $('#' + tripPartDivId + ' .single-plan-review').each(function(){
                    var plan = $(this);
                    plan.attr('data-trip-start-time', currentStartTime.toISOString());
                    plan.attr('data-trip-end-time', currentEndTime.toISOString());
                    if (plan.attr('data-eligibility-visible') == '1' && plan.attr('data-filter-visible') == '1') {
                        resizeChartViaPlan(plan);
                    }
                });
            }
        });
    }

    /*
     * given all filter values, check if a given plan is visible or not
     * @param {Array} modes
     * @param {number} transferValue
     * @param {number} costValue
     * @param {number} durationValue
     * @param {number} walkDistValue
     * @param {number} waitTimeValue
     * @param {number} paratransitCountValue
     * @param {Object} plan
     */
    function processPlanFiltering(modes, transferValue, costValue, durationValue, walkDistValue, waitTimeValue, paratransitCountValue, plan) {
        var modeVisible = true;
        if (modes instanceof Array) {
            modeVisible = filterPlansByMode(modes, plan);
        }

        if (!modeVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

        var transferVisible = true;
        if (typeof transferValue == 'number') {
            transferVisible = filterPlansByTransfer(transferValue, plan);
        }

        if (!transferVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

        var costVisible = true;
        if (typeof costValue == 'number') {
            costVisible = filterPlansByCost(costValue, plan);
        }

        if (!costVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

        var durationVisible = true;
        if (typeof durationValue == 'number') {
            durationVisible = filterPlansByDuration(durationValue, plan);
        }

        if (!durationVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

         var walkDistVisible = true;
        if (typeof walkDistValue == 'number') {
            walkDistVisible = filterPlansByWalkDist(walkDistValue, plan);
        }

        if (!walkDistVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

        var waitTimeVisible = true;
        if (typeof waitTimeValue == 'number') {
            waitTimeVisible = filterPlansByWaitTime(waitTimeValue, plan);
        }

        if (!waitTimeVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

        var paratransitCountVisible = true;
        if (typeof paratransitCountValue == 'number') {
            paratransitCountVisible = filterPlansByParatransitCount(paratransitCountValue, plan);
        }

        if (!paratransitCountVisible) {
            plan.attr('data-filter-visible', 0);
            return;
        }

        plan.attr('data-filter-visible', 1);
    }

    /*
     * Filter trip plans by modes
     * @param {Array} modes: an array of mode Ids
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByMode(modes, plan) {
        var visible = false;
        if (!modes instanceof Array || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        var mode = plan.attr('data-mode');
        visible = (modes.indexOf(mode) >= 0);

        return visible;
    }

    /*
     * Filter trip plans by number of transfer
     * @param {number} minCount
     * @param {number} maxCount
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByTransfer(maxCount, plan) {
        var visible = false;
        if (typeof(maxCount) != 'number' || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        var transfer = parseInt(plan.attr('data-transfer'));
        visible = (typeof(transfer) != 'number' || isNaN(transfer) || (transfer <= maxCount));

        return visible;
    }

    /*
     * Filter trip plans by total cost
     * @param {number} minCost
     * @param {number} maxCost
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByCost(maxCost, plan) {
        var visible = false;
        if (typeof(maxCost) != 'number' || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        var cost = parseFloat(plan.attr('data-cost'));
        visible = (typeof(cost) != 'number' || isNaN(cost) || (cost <= maxCost));

        return visible;
    }

    /*
     * Filter trip plans by total duration
     * @param {number} minDuration
     * @param {number} maxDuration
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByDuration(maxDuration, plan) {
        var visible = false;
        if (typeof(maxDuration) != 'number' || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        var duration = parseFloat(plan.attr('data-duration'));
        visible = (typeof(duration) != 'number' || isNaN(duration) || (duration <= maxDuration));

        return visible;
    }

    /*
     * Filter trip plans by total walk dist
     * @param {number} maxWalkDist
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByWalkDist(maxWalkDist, plan) {
        var visible = false;
        if (typeof(maxWalkDist) != 'number' || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        var walkDist = parseFloat(plan.attr('data-walk-dist'));
        visible = (typeof(walkDist) != 'number' || isNaN(walkDist) || (walkDist <= maxWalkDist));

        return visible;
    }


    /*
     * Filter trip plans by total waiting time
     * @param {number} maxWaitTime
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByWaitTime(maxWaitTime, plan) {
        var visible = false;
        if (typeof(maxWaitTime) != 'number' || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        var waitTime = parseFloat(plan.attr('data-wait-time'));
        visible = (typeof(waitTime) != 'number' || isNaN(waitTime) || (waitTime <= maxWaitTime));

        return visible;
    }

    /*
     * Filter trip plans by max allowed paratransit count to show
     * @param {number} maxParantransitCount
     * @param {object} plan
     * @return {bool} visible
     */
    function filterPlansByParatransitCount(maxParantransitCount, plan) {
        var visible = false;
        if (typeof(maxParantransitCount) != 'number' || typeof(plan) != 'object' || plan === null) {
            return visible;
        }

        if(plan.attr('data-mode-code') === 'mode_paratransit') {
            var paratransitNumber = parseInt(plan.attr('data-paratransit-number'));
            visible = (typeof(paratransitNumber) != 'number' || isNaN(paratransitNumber) || (paratransitNumber <= maxParantransitCount));
        }
        else {
            visible = true;
        }
        return visible;
    }

    /*
     * based on given sortKey, get the value from itinerary container
     * @param {object/dom} plan
     * @param {string} sortKey
     */
    function findSortValue(plan, sortKey) {
        if (!plan || (typeof(sortKey) != 'string' || sortKey.trim().length === 0)) {
            return null;
        }
        var attr = plan.attributes['data-' + sortKey];
        if (!attr) {
            return null;
        }

        var rawValue = attr.value;
        switch (sortKey) {
            case 'start-time':
            case 'end-time':
                if (plan.attributes['data-' + sortKey + '-estimated'] == 'true') {
                    rawValue = null;
                } else {
                    rawValue = parseDate(rawValue);
                }
                break;
            case 'duration':
            case 'walk-dist':
            case 'cost':
            case 'wait-time':
                rawValue = parseFloat(rawValue);
                if (isNaN(rawValue)) {
                    rawValue = null;
                }
                break;
            default:
                break;
        }

        return rawValue;
    }

    /*
     * Sort trip itineraries by given type
     * @param {object/dom} sortDropdown
     */
    function sortItineraryBy(sortDropdown) {
        var sortKey = sortDropdown.value;
        var planContainer = $(sortDropdown).parents('.single-trip-part');
        var plans = planContainer.find('.single-plan-review');
        var sortArray = [];
        var nonSortableArray = [];
        if (plans.length > 0) {
            for (var i = 0, planCount = plans.length; i < planCount; i++) {
                var val = findSortValue(plans[i], sortKey);
                if (val === null) {
                    nonSortableArray.push({
                        itinerary: plans[i],
                        value: val
                    });
                } else {
                    sortArray.push({
                        itinerary: plans[i],
                        value: val
                    });
                }
            }
        }

        sortArray = sortArray.sort(function(sortItem1, sortItem2) {
            return (sortItem1.value - sortItem2.value);
        });

        sortArray = sortArray.concat(nonSortableArray);

        if (sortArray.length > 0) {
            var planHeader = planContainer.find('.single-plan-header');
            var startInsertIndex = 0;
            if (planHeader.length > 0) {
                startInsertIndex = planContainer.children().index(planHeader[0]);
            }
            sortArray.forEach(function(sortItem) {
                var detachItem = $(sortItem.itinerary).detach();
                if (startInsertIndex === 0) {
                    planContainer.prepend(detachItem);
                } else {
                    planContainer.children().eq(startInsertIndex++).after(detachItem);
                }
            });
        }
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

    function addInlineHelperTooltip(text) {
        if(typeof(text) != 'string' || text.trim().length === 0) {
            return '';
        }

        return '<i class="fa fa-question-circle fa-2x pull-right label-help"' +
            'style="margin-top:-4px;" data-original-title="' + text +
            '" aria-label="' + text + '"></i>';
    }

    function addReviewTooltip(key) {
        return (localeDictFinder[key].indexOf('not found') > -1 || localeDictFinder[key] == '') ? ('') : (addInlineHelperTooltip(localeDictFinder[key]));
    }

    //public methods
    this.processTripResponse = processTripResponse;
}
