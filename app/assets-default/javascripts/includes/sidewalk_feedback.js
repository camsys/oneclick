/*
 * SidewalkFeedback class: add Sidewalk_feedback tool and functionalities to a CsLeaflet map
 * Dependencies: CsLeaflet.Leaflet, jQuery, Bootstrap, Bootstrap Datetimepicker
 */
var CsLeaflet = CsLeaflet || {};

CsLeaflet.SidewalkFeedbackTool = {

    //options
    _options: null,

    _csMap: null,

    _button: null,

    LMsidewalk_feedback_layergroup: new L.layerGroup(),

    init: function(csMap, options) {
    	this._csMap = csMap || {};
    	this._options = options || {};

    	this.addFeedbackInputControl();
        this.registerCustomPopupEventsOnMap();
    	this.registerSidewalkFeedbackEventsOnMap();

        this.registerMapZoomEvent();
    },

    registerMapZoomEvent: function() {
        var csMap = this._csMap || {};
        var currentMap = csMap.LMmap || {};
        var options = this._options || {};
        var feedbackUtil = this;
        var button = this._button || {};
        if(typeof options.min_visible_zoom === 'number') {
            currentMap.on('zoomend', function(){
                var zoom = currentMap.getZoom();
                if(zoom < options.min_visible_zoom) {
                    button.setDisabled(true);
                    currentMap.removeLayer(feedbackUtil.LMsidewalk_feedback_layergroup);
                } else {
                    button.setDisabled(false);
                    currentMap.addLayer(feedbackUtil.LMsidewalk_feedback_layergroup);
                }
            });
        }
    },

    createSidewalkFeedbackMarker: function(lat, lng, dataOptions) {
        var csMap = this._csMap || {};
        var options = this._options || {};
        var marker_name = null;
        if(dataOptions && typeof dataOptions === 'object') {
            var feedbackData = dataOptions.feedbackData || {};
            marker_name = feedbackData.comment;
        }
        var marker = csMap.createMarker(null, lat, lng, options.icon_class, null, marker_name, false, dataOptions);
        this.LMsidewalk_feedback_layergroup.addLayer(marker);

        return marker;
    },

    removeSidewalkFeedbackMarkers: function() {
        var csMap = this._csMap || {};
        var currentMap = csMap.LMmap || {};
        currentMap.removeLayer(this.LMsidewalk_feedback_layergroup);
        this.LMsidewalk_feedback_layergroup = new L.layerGroup();
    },

    addSidewalkFeedbackMarkers: function(arr) {
        var feedbackUtil = this;
        var csMap = this._csMap || {};
        for (var i = 0; i < arr.length; i++) {
            var obj = arr[i] || {};
            var feedbackData = obj.data || {};
            var allowActions = obj.allowed_actions || {};
            if (feedbackData.lat == null || feedbackData.lon == null || !feedbackData.comment) {
                continue;
            }

            marker = feedbackUtil.createSidewalkFeedbackMarker(feedbackData.lat, feedbackData.lon, {
                feedbackData: feedbackData
            });

            var popupText = feedbackUtil.getPopupTextForExistingFeedback(feedbackData, allowActions); //TODO: how to get allowed_actions for previous markers
            marker.bindPopup(popupText, {
                minWidth: 300,
                closeButton: false,
                className: 'sidewalk-feedback-popup'
            });

            // Add this marker to the list of markers
            feedbackUtil.LMsidewalk_feedback_layergroup.addLayer(marker);
        }
    },

    removeMarker: function(marker) {
        this.LMsidewalk_feedback_layergroup.removeLayer(marker);
    },

    addFeedbackInputControl: function() {
    	var csMap = this._csMap;
        if(!L.Control.CustomButton) {
            csMap.registerCustomControl();
        }

        var tooltips = csMap.getMapControlTooltips();
        var currentMap = csMap.LMmap;
        var feedbackInputControl = new L.Control.CustomButton(csMap.SIDEWALK_FEEDBACK, {
            title: tooltips.add_sidewalk_feedback_on_map,
            iconCls: 'fa fa-lg fa-comment',
            toggleable: true
        });

        feedbackInputControl.addTo(currentMap);

        this._button = feedbackInputControl;
    },

    getFormattedFeedbackInputFormForMarker: function(lat, lng) {
        var options = this._options || {};
        var locale_text = options.locale_text || {};
        return "<div class='well'>" +
            "<div class='row'><div class='pull-right'>" +
            "<button class='btn action-button map-action-button' style='margin-right: 5px;' action='submit'>" + locale_text.submit + "</button>" +
            "<button class='btn action-button map-action-button' action='cancel' >" + locale_text.cancel + "</button>" +
            "</div></div>" +
            "<div class='row'>" +
            "<input name='lat' type='hidden' value=" + lat + ">" +
            "<input name='lon' type='hidden' value=" + lng + ">" +
            "<div class='col-sm-12' style='padding:0px;'><label class='control-label'>" + locale_text.comments + "</label><textarea class='form-control' name='comment'></textarea></div>" +
            "<div class='col-sm-12' style='padding:0px;'><label class='control-label'>" + locale_text.remove_by + "</label><input class='form-control' name='removed_at'></input></div>" +
            "</div></div>";
    },

    getPopupTextForExistingFeedback: function(feedbackData, allowActions) {
        feedbackData = feedbackData || {};
        allowActions = allowActions || {};
        var options = this._options || {};
        var locale_text = options.locale_text || {};
    	return "<div class='well'>" +
            "<div class='row'><div class='pull-right'>" +
            (
                allowActions.is_approvable ?
                (
                    "<button class='btn action-button style='margin-right: 5px;' map-action-button' action='approve'>" + locale_text.approve + "</button>" +
                    "<button class='btn action-button style='margin-right: 5px;' map-action-button' action='reject'>" + locale_text.reject + "</button>"
                ) : ""
            ) +
            (allowActions.is_deletable ? "<button class='btn action-button map-action-button' action='delete'>" + locale_text.delete + "</button>": "") +
            "</div></div>" +
            "<div class='row'>" +
            "<div><label>" + locale_text.comments + "</label><div><span class='col-sm-12'>" + feedbackData.comment + "</span></div></div>" +
            (
                feedbackData.removed_at ?
                ("<div><label>" + locale_text.remove_by + "</label><div><span class='col-sm-12'>" + moment(feedbackData.removed_at).format('MM/DD/YYYY') + "</span></div></div>" ) : ""
            ) +
            "</div></div>";
    },

    registerCustomPopupEventsOnMap: function() {
        var csMap = this._csMap;
        var currentMap = csMap.LMmap;
        var feedbackUtil = this;
        currentMap.on('popupopen', function(e) {
          var popupClsName = e.popup.options.className;
          var marker = e.popup._source;
          if (popupClsName === 'sidewalk-feedback-popup') {
            feedbackUtil.registerSidewalkFeedbackPopupButtonEvents(marker);
          } else if (popupClsName === 'new-sidewalk-feedback-popup') {
            feedbackUtil.registerNewSidewalkFeedbackPopupButtonEvents(marker);
          }
        });
    },

    registerSidewalkFeedbackEventsOnMap: function() {
    	var csMap = this._csMap;
    	var currentMap = csMap.LMmap;
    	var feedbackUtil = this;
        currentMap.on('newsidewalkfeedback', function(e){
            var latlng = e.latlng;
            var marker = feedbackUtil.createSidewalkFeedbackMarker(latlng.lat, latlng.lng);

            var popupText = feedbackUtil.getFormattedFeedbackInputFormForMarker(latlng.lat, latlng.lng);
            marker.bindPopup(popupText, {
                minWidth: 300,
                closeButton: false,
                closeOnClick: false,
                className: 'new-sidewalk-feedback-popup'
            }).openPopup();
        });
    },

    /**
     * Submit, Cancel buttons on new feedback popup dialog
     **/
    registerNewSidewalkFeedbackPopupButtonEvents: function(marker) {
        var currentMap = this._csMap.LMmap;
        var feedbackUtil = this;

        $('.new-sidewalk-feedback-popup').on('click', '.map-action-button', function(e) {
            e.preventDefault ? e.preventDefault() : e.returnValue = false;

        	var buttonAction = $(this).attr('action');
        	switch(buttonAction) {
        		case 'submit':
                    var popupDialog = $(this).parents('.new-sidewalk-feedback-popup');
        			var newFeedbackData = feedbackUtil.readFeedbackData(popupDialog);
        			var isValid = feedbackUtil.validateNewFeedbackData(newFeedbackData, popupDialog);
        			if(isValid) {
        				feedbackUtil.submitNewFeedback(currentMap, marker, newFeedbackData);
        			}
        			break;
        		case 'cancel':
        			feedbackUtil.cancelNewFeedback(currentMap, marker);
        			break;
        		default:
        			break;
        	}
        });

        $('.new-sidewalk-feedback-popup input[name=removed_at]').datetimepicker({
            minDate: new Date(),
            pickTime: false,
            format: 'MM/DD/YYYY'
        });
    },

     /**
     * Approve, Reject, Delete buttons on submitted_feedback popup dialog
     **/
    registerSidewalkFeedbackPopupButtonEvents: function(marker) {
        var currentMap = this._csMap.LMmap;
        var feedbackUtil = this;

        $('.sidewalk-feedback-popup').on('click', '.map-action-button', function(e) {
            e.preventDefault ? e.preventDefault() : e.returnValue = false;

            var buttonAction = $(this).attr('action');
            switch(buttonAction) {
                case 'approve':
                    feedbackUtil.approveFeedback(currentMap, marker);
                    break;
                case 'reject':
                    feedbackUtil.rejectFeedback(currentMap, marker);
                    break;
                case 'delete':
                    feedbackUtil.deleteFeedback(currentMap, marker);
                    break;
                default:
                    break;
            }
        });
    },

    readFeedbackData: function(feedbackPopupDialog) {
    	var data = {
    		lat: $(feedbackPopupDialog).find('input[name=lat]').val(),
    		lon: $(feedbackPopupDialog).find('input[name=lon]').val(),
    		comment: $(feedbackPopupDialog).find('textarea[name=comment]').val(),
            removed_at: $(feedbackPopupDialog).find('input[name=removed_at]').val()
    	};

    	return data;
    },

    validateNewFeedbackData: function(feedbackData, feedbackPopupDialog) {
    	var isValid = true;

    	if(!feedbackData.comment) {
            isValid = false;
            $(feedbackPopupDialog).find('textarea[name=comment]').parent('div').addClass('has-error');
        }

    	return isValid;
    },

    submitNewFeedback: function(map, marker, feedbackData) {
        var options = this._options ? this._options : {};
    	var feedbackUtil = this;
    	$.ajax({
          type: "POST",
          url: options.submit_feedback_url,
          data: feedbackData,
          dataType: 'json'
        }).done(function(result) {
            result = result || {};
            if(result.success) {
                marker.options.feedbackData = result.feedback_data;
                var popupText = feedbackUtil.getPopupTextForExistingFeedback(result.feedback_data, result.feedback_allow_actions);
                marker.bindPopup(popupText, {
                    minWidth: 300,
                    closeButton: false,
                    className: 'sidewalk-feedback-popup'
                }).openPopup();
            } else {
                show_alert(result.error_msg);
            }
          });
    },

    cancelNewFeedback: function(map, marker) {
    	this.removeMarker(marker);
    },

    approveFeedback: function(map, marker) {
        var options = this._options ? this._options : {};
    	var feedbackUtil = this;
    	$.ajax({
          type: "POST",
          url: options.approve_feedback_url,
          data: {
            "id": marker.options.feedbackData.id
          },
          // This can't just be a reload or we hit issues with the reload
          success: function(result) {
            result = result || {};
            if(result.success) {
                marker.options.feedbackData = result.feedback_data;
                var popupText = feedbackUtil.getPopupTextForExistingFeedback(result.feedback_data, result.feedback_allow_actions);
                marker.bindPopup(popupText, {
                    minWidth: 300,
                    closeButton: false,
                    className: 'sidewalk-feedback-popup'
                }).openPopup();
            } else {
                show_alert(result.error_msg);
            }
          }
        });
    },

    rejectFeedback: function(map, marker) {
        var options = this._options ? this._options : {};
        var feedbackUtil = this;
        $.ajax({
          type: "POST",
          url: options.reject_feedback_url,
          data: {
            "id": marker.options.feedbackData.id
          },
          // This can't just be a reload or we hit issues with the reload
          success: function(result) {
            result = result || {};
            if(result.success) {
                feedbackUtil.removeMarker(marker);
            } else {
                show_alert(result.error_msg);
            }
          }
        });
    },

    deleteFeedback: function(map, marker) {
        var options = this._options ? this._options : {};
    	var feedbackUtil = this;
    	$.ajax({
          type: "POST",
          url: options.delete_feedback_url,
          data: {
            "id": marker.options.feedbackData.id
          },
          // This can't just be a reload or we hit issues with the reload
          success: function(result) {
            result = result || {};
            if(result.success) {
                feedbackUtil.removeMarker(marker);
            } else {
                show_alert(result.error_msg);
            }
          }
        });
    }
};