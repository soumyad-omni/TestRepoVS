({
	dojobcheck : function(component, event, helper){
    	var sendquote = component.get("c.sendQuotetocastiron");
        sendquote.setParams({ "qId" : component.get("v.recordId") });
        sendquote.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //component.set("v.disabled","true");
            	component.set("v.message","Success, sending quote to SAP");
            }
            else{
                console.log('failed sending quote to Quote');
            }
        });
        $A.enqueueAction(sendquote);
	}
})