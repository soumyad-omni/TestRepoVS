({
	fetchQuoteLines : function(component) 
    {
        //alert("fetch quote lines");
        var action = component.get("c.fetchQuoteLines");
        action.setParams({ quoteId : component.get("v.quoteId"), parLocation : component.get("v.parLocation") });
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue())
                {
                    component.set("v.quoteLines", response.getReturnValue());
                }
            }
            else
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    copyMovePars : function(component, quoteLinesToCopyMove) 
    {
        console.log("parToListSelected--"+component.get("v.parToListSelected"));
        var action = component.get("c.copyMovePars");
        action.setParams({ quoteId : component.get("v.quoteId"), 
                          parLocation : component.get("v.parLocation"),
                          quoteLines : quoteLinesToCopyMove,
                          selectedPars : component.get("v.parToListSelected"),
                          copyMove : component.get("v.copyMove")});
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue())
                {
                    component.set("v.quoteLines", response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": "Selected Quotelines are Copied/Moved to the selected Pars."
                    });
                    toastEvent.fire();
                    component.set("v.isCopyMoveModalOpen", false);
                }
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
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    prepareParOptions : function(component) 
    {
        var parOptions =[];
        var quotePars = component.get("v.quotePars");
        var parLocation = component.get("v.parLocation");
        quotePars.forEach(function(eachPar){
            if(parLocation != eachPar.Par__c)
            parOptions.push({"label": eachPar.Par__c, "value": eachPar.Par__c, "selected": false});
        });
        console.log('parOptions--',parOptions);
        component.set("v.parOptions",parOptions);
    }
    
})