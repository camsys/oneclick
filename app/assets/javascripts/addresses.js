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
			'"addr" : "200 Peachtree Drive, White, GA 30184",' +
			'"lat"  : 34.216618,' +
			'"lon"  : -84.6367147' +
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