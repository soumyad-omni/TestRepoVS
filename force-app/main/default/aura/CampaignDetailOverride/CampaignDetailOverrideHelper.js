({
	helperFun : function(component,event,secId) {
	  var camp = component.find(secId);
        	for(var cmp in camp) {
        	$A.util.toggleClass(camp[cmp], 'slds-show');  
        	$A.util.toggleClass(camp[cmp], 'slds-hide');  
       }
	}
})