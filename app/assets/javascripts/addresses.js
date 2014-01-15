var _currentMachineNameInField = null;

var addrConfig = {

    "setCurrentMachineNameInField" : function(name){
        _currentMachineNameInField = name;
    },

    "getCurrentMachineAddressInField" : function(){
        return addrConfig.addresses[_currentMachineNameInField];
    },

    "addresses" : {

    	// Robert W Woodruff Library
        "machine1" : '{' + 
			'"id" : 8768,' +
			'"type" : "1",' +
			'"addr" : "828 Mitchell Street Southwest, Atlanta, GA 30314",' +
			'"lat"  : 33.7532,' +
			'"lon"  :  -84.4146' +
		'}',

		// Stewart Lakewood Branch Atlanta-Fulton Library
        "machine2" : '{' + 
			'"id" : 8813,' +
			'"type" : "1",' +
			'"addr" : "2891 Lakewood Avenue Southwest, Atlanta, GA 30315",' +
			'"lat"  : 33.6973,' +
			'"lon"  : -84.4113' +
		'}',
    }
}
