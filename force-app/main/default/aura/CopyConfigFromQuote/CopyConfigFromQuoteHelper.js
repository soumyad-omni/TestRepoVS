({
	doSearch : function(component) {
		
        var action = component.get("c.searchQuote");
        action.setParams({ quoteNum : component.get("v.searchKey"), sourceQuoteId : component.get("v.sourceQuoteId")});
 
        action.setCallback(this, function(response){
            component.set("v.isSearching", false);
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                console.log('rsponse --'+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() && response.getReturnValue().length>0)
                {
                    console.log('rsponse -len-'+response.getReturnValue().length);
                    component.set("v.matchQuoteLines", response.getReturnValue());
                    component.set("v.matchingQuoteId", response.getReturnValue()[0].Quote__c);
                }else{
                    component.set("v.matchQuoteLines", []);
                    component.set("v.matchingQuoteId", null);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "message": "No Matching Quote Found."
                    });
                    toastEvent.fire();
                }
            }
            else
            {
                component.set("v.matchQuoteLines", []);
                component.set("v.matchingQuoteId", null);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": errors[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
    copyQuoteLinesToSource : function(component, quoteLinesToCopy) {
		var action = component.get("c.copyQuoteLines");
        action.setParams({ quoteLinesToCopy : quoteLinesToCopy, sourceQuoteId : component.get("v.sourceQuoteId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "message": "Quote Lines Copied to Quote"
                });
                toastEvent.fire();
                var refreshEvent = $A.get("e.c:QuoteLinesRefresh");
                refreshEvent.fire();
                component.set("v.isCopyConfigModalOpen", false);
            }
            else
            {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": errors[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})