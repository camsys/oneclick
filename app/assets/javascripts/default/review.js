/*
* global function to implement a delay timer
* only execute callback when the final event is detected
*/
var waitForFinalEvent = (function () {
  var timers = {};
  return function (callback, ms, uniqueId) {
    if (!uniqueId) {
      uniqueId = "Don't call this twice without a uniqueId";
    }
    if (timers[uniqueId]) {
      clearTimeout (timers[uniqueId]);
    }
    timers[uniqueId] = setTimeout(callback, ms);
  };
})();


/*
* get round value 
* e.g., 75 -> 75
*		(75, 76] -> 76
* @param {number}
*/
function getRoundMaxValue(rawValue) {
	if(typeof(rawValue) != 'number') {
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
	if(typeof(rawValue) != 'number') {
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
	if(typeof(str) != 'string') {
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
	if(typeof(str) != 'string') {
		return '';
	}
	return str.replace(/\s+/g, '');
}

/*
 * parse data in format: %Y-%m-%d %H:%M
 * @param {string} dateStr
 * @return {Date}
 */
function parseDate(dateStr) {
	var momentdate = moment(dateStr);
	if(typeof(momentdate) === 'object' && momentdate != null) {
		return momentdate.toDate();
	} else {
		return null;
	}
}

/*
* TripReviewPageRenderer class: a self-contained class to render dynamic items on trip review page
* @param {number}: intervalStep (minutes)
* @param {number}: barHeight (pixel)
* @method processTripResponse: public method to process trip results
*/
function TripReviewPageRenderer(intervalStep, barHeight) {
	if(typeof(intervalStep) != 'number' || intervalStep < 0) {
		intervalStep = 30; //30min as default
	}

	if(typeof(barHeight) != 'number' || barHeight < 0) {
		barHeight = 20; //20px as default
	}

	var tripContainerId = 'tripContainer'; //id of trip container Div
	var legendContainerId = "legendContainer"; //id of legend container div
	var filterContainerId = "filterContainer"; //id of filter container div
	var modeContainerId = "modeContainer"; //id of mode filter container div
	var transferSliderId = "transferSlider"; //id of transfer filter slider
	var costSliderId = "costSlider"; //id of cost filter slider
	var durationSliderId = "durationSlider"; //id of duration filter slider
	
	var tripPlanDivPrefix = "trip_plan_"; //prefix of each trip plan div
	var missInfoDivPrefix = "tripRestriction"; //prefix of each trip restriction modal dialog
	
	 //chart tooltip
	var chartTooltipDiv = d3.select("body").append("div")   
	.attr("class", "chart-tooltip")  
	.style("opacity", "0");
	
	/**
	 * Process trip results response from service
	 * @param {object} tripResponse 
	 */
	function processTripResponse(tripResponse) {
		//check if response is object
		if(typeof tripResponse != 'object' || tripResponse === null) {
			return;
		}
		
		//check response status
		if(tripResponse.status === 0) {
			console.log('something went wrong');
			return;
		}
		
		var tripParts = tripResponse.trip_parts;
		//check if trip_parts is Array
		if(! tripParts instanceof Array) {
			return;
		}
		
		var resizeChartArray = [];
		//process each trip
		for(var i=0, tripCount=tripParts.length; i<tripCount; i++) {
			tripParts[i] = processTripTimeRange(tripParts[i]);
			tripParts[i] = formatTripData(tripParts[i]);
		}

		tripParts.forEach(function(trip) {
			var newTripChartArray = addTripHtml(trip);
			newTripChartArray.forEach(function(tripChart) {
				resizeChartArray.push(tripChart);
			});
		});

		//process legends
		addLegendHtml(tripParts);

		//add sorting dropdown change listener
		$('.single-trip-part select').on('change', function(e){
			sortItineraryBy(e.currentTarget);
		});
		
		//process filters
		addFilterHtml(tripParts);
		
				
		//windows resize needs to update charts
		window.onresize = function(event) {
			waitForFinalEvent( function() {
				resizeChartArray.forEach(function(param) {
					resizeChart (param.id, param.startTime, param.endTime, intervalStep, barHeight);
				});
			}, 100, 'window resize');
		};
		
		//clicking Select button to change styles
		$('.single-plan-review .single-plan-select').click( function() {
			$(this).parents('.single-trip-part').find('.single-plan-review')
				.removeClass('single-plan-selected')
				.addClass('single-plan-unselected');
			$(this).parents('.single-plan-review')
				.removeClass('single-plan-unselected')
				.addClass('single-plan-selected');
		});
	}

	/*
	* trip -> itineraries -> legs
	* iterate legs to check if itinerary time range covers all known legs' time ranges
	* iterate itineraries to check if trip time range covers all known itineraries' time ranges
	*/
	function processTripTimeRange(trip) {
		if(typeof trip != 'object' || trip === null) {
			return null;
		}

		if(! trip.itineraries instanceof Array) {
			return trip;
		}

		var tripStartTime = parseDate(trip.start_time);
		var tripEndTime = parseDate(trip.end_time);

		trip.itineraries.forEach(function(plan) {
			var planStartTime = parseDate(plan.start_time);
			var planEndTime = parseDate(plan.end_time);
			if(plan.legs instanceof Array) {
				plan.legs.forEach(function(leg) {
					var legStartTime = parseDate(leg.start_time);
					var legEndTime = parseDate(leg.end_time);
					if(!isNaN(planStartTime)) {
						if(!isNaN(legStartTime)) {
							if(legStartTime < planStartTime) {
								planStartTime = legStartTime;
							}
						}
						if(!isNaN(legEndTime)) {
							if(legEndTime < planStartTime) {
								planStartTime = legEndTime;
							}
						}
					}

					if(!isNaN(planEndTime)) {
						if(!isNaN(legStartTime)) {
							if(legStartTime > planEndTime) {
								planEndTime = legStartTime;
							}
						}
						if(!isNaN(legEndTime)) {
							if(legEndTime > planEndTime) {
								planEndTime = legEndTime;
							}
						}
					}
				});
			}	

			if(!isNaN(planStartTime)) {
				plan.start_time = planStartTime.toISOString();
			}	
			if(!isNaN(planEndTime)) {
				plan.end_time = planEndTime.toISOString();
			}	


			if(!isNaN(planStartTime)) {
				if(isNaN(tripStartTime) || planStartTime < tripStartTime) {
					tripStartTime = planStartTime;
				}
			}
			if(!isNaN(planEndTime)) {
				if(isNaN(tripStartTime) || planEndTime < tripStartTime) {
					tripStartTime = planEndTime;
				}
			}

			if(!isNaN(planStartTime)) {
				if(isNaN(tripEndTime) || planStartTime > tripEndTime) {
					tripEndTime = planStartTime;
				}
			}
			if(!isNaN(planEndTime)) {
				if(isNaN(tripEndTime) || planEndTime > tripEndTime) {
					tripEndTime = planEndTime;
				}
			}
		});
		
		if(!isNaN(tripStartTime)) {
			trip.actual_start_time = tripStartTime.toISOString();
		}	
		if(!isNaN(tripEndTime)) {
			trip.actual_end_time = tripEndTime.toISOString();
		}
		return trip;
	}

	/*
	* re-format data in trip object
	* - leg type formatting: only allow Walk, Transfer, Vehicle
	* - legs [] is empty: then need to put itinerary data into legs array
	* - start_time or end_time: if null then use trip's start_time or end_time
	*/
	function formatTripData(trip) {
		if(typeof trip != 'object' || trip === null) {
			return null;
		}

		var strTripStartTime = trip.start_time;
		var strTripEndTime = trip.end_time;
		var minUIDuration = typeof(trip.min_ui_duration) === 'number' ? trip.min_ui_duration : 60; //default 1 hrs
		var maxUIDuration = typeof(trip.max_ui_duration) === 'number' ? trip.max_ui_duration : 4 * 60; //default 4 hrs

		var tripStartTime = parseDate(strTripStartTime);
		var tripEndTime = parseDate(strTripEndTime);

		var actualTripStartTime = parseDate(trip.actual_start_time); //min time by iterating all legs in all itineraries
		var actualTripEndTime = parseDate(trip.actual_end_time); //max time by iterating all legs in all itineraries

		var isStartTimeInvalid = isNaN(tripStartTime);
		var isEndTimeInvalid = isNaN(tripEndTime);
		if(isStartTimeInvalid && isEndTimeInvalid) {
			return;
		} else if(isStartTimeInvalid) {  //check max_ui_duration restriction
			if(!isNaN(actualTripEndTime)) {
				tripEndTime = moment(actualTripEndTime).add('minutes', intervalStep).toDate();
				tripStartTime = moment(actualTripEndTime).subtract('minutes', maxUIDuration).toDate();
			} else {
				tripEndTime = moment(tripEndTime).add('minutes', intervalStep).toDate();
				tripStartTime = moment(tripEndTime).subtract('minutes', maxUIDuration).toDate();
			}
			if(!isNaN(actualTripStartTime) && tripStartTime > actualTripStartTime) {
				tripStartTime = moment(actualTripStartTime).subtract('minutes', intervalStep).toDate();
			}
		} else if(isEndTimeInvalid) {
			if(!isNaN(actualTripStartTime)) {
				tripStartTime = moment(actualTripStartTime).subtract('minutes', intervalStep).toDate();
				tripEndTime = moment(actualTripStartTime).add('minutes', maxUIDuration).toDate();
			} else {
				tripStartTime = moment(tripStartTime).subtract('minutes', intervalStep).toDate();
				tripEndTime = moment(tripStartTime).add('minutes', maxUIDuration).toDate();
			}
			if(!isNaN(actualTripEndTime) && tripEndTime < actualTripEndTime) {
				tripEndTime = moment(actualTripEndTime).add('minutes', intervalStep).toDate();
			}
		}
		
		if(tripEndTime <= tripStartTime) {
			return null;
		} 

		var timeRangeMins = (tripEndTime - tripStartTime) / 1000;
		if(timeRangeMins < minUIDuration) { //check min_ui_duration restriction
			tripStartTime = moment(tripStartTime).subtract('minutes', (minUIDuration - timeRangeMins) / 2).toDate();
			tripEndTime = moment(tripEndTime).add('minutes', (minUIDuration - timeRangeMins) / 2).toDate();
		}

		trip.start_time =  tripStartTime.toISOString();
		trip.end_time =  tripEndTime.toISOString();

		trip.min_ui_duration = minUIDuration;
		trip.max_ui_duration = maxUIDuration;

		if(! trip.itineraries instanceof Array) {
			return trip;
		}

		trip.itineraries.forEach(function(plan) {
			if(isNaN(parseDate(plan.start_time))) {
				plan.start_time = trip.start_time;
				plan.start_time_estimated = true;
			} else {
				plan.start_time_estimated = false;
			}

			if(isNaN(parseDate(plan.end_time))) {
				plan.end_time = trip.end_time;
				plan.end_time_estimated = true;
			} else {
				plan.end_time_estimated = false;
			}

			if(plan.legs instanceof Array) {
				if(plan.legs.length === 0) {
					plan.legs.push({
						"type": "Vehicle",
                        "description": trip.description,
                        "start_time": plan.start_time,
                        "end_time": plan.end_time,
                        "start_time_estimated": plan.start_time_estimated,
                        "end_time_estimated": plan.end_time_estimated
					});
				}

				plan.legs.forEach(function(leg) {
					leg.type = typeof(leg.type) === 'string' ? toCamelCase(leg.type.toLowerCase()) : 'Unknown';
					if(['Walk', 'Transfer', 'Wait'].indexOf(leg.type) < 0) {
						leg.type = 'Vehicle';
					}
					if(isNaN(parseDate(leg.start_time))) {
						leg.start_time = trip.start_time;
						leg.start_time_estimated = true;
					}

					if(isNaN(parseDate(leg.end_time))) {
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
	 * @return {Array} resizeChartArray: an array of config objects for each chart resizing
	 */
	function addTripHtml(trip) {
		var resizeChartArray = [];

		//check if trip is object
		if(typeof trip != 'object' || trip === null) {
			return resizeChartArray;
		}
		
		var isDepartAt = trip.is_depart_at; //departing at or arriving at??
		var tripId = trip.id;
		var strTripStartTime = trip.start_time;
		var strTripEndTime = trip.end_time;

		var tripStartTime = parseDate(strTripStartTime);
		var tripEndTime = parseDate(strTripEndTime);

		var isStartTimeInvalid = isNaN(tripStartTime);
		var isEndTimeInvalid = isNaN(tripEndTime);
		if( isStartTimeInvalid || isEndTimeInvalid || tripEndTime <= tripStartTime) {
			return resizeChartArray;
		} 
		
		var tripTags = "<div class='col-xs-12 well single-trip-part'>";
		
		var tickLabels = getTickLabels(tripStartTime, tripEndTime, intervalStep);
		//process header
		var tripHeaderTags = addTripHeaderHtml(trip.description, tickLabels, intervalStep, isDepartAt);
		tripTags +=  tripHeaderTags;
		
		//process each trip plan
		var tripPlans = trip.itineraries;
		tripPlans = tripPlans.sort(function(itin1, itin2) {
			if(isDepartAt) {
				var departTime1 = parseDate(itin1.start_time);
				var departTime2 = parseDate(itin2.start_time);
				
				return (departTime1 - departTime2);
			} else {
				var arrivalTime1 = parseDate(itin1.end_time);
				var arrivalTime2 = parseDate(itin2.end_time);
				
				return (arrivalTime1 - arrivalTime2);
			}
		});
		tripPlans.forEach(function(tripPlan) {
			if(typeof(tripPlan) === 'object' && tripPlan != null) {
				tripTags += addTripPlanHtml(
					tripId,
					tripPlan,
					strTripStartTime,
					strTripEndTime,
					isDepartAt
				);
			}
		});
		
		tripTags += "</div>";
		
		//render HTML
		$('#' + tripContainerId).append(tripTags);
		
		//render Chart
		tripPlans.forEach(function(tripPlan) {
			if(typeof(tripPlan) === 'object' && tripPlan != null) {
				var tripPlanChartId = tripPlanDivPrefix + tripId + "_" + tripPlan.id;
				createChart(
					tripPlan.id,
					tripPlanChartId, 
					tripPlan.legs, 
					tripStartTime, 
					tripEndTime, 
					intervalStep, 
					barHeight
				);
				
				resizeChartArray.push({
					id: tripPlanChartId,
					startTime: tripStartTime,
					endTime: tripEndTime
				});
				
				addTripStrictionUpdateButtonClickListener(tripPlan.missing_information, tripId, tripPlan.id);
			}
		});
		
		return resizeChartArray;
	}
	
	/*
	 * add on-click listener for Update button in each trip restriction modal dialog
	 * @param {Array} missingInfoArray
	 * @param {number} tripId
	 * @param {number} planId
	 */
	function addTripStrictionUpdateButtonClickListener(missingInfoArray, tripId, planId) {
		if(! missingInfoArray instanceof Array || missingInfoArray.length === 0) {
			return;
		}

		var tripPlanChartDivId = tripPlanDivPrefix + tripId + '_' + planId;
		var missInfoDivId = missInfoDivPrefix + tripId + '-' + planId;
		var updateButtons = $('#' + missInfoDivId + ' .btn-primary');
		
		$('#' + missInfoDivId + ' .btn-primary').click(function(){
			var dialog = $('#' + missInfoDivId);
			var formVals =dialog.find('.form-inline').serializeArray();
			if(formVals.length === 0) {
				return;
			}
			
			var vals = formVals;
			var questionIndex = 1;
			var isQuestionClear = true;
			missingInfoArray.forEach(function(missingInfo) {
				if(!isQuestionClear) {
					return;
				}

				if(typeof(missingInfo) != 'object' || missingInfo === null || !missingInfo.hasOwnProperty('success_condition')) {
					return;
				}
				var controlName = missInfoDivId + '-question-' + (questionIndex++);
				vals.forEach(function(val) {
					if(val.name === controlName) {
						isQuestionClear = isQuestionClear && evalSuccessCondition(formatQuestionAnswer(missingInfo.data_type, val.value), missingInfo.success_condition)
						return;
					}
				});
			});
			var tripPlanDiv = $('#' + tripPlanChartDivId).parents('.single-plan-review');
			if(isQuestionClear) {
				tripPlanDiv.find('.single-plan-question').remove();
				tripPlanDiv.find('.single-plan-select').css('visibility', '');
			} else {
				tripPlanDiv.remove();
			}
			
			dialog.modal('hide');
		});
	}

	function evalSuccessCondition(value, successCondition) {
		try{
			return eval(value + successCondition);
		} 
		catch(evalError) {
			console.log(evalError);
		}

		return false;
	}
	
	function formatQuestionAnswer(type, value) {
		switch(type) {
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
	 * @param {string} tripHeaderTags: html tags of the whole trip header
	 */
	function addTripHeaderHtml(tripDescription, tickLabels,intervelStep, isDepartAt) {		
		//trip description
		var tripDescTag = '<label class="col-sm-12">' + tripDescription + '</label>';
		
		var tickLabelTags = '';
		if(tickLabels instanceof Array && tickLabels.length > 1) {
			var labelCount = tickLabels.length;
			
			var xsShowIndexArray = [0, labelCount - 1];
			var smShowIndexArray = [0, labelCount - 1];
			
			var midIndex = parseInt(labelCount/2);
			if(xsShowIndexArray.indexOf(midIndex) < 0) {
				xsShowIndexArray.push(midIndex);
			} 
			
			if(smShowIndexArray.indexOf(midIndex) < 0) {
				smShowIndexArray.push(midIndex);
			} 
			
			var isEvenCount = (labelCount % 2 === 0);
			var smBase = 2;
			while(smBase <= labelCount -1) {
				if(isEvenCount && smBase === (midIndex - 1)) {
					smBase += 1;
				}
				if(smShowIndexArray.indexOf(smBase) <= 0) {
					smShowIndexArray.push(smBase);
				}
				
				smBase += 2;
			}
			
			var labelWidthPct = 1 / (labelCount - 1) * 100 + '%';
			var labelIndex = 0;
			tickLabels.forEach(function(tickLabel){	
				var className = '';
				if(xsShowIndexArray.indexOf(labelIndex) < 0) {
					className = ' tick-label-hidden-xs';
				} 
				
				if(smShowIndexArray.indexOf(labelIndex) < 0){
					className += ' tick-label-hidden-sm';
				} 
				
				className += ' tick-label-visible-md';
				
				var marginTag = '';
				if(labelIndex === 0) {
					marginTag = 'margin: 0px 0px 0px -20px';
				} else {
					marginTag = 'margin: 0px;';
				}
				tickLabelTags +=
			 	'<span class="' + className + '" style="display:inline-block;width:' + labelWidthPct + ';border: none;text-align:left;' + marginTag + ';">' + tickLabel + '</span>';
				labelIndex ++;
			});
		}
		
		var sorterTags = 
		'<label' + (isDepartAt ? ' class="negative-margin-left"' : '') + '>Sort by: </label>' + 
		'<select style="display: inline-block;"' + (isDepartAt ? '' : ' class="negative-margin-right"') + '>' +
			'<option value="start-time" ' + (isDepartAt ? ' selected' : '') + '>Departure Time</option>' +
			'<option value="end-time" ' + (isDepartAt ? '' : ' selected') + '>Arrival Time</option>' +
			'<option value="cost" >Cost</option>' +
			'<option value="duration" >Travel Time</option>' +
		'</select>';
		
		var tripHeaderTags = tripDescTag +
				"<div class='col-xs-12 single-plan-header'>" +
					"<div class='col-xs-3 col-sm-2' style='padding: 0px;'>" +
						(isDepartAt ? ("<button class='btn btn-xs pull-right prev-period'> -" + intervelStep + "</button>") : "") +
					"</div>" +
					"<div class='col-xs-7 col-sm-9 " + (isDepartAt ? "highlight-left-border" : "highlight-right-border") + "' style='padding: 0px;white-space: nowrap; text-align: center;'>" +
						(
							isDepartAt ? 
							("<button class='btn btn-xs pull-left next-period'> +" + intervelStep + "</button>") : 
							("<button class='btn btn-xs pull-right prev-period'> -" + intervelStep + "</button>")
						) +
						sorterTags +
					"</div>" +
					"<div class='col-xs-2 col-sm-1 select-column' style='padding: 0px;'>" +	
						(isDepartAt ? "" : ("<button class='btn btn-xs pull-left next-period'> +" + intervelStep + "</button>")) +
					"</div>" +
					"<div class='col-xs-3 col-sm-2' style='padding: 0px;'>" +
					"</div>" +
					"<div class='col-xs-7 col-sm-9 " + (isDepartAt ? "highlight-left-border" : "highlight-right-border") + "' style='padding: 0px;white-space: nowrap;'>" +
					 	tickLabelTags +
					"</div>" +
					"<div class='col-xs-2 col-sm-1 select-column' style='padding: 0px;'>" +	
					"</div>" +
				"</div>";
		return tripHeaderTags;
	}

	/**
	 * Render trip part
	 * @param {number} tripId
	 * @param {Object} tripPlan
	 * @param {string} strTripStartTime: trip start time
	 * @param {string} strTripEndTime: trip end time
	 * @param {bool} isDepartAt: true if departing at, false if arriving at
	 * @return {string} HTML tags of each trip plan
	 */
	function addTripPlanHtml(tripId, tripPlan, strTripStartTime, strTripEndTime, isDepartAt) {
		if(typeof(tripPlan)!= 'object' || tripPlan === null) {
			return "";
		}
		var planId = tripPlan.id;
		var mode = tripPlan.mode ? tripPlan.mode : '';
		var modeName = tripPlan.mode_name ? tripPlan.mode_name : '';
		var serviceName = tripPlan.service_name ? tripPlan.service_name : '';
		var contact_information = tripPlan.contact_information; 
		var cost = tripPlan.cost;
		var missingInfoArray = tripPlan.missing_information; 
		var transfers = typeof(tripPlan.transfers) === 'number' ? tripPlan.transfers : 0;
		var duration = tripPlan.duration;
		var strPlanStartTime = tripPlan.start_time; 
		var strPlanEndTime = tripPlan.end_time;
		var isPlanStartTimeEstimated = tripPlan.start_time_estimated;
		var isPlanEndTimeEstimated = tripPlan.end_time_estimated;
						
		//var cssName = removeSpace(mode.toLowerCase()) + "-" + removeSpace(serviceName.toLowerCase());
		var cssName = removeSpace(mode.toLowerCase());
		var modeServiceUrl = "";
		if(typeof(contact_information) === 'object'  && contact_information != null) {
			modeServiceUrl = contact_information.url;
		}

		//check if missing info found; if so, need to us Question button instead of Select button
		var isMissingInfoFound = (missingInfoArray instanceof Array && missingInfoArray.length > 0);
		var missInfoDivId = missInfoDivPrefix + tripId + "-" + planId; //id of missing info modal dialog
		
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
			" data-mode='" + mode + "'" +
			" data-transfer='" + transfers.toString() + "'" +
			" data-cost='" + ((typeof(cost) === 'object'  && cost != null && (typeof(cost.price) === 'number')) ? cost.price : '') + "'" +
			" data-duration='" + (typeof(duration) === 'object'  && duration != null ? parseFloat(duration.sortable_duration)/60 : '') + "'";
		var tripPlanTags = 
			"<div class='col-xs-12 single-plan-review single-plan-unselected' style='padding: 0px;'" + dataTags +">" +
				"<div class='col-xs-3 col-sm-2 trip-plan-first-column' style='padding: 0px; height: 100%;'>" +
					"<table>" +
						"<tbody>" +
							"<tr>" +
								"<td class='trip-mode-icon " + cssName + "'>" +
									(
										typeof(modeServiceUrl) === 'string' && modeServiceUrl.trim().length > 0 ?
											"<a href='" + modeServiceUrl + "' target='_blank'</a>" : "" 
									)	+
								"</td>" +
								"<td class='trip-mode-cost'>" +
									"<div class='itinerary-text'>" +
										(typeof(cost) === 'object'  && cost != null && (typeof(cost.price) === 'number')? "$" + cost.price : '') + 
									"</div>" +
								"</td>" +
							"</tr>" +
						"</tbody>" +
					"</table>" +
				"</div>" +
				"<div class='col-xs-7 col-sm-9 " + 
					(isDepartAt ? "highlight-left-border regular-right-border" : "highlight-right-border regular-left-border") + 
					"' style='padding: 0px; height: 100%;' id='" + tripPlanDivPrefix + tripId + "_" + planId + "'>" +
				"</div>" +
				"<div class='col-xs-2 col-sm-1 select-column' style='padding: 0px; height: 100%;'>" +
					(
						isMissingInfoFound ?
						(
							"<button class='btn btn-default btn-xs single-plan-question action-button' " +
							"data-toggle='modal' data-target='#" + missInfoDivId + "'>?</button>" +
							"<button class='btn btn-default btn-xs single-plan-select action-button' style='visibility: hidden;'>Select</button>"
						) :
						"<button class='btn btn-default btn-xs single-plan-select action-button'>Select</button>"
					) +
				"</div>" +
			"</div>";
		//tags for missing info div
		if(isMissingInfoFound) {
			tripPlanTags += addTripRestrictionDialogHtml(missingInfoArray, missInfoDivId);
		}
		
		return tripPlanTags;
	}
	
	/*
	 * generate html tags for trip restrictions dialog
	 * @param {Array} missingInfoArray
	 * @param {string} missInfoDivId
	 * @return {string} html tags
	 */
	function addTripRestrictionDialogHtml(missingInfoArray, missInfoDivId){
			if(! missingInfoArray instanceof Array || missingInfoArray.length === 0 || typeof(missInfoDivId) != 'string') {
				return '';
			}
			
			var questionTags = '';
			var questionIndex = 1;
			missingInfoArray.forEach(function(missingInfo) {
				var controlName = missInfoDivId + '-question-' + (questionIndex++);
				questionTags += addSingleTripRestrictionQuestion(missingInfo, controlName);
			});

			var missInfoTags = 
			'<div class="modal fade" data-backdrop="static" id="' + missInfoDivId + '" tabindex="-1" role="dialog" aria-labelledby="'+ missInfoDivId + '-title" aria-hidden="true">' +
			  '<div class="modal-dialog">' +
			    '<div class="modal-content">' +
			      '<div class="modal-header">' +
			        '<button type="button" class="close" aria-hidden="true" style="color: red; opacity: 1;">?</button>' +
			        '<b class="modal-title" id="' + missInfoDivId + '-title">Trip Restrictions</b>' +
			      '</div>' +
			      '<div class="modal-body">' +
			      	'<form class="form-inline" role="form">' +
				      	questionTags + 
			        '</form>' + 
			      '</div>' +
			      '<div class="modal-footer">' +
			        '<button type="button" class="btn btn-primary action-button">Update</button>' +
			        '<button type="button" class="btn btn-default action-button" data-dismiss="modal">Cancel</button>' +
			      '</div>' +
			    '</div>' +
			  '</div>' +
			'</div>';
			
		return missInfoTags;	
	}

	/*
	* generate html tags for each trip restriction question
	* @param {Object} missingInfo
	* @param {string} controlName
	* @return {string}
	*/
	function addSingleTripRestrictionQuestion(missingInfo, controlName) {
		var isMissingInfoFound = (typeof(missingInfo) === 'object'  && missingInfo != null &&  missingInfo.hasOwnProperty('success_condition'));

		if(!isMissingInfoFound) {
			return '';
		}

		var infoShortDesc = missingInfo.description;
		var infoLongDesc = missingInfo.question;
		var infoType = missingInfo.data_type;
		var successCondition = missingInfo.success_condition;
		
		var answersTags = '';
		switch(infoType) {
			case 'boolean':
				var infoOptions = missingInfo.options;
				if(infoOptions instanceof Array && infoOptions.length > 0) {
					infoOptions.forEach(function(infoOption) {
						if(typeof(infoOption) === 'object'  && infoOption != null) {
							answersTags += 
							'<label class="radio-inline">' +
									'<input type="radio" name="' + controlName +'" ' + 
										'value="' + infoOption.value + '" ' +
										(infoOption.is_default ? 'checked' : '') +
									'>' + infoOption.text + 
								'</label>';				
						}
					});
				}
				break;
			case 'integer':
				answersTags += '<input type="number" class="form-control" id="' + controlName + '-number" label="false" name="' + controlName +'"/>';
				break;
			case 'date':
				answersTags += '<input type="text" class="form-control" id="' + controlName + '-date" label="false" name="' + controlName +'"/>' +
									'<script type="text/javascript">' +
										'$(function () {' +
											'$("#' + controlName + '-date").datetimepicker({' +
												'defaultDate: new Date(),' +
												'pickTime: false ' +
											'});' +
										'});' +
									'</script>';
				break;
			case 'datetime':
				answersTags += '<input type="text" class="form-control" id="' + controlName + '-date" label="false" name="' + controlName +'"/>' +
									'<script type="text/javascript">' +
										'$(function () {' +
											'$("#' + controlName + '-date").datetimepicker({' +
												'defaultDate: new Date()'
											'});' +
										'});' +
									'</script>';
				break;
			default:
				break;
		}

		return (
			'<p">' +
	        	'<span>' + infoShortDesc + '</span>' +
	        '</p>' +
	      	'<p">' +
	        	'<label class="control-label"style="margin-right: 10px;">' + infoLongDesc + '</label>' +
	        	answersTags +
	        '</p>'
	    );
	}
	
	/**
	 * Html of legends
	 * @param {Array} trips 
	 */
	function addLegendHtml(trips) {
		if(! trips instanceof Array) {
			return;
		}
		
		var legendTags = '';
		var legendClassNames = [];
		trips.forEach(function(trip) {
			if(typeof(trip) != 'object' || trip === null || ! trip.itineraries instanceof Array) {
				return;
			}
			var tripPlans = trip.itineraries;
			tripPlans.forEach(function(tripPlan) {
				if(typeof(tripPlan) != 'object' || tripPlan === null || ! tripPlan.legs instanceof Array) {
					return;
				}
				var legs = tripPlan.legs;
				legs.forEach(function(leg) {
					if(typeof(leg) != 'object' || leg === null || typeof(leg.type) != 'string') {
						return;
					}
					
					var className = "travel-legend-" + removeSpace(leg.type.toLowerCase());
					var legendText = toCamelCase(leg.type);
					
					if(!legendClassNames[className]) {
						legendClassNames[className] = legendText;
						legendTags += 
							"<div class='travel-legend-container'>" + 
							"<div class='travel-legend " + className + "'/>" +
							"<span class='travel-legend-text'>" + legendText + "</span>" +
							"</div>";
					}
				});
			});
		});
		
		$('#' + legendContainerId).append(legendTags);
	}
	
	/*
	 * Html of filters
	 * @param {Array} trips 
	 */
	function addFilterHtml(trips) {
		if(! trips instanceof Array) {
			return;
		}
		
		var filterTags = '';
		
		var modes = {};
		var minTransfer = -1;
		var maxTransfer = -1;
		var minCost = -1;
		var maxCost = -1;
		var minDuration = -1;
		var maxDuration = -1;
		
		trips.forEach(function(trip) {
			if(typeof(trip) != 'object' || trip === null || ! trip.itineraries instanceof Array) {
				return;
			}
			var tripPlans = trip.itineraries;
			tripPlans.forEach(function(tripPlan) {
				if(typeof(tripPlan) != 'object' || tripPlan === null) {
					return;
				}
				
				//transfers
				var transfer = parseInt(tripPlan.transfers);
				if(transfer >= 0) {
					if(minTransfer < 0 || transfer < minTransfer) {
						minTransfer = transfer;
					}
					
					if(minTransfer < 0 || transfer > maxTransfer) {
						maxTransfer = transfer;
					}
				}
				
				//cost
				var costInfo = tripPlan.cost;
				if(typeof(costInfo) === 'object'  && costInfo != null) {
					var cost = parseFloat(costInfo.price);
					if(cost >= 0) {
						if(minCost < 0 || cost < minCost) {
							minCost = cost;
						}
						
						if(maxCost < 0 || cost > maxCost) {
							maxCost = cost;
						}
					}
				}
				
				//duration
				var durationInfo = tripPlan.duration;
				if(typeof(durationInfo) === 'object'  && durationInfo != null) {
					var duration = parseFloat(durationInfo.sortable_duration);
					if(duration >= 0) {
						if(minDuration < 0 || duration < minDuration) {
							minDuration = duration;
						}
						
						if(maxDuration < 0 || duration > maxDuration) {
							maxDuration = duration;
						}
					}
				}
				
				//modes
				if(! modes.hasOwnProperty(tripPlan.mode)){
					modes[tripPlan.mode] = toCamelCase(tripPlan.mode_name);
				}
			});
		});
		
		//insert modes filter tags
		var isFirstMode = true;
		for(var modeId in modes) {
			if(isFirstMode) {
				filterTags +=
					'<div class = "col-sm-12">' + 
						'<label class="sr-only">Modes</label>' +
						'<label class="col-sm-12">Modes</label>' +
					'</div>';
				isFirstMode = false;
			}

			filterTags +=
			'<div class="col-sm-12" id="' + modeContainerId + '">' +
			'<div class="checkbox" style="margin:0px 0px 0px 10px;">' +
			  '<label>' +
			    '<input type="checkbox" checked=true value=' + modeId + '>' +
			    modes[modeId] +
			  '</label>' +
			'</div>'+
			'</div>';
		}
		
		var sliderConfigs = [];
		//insert transfer fitler tags
		var transferFilter = getTransferFilterHtml(minTransfer, maxTransfer);
		if(typeof(transferFilter) === 'object'  && transferFilter != null) {
			filterTags += transferFilter.tags;
			sliderConfigs['transfer'] = transferFilter.sliderConfig;
		}
		//insert cost fitler tags
		var costFilter = getCostFilterHtml(minCost, maxCost);
		if(typeof(costFilter) === 'object'  && costFilter != null) {
			filterTags += costFilter.tags;
			sliderConfigs['cost'] = costFilter.sliderConfig;
		}
		//insert duration fitler tags
		var durationFilter = getDurationFilterHtml(minDuration, maxDuration);
		if(typeof(durationFilter) === 'object'  && durationFilter != null) {
			filterTags += durationFilter.tags;
			sliderConfigs['duration'] = durationFilter.sliderConfig;
		}
		
		//render
		$('#' + filterContainerId).append(filterTags);
		
		//enable mode checkbox event
		$('#' + modeContainerId + ' .checkbox').on('change', function() {
        	waitForFinalEvent(filterPlans, 100, 'mode change');
		});
		
		//enable sliders
		for(var sliderIndex in sliderConfigs) {
			var slider = sliderConfigs[sliderIndex];
			addSliderTooltip(slider);
		}
		
	}
	
	/*
	 * create html tags for transfer filter
	 * @param {number}: minTransfer
	 * @param {number}: maxTransfer
	 */
	function getTransferFilterHtml(minTransfer, maxTransfer){
		var tags = '';
		var sliderConfig = null;
		if(typeof(maxTransfer) === 'number' && typeof(minTransfer) === 'number' && maxTransfer > minTransfer) {
			tags = 
			'<div class = "col-sm-12">' + 
				'<label class="sr-only">Number of transfers</label>' +
				'<label class="col-sm-12">Number of transfers</label>' +
			'</div>' +
			'<div class="col-sm-12">' +
				'<div role="slider" id="' + transferSliderId + '" aria-valuemin="' + minTransfer + '" aria-valuemax="' + maxTransfer + '">' +
				'</div>' +
			'</div>' +
			'<div class="col-sm-12" style="margin-bottom: 5px;">' + 
				'<span class="pull-left">' + minTransfer.toString() + '</span>'	+
				'<span class="pull-right">' + maxTransfer.toString() + '</span>'	+
			'</div>';	
			sliderConfig = {
				id: transferSliderId,
				values: [minTransfer, maxTransfer],
				min: minTransfer,
				max: maxTransfer,
				step: 1,
				range: true
			};
		}
		
		return {
			tags: tags,
			sliderConfig: sliderConfig
		};
	}
	
	/*
	 * create html tags for cost filter
	 * @param {number}: minCost
	 * @param {number}: maxCost
	 */
	function getCostFilterHtml(minCost, maxCost){
		var tags = '';
		var sliderConfig = null;
		if(typeof(maxCost) === 'number' && typeof(minCost) === 'number' && maxCost > minCost) {
			minCost = getRoundMinValue(minCost);
			maxCost = getRoundMaxValue(maxCost);
			tags = 
			'<div class = "col-sm-12">' + 
				'<label class="sr-only">Cost</label>' +
				'<label class="col-sm-12">Cost</label>' +
			'</div>' +
			'<div class="col-sm-12">' +
				'<div role="slider" id="' + costSliderId + '" aria-valuemin="' + minCost + '" aria-valuemax="' + maxCost + '">' +
				'</div>' +
			'</div>' +
			'<div class="col-sm-12" style="margin-bottom: 5px;">' + 
				'<span class="pull-left">$' + minCost.toString() + '</span>'	+
				'<span class="pull-right">$' + maxCost.toString() + '</span>'	+
			'</div>';	
			sliderConfig = {
				id: costSliderId,
				values: [minCost, maxCost],
				min: minCost,
				max: maxCost,
				step: 1,
				range: true
			};
		}
		
		return {
			tags: tags,
			sliderConfig: sliderConfig
		};
	}
	
	/*
	 * create html tags for durtion filter
	 * @param {number}: minDuration
	 * @param {number}: maxDuration
	 */
	function getDurationFilterHtml(minDuration, maxDuration){
		var tags = '';
		var sliderConfig = null;
		if(typeof(maxDuration) === 'number' && typeof(minDuration) === 'number' && maxDuration > minDuration) {
			minDuration = getRoundMinValue(minDuration/60);
			maxDuration = getRoundMaxValue(maxDuration/60);
			tags = 
			'<div class = "col-sm-12">' + 
				'<label class="sr-only">Time</label>' +
				'<label class="col-sm-12">Time</label>' +
			'</div>' +
			'<div class="col-sm-12">' +
				'<div role="slider" id="' + durationSliderId + '" aria-valuemin="' + minDuration + '" aria-valuemax="' + maxDuration + '">' +
				'</div>' +
			'</div>' +
			'<div class="col-sm-12" style="margin-bottom: 5px;">' + 
				'<span class="pull-left">' + minDuration.toString() + 'min</span>'	+
				'<span class="pull-right">' + maxDuration.toString() + 'min</span>'	+
			'</div>';	
			sliderConfig = {
				id: durationSliderId,
				values: [minDuration, maxDuration],
				min: minDuration,
				max: maxDuration,
				step: 0.01,
				range: true
			};
		}
		
		return {
			tags: tags,
			sliderConfig: sliderConfig
		};
	}
	
	/*
	 * add tooltip for each slider
	 * @param {Object} slider
	 */
	function addSliderTooltip(slider) {
		if(typeof(slider) != 'object' || slider === null) {
			return;
		}

		var sliderId = "#" + slider.id;
		$(sliderId).slider(slider);
		
		$(sliderId).on('slide', function( event, ui ) {
				var minVal = ui.values[0];
				var maxVal = ui.values[1];
				$(sliderId + ' .ui-slider-handle:first').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + minVal + '</div></div>');
				$(sliderId + ' .ui-slider-handle:last').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + maxVal + '</div></div>');
        		
        		waitForFinalEvent(filterPlans, 100, slider.Id + ' sliding');
		});
		
		$(sliderId + " .ui-slider-handle").mouseleave(function() {
			$(sliderId  + ' .ui-slider-handle').empty();
		});
		$(sliderId + " .ui-slider-handle").mouseenter(function() {
			var values = $(sliderId).slider( "option", "values" );
			var minVal = values[0];
			var maxVal = values[1];
			$(sliderId + ' .ui-slider-handle:first').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + minVal + '</div></div>');
			$(sliderId + ' .ui-slider-handle:last').append('<div class="tooltip top slider-tip"><div class="tooltip-arrow"></div><div class="tooltip-inner">' + maxVal + '</div></div>');
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
		var labelFormat = d3.time.format('%H:%M %p');
		var ticks = d3.time.scale()
			.domain([tripStartTime, tripEndTime])
			.nice(d3.time.minute, intervalStep)
			.ticks(d3.time.minute, intervalStep)
			.forEach(function(tick) {
				tickLabels.push(labelFormat(tick));
			});
			
		return tickLabels;
	}
	
	/**
	 * Create a timeline chart
	 * @param {number} planId 
	 * @param {string} chartDivId 
	 * @param {Array} tripLegs
	 * @param {Date} tripStartTime
	 * @param {Date} tripEndTime
	 * @param {number} intervalStep
	 * @param {number} barHeight
	 */
	function createChart(planId, chartDivId, tripLegs, tripStartTime, tripEndTime, intervalStep, barHeight) {
		if(! tripStartTime instanceof Date || ! tripEndTime instanceof Date || 
			! tripLegs instanceof Array || typeof(intervalStep) != 'number' || typeof(barHeight) != 'number') {
			return;
		}

		//planId is used in chart_onclick event
		//sent to server to get itinerary and render plan details modal
		tripLegs.forEach(function(leg){
			leg.planId = planId;
		});

		var $chart = $('#' + chartDivId);
		if($chart.length === 0) { //this chart div doesnt exist
			return;
		}
		
		var width = $chart.width();
		var height = $chart.height();
		var chart = d3.select('#' + chartDivId) 
		  .append('svg')
		  .attr('class', 'chart')
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
		var ticks = xScale
			.ticks(d3.time.minute, intervalStep);
		
		//draw tick lines without first and last (this is styled by border)
		if(ticks.length > 0) {
			ticks.splice(0, 1);
			
			if(ticks.length > 0) {
				ticks.splice(ticks.length -1, 1);
			}
		}
		
		chart.selectAll("line")
		  .data(ticks)
		  .enter().append("line")
		  .attr("x1", function(d) { return x(d); })
		  .attr("x2", function(d) { return x(d); })
		  .attr("y1", 0)
		  .attr("y2", height);
		
		var tipText = "";
		tripLegs.forEach(function(leg) {
			tipText += leg.description + "<br>";
		});
		
		chart.selectAll("rect")
		   .data(tripLegs)
		   .enter().append("rect")
		   .attr('class', function(d) { return "travel-type-" + d.type.toLowerCase(); })
		   .attr("x", function(d) { return d.start_time_estimated ? 0 : x(parseDate(d.start_time)); })
		   .attr("y", y(1) - barHeight/2)
		   .attr("width", function(d) { return (d.end_time_estimated ? width : x(parseDate(d.end_time))) - (d.start_time_estimated ? 0 : x(parseDate(d.start_time))); })
		   .attr("height", barHeight)
		   .on("mouseover", function(d) {
				chartTooltipDiv
					.style("left", getTooltipLeft(d3.event.pageX, chartTooltipDiv.node()) + "px")     
					.style("top", getTooltipTop(d3.event.pageY, chartTooltipDiv.node()) + "px")
					.style("opacity", "0.9");
		
				chartTooltipDiv.html(tipText); //d.description if for each leg  
					
				})                  
			.on("mouseout", function(d) {       
				chartTooltipDiv    
					.style("left", "0px")     
					.style("top", "0px")
					.style("opacity", "0");
			});
	}

	/*
	* get left position in px of chart tooltip
	*/
	function getTooltipLeft (rawLeft, tooltipNode) {
		var divWidth = tooltipNode.clientWidth;
		var docWidth = $(document).width();
		var margin = 5;
		if((rawLeft + divWidth) >= docWidth) {
			rawLeft = docWidth - divWidth - margin;
		}
		
		return rawLeft;
	}

	/*
	* get top position in px of chart tooltip
	*/
	function getTooltipTop (rawTop, tooltipNode) {
		var divHeight = tooltipNode.clientHeight;
		var docHeight = $(document).height();
		var margin = 5;
		if((rawTop + divHeight) >= docHeight) {
			rawTop = docHeight - divHeight - margin;
		}
		
		return rawTop;
	}
	
	/**
	 * Create a timeline chart
	 * @param {string} chartDivId 
	 * @param {Date} tripStartTime
	 * @param {Date} tripEndTime
	 * @param {number} intervalStep
	 * @param {number} barHeight
	 */
	function resizeChart (chartDivId, tripStartTime, tripEndTime, intervalStep, barHeight) {
		if(! tripStartTime instanceof Date || ! tripEndTime instanceof Date || 
			typeof(intervalStep) != 'number' || typeof(barHeight) != 'number') { //type check
			return;
		}
		var $chart = $('#' + chartDivId);
		if($chart.length === 0) { //this chart div doesnt exist
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
		
		//update tick lines
		chart.selectAll("line")
		  .attr("x1", function(d) { return x(d); })
		  .attr("x2", function(d) { return x(d); })
		  .attr("y1", 0)
		  .attr("y2", height);
		
		//update chart items
		chart.selectAll("rect")
		   .attr("x", function(d) { return d.start_time_estimated ? 0 : x(parseDate(d.start_time)); })
		   .attr("y", y(1) - barHeight/2)
		   .attr("width", function(d) { return (d.end_time_estimated ? width : x(parseDate(d.end_time))) - (d.start_time_estimated ? 0 : x(parseDate(d.start_time))); })
		   .attr("height", barHeight);
	}
	
	/*
	 * main filtering function that handles modes, transfer, cost, and duration
	 */
	function filterPlans(){
		var modes = [];
		var modeCheckboxs = $('#' + modeContainerId + ' .checkbox :checked');
		for(var i=0, modeCount=modeCheckboxs.length; i<modeCount; i++) {
			var modeCheckbox = modeCheckboxs[i];
			var modeVal = modeCheckbox.attributes['value'].value;
	
			modes.push(modeVal);
		}
		
		var transferValues = $('#' + transferSliderId).slider( "option", "values" );
		
		
		var costValues = $('#' + costSliderId).slider( "option", "values" );
		
		
		var durationValues = $('#' + durationSliderId).slider( "option", "values" );
		
		
		var allPlans = d3.selectAll('.single-plan-review')[0];
		allPlans.forEach(function(plan) {
			processPlanFiltering(modes, transferValues, costValues, durationValues, plan);
		});
	}
	
	function processPlanFiltering(modes, transferValues, costValues, durationValues, plan){
			var modeVisible = true;
			if(modes instanceof Array) {
				modeVisible = filterPlansByMode(modes, plan);
			}
		
			if(!modeVisible) {
				plan.style.display = 'none';
				return;
			}

			var transferVisible = true;
			if(transferValues instanceof Array && transferValues.length === 2) {
				transferVisible = filterPlansByTransfer(transferValues[0], transferValues[1], plan);
			}

			if(!transferVisible) {
				plan.style.display = 'none';
				return;
			}
			
			var costVisible = true;
			if(costValues instanceof Array && costValues.length === 2) {
				costVisible = filterPlansByCost(costValues[0], costValues[1], plan);
			}

			if(!costVisible) {
				plan.style.display = 'none';
				return;
			}
			
			var durationVisible = true;
			if(durationValues instanceof Array && durationValues.length === 2) {
				durationVisible = filterPlansByDuration(durationValues[0], durationValues[1], plan);
			}
			
			if(!durationVisible) {
				plan.style.display = 'none';
				return;
			}

			//passes all filtering check
			plan.style.display = 'block';
			
			var tmpTripId = plan.attributes['data-trip-id'].value;
			var tmpPlanId = plan.attributes['data-plan-id'].value;
			var tmpTripStartTime = parseDate(plan.attributes['data-trip-start-time'].value);
			var tmpTripEndTime = parseDate(plan.attributes['data-trip-end-time'].value);		
			var tmpChartDivId = tripPlanDivPrefix + tmpTripId + "_" + tmpPlanId;	
			resizeChart(tmpChartDivId, tmpTripStartTime, tmpTripEndTime, intervalStep, barHeight);
	}
	
	/*
	 * Filter trip plans by modes
	 * @param {Array} modes: an array of mode Ids
	 * @param {object} plan
	 * @return {bool} visible
	 */
	function filterPlansByMode(modes, plan) {
		var visible =false;
		if(!modes instanceof Array || typeof(plan) != 'object' || plan === null || ! plan.hasOwnProperty('attributes')) {
			return visible;
		}
					
		var mode = plan.attributes['data-mode'].value;
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
	function filterPlansByTransfer(minCount, maxCount, plan) {
		var visible =false;
		if(typeof(minCount) != 'number' || typeof(maxCount) != 'number'  || typeof(plan) != 'object' || plan === null || ! plan.hasOwnProperty('attributes')) {
			return visible;
		}
					
		var transfer = parseInt(plan.attributes['data-transfer'].value);
		visible = (typeof(transfer) != 'number' || isNaN(transfer)   || (transfer >= minCount && transfer <= maxCount) );
		
		return visible;
	}
	
	/*
	 * Filter trip plans by total cost
	 * @param {number} minCost
	 * @param {number} maxCost
	 * @param {object} plan
	 * @return {bool} visible
	 */
	function filterPlansByCost(minCost, maxCost, plan) {
		var visible =false;
		if(typeof(minCost) != 'number' || typeof(maxCost) != 'number' || typeof(plan) != 'object' || plan === null || ! plan.hasOwnProperty('attributes')) {
			return visible;
		}
					
		var cost = parseFloat(plan.attributes['data-cost'].value);
		visible = (typeof(cost) != 'number' || isNaN(cost) || (cost >= minCost && cost <= maxCost));
		
		return visible;
	}
	
	/*
	 * Filter trip plans by total duration
	 * @param {number} minDuration
	 * @param {number} maxDuration
	 * @param {object} plan
	 * @return {bool} visible
	 */
	function filterPlansByDuration(minDuration, maxDuration, plan) {
		var visible =false;
		if(typeof(minDuration) != 'number' || typeof(maxDuration) != 'number'  || typeof(plan) != 'object' || plan === null || ! plan.hasOwnProperty('attributes')) {
			return visible;
		}
					
		var duration = parseFloat(plan.attributes['data-duration'].value);
		visible = (typeof(duration) != 'number' || isNaN(duration)  || (duration >= minDuration && duration <= maxDuration) );
		
		return visible;
	}

	/*
	* based on given sortKey, get the value from itinerary container
	* @param {object/dom} plan
	* @param {string} sortKey
	*/
	function findSortValue(plan, sortKey) {
		if(!plan || (typeof(sortKey) != 'string' || sortKey.trim().length === 0)) {
			return null;
		}
		var attr = plan.attributes['data-' + sortKey];
		if(!attr) {
			return null;
		}
		
		var rawValue = attr.value;
		switch(sortKey) {
			case 'start-time':
			case 'end-time':
				if(plan.attributes['data-' + sortKey + '-estimated'] == 'true') {
					rawValue = null;
				} else {
					rawValue = parseDate(rawValue);
				}
				break;
			case 'duration':
			case 'cost':
				rawValue = parseFloat(rawValue);
				if(isNaN(rawValue)) {
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
		if(plans.length > 0) {
			for(var i=0, planCount=plans.length; i<planCount; i++) {
				var val = findSortValue(plans[i], sortKey);
				if(val === null) {
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
		
		sortArray = sortArray.sort(function(sortItem1, sortItem2){
			return (sortItem1.value - sortItem2.value);
		});

		sortArray = sortArray.concat(nonSortableArray);
		
		if(sortArray.length > 0) {
			var planHeader = planContainer.find('.single-plan-header');
			var startInsertIndex = 0;
			if(planHeader.length > 0) {
				startInsertIndex= planContainer.children().index(planHeader[0]);
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

	//public methods
	this.processTripResponse = processTripResponse;
}