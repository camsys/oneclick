var _currentMachineNameInField = null;

var addrConfig = {

    "setCurrentMachineNameInField" : function(name){
        _currentMachineNameInField = name;
    },

    "getCurrentMachineAddressInField" : function(){
        return addrConfig.addresses[_currentMachineNameInField];
    },

    "addresses" : {
        "machine1" : '{' + 
			'"id" : 1,' +
			'"type" : "2",' +
			'"addr" : "Fulton-Dekalb Hospital Authority, Georgia State University, 50 Hurt Plaza Southeast #803, Atlanta, GA 30303",' +
			'"lat"  : 33.753594,' +
			'"lon"  : -84.386415' +
		'}',
        "machine2" : '{' + 
			'"id" : 1,' +
			'"type" : "2",' +
			'"addr" : "253 Mangum Street Northwest",' +
			'"lat"  : 33.760757,' +
			'"lon"  : -84.399097' +
		'}',
    }
}
