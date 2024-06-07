({
    doInit : function(component, event, helper) 
    { 
        helper.fetchQuoteDetails(component, event);
    },
    navigateToAddNewPar : function(component, event, helper) 
    {
        helper.checkRevisionNumber(component);  //IBA-1845 Added new logic
        //helper.navigateToAddProductsComp(component); //IBA-1845 moved this call to helper
        /*
        var action = component.get("c.validateQuoteSync");
        action.setParams({ quoteId : component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                helper.navigateToAddProductsComp(component);
            }else{
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
        */
    }
})