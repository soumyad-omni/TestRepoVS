({
	fetchQuoteDetails : function(component, event) 
    {
		var action = component.get("c.getQuoteDetails");
        action.setParams({ quoteId : component.get("v.recordId")});
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.isButtonShow", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
	},
    navigateToAddProductsComp : function(component, event) 
    {
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddNewPar",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
	},
    //IBA-1845 Added new logic
    checkRevisionNumber : function(component, event) 
    {
        var action = component.get("c.compareRevisionNumber");
        action.setParams({ quoteId : component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() == true) {
                    this.navigateToAddProductsComp(component);
                }else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "",
                        "type":"info",
                        "mode": "sticky",
                        "message":"Quote is being synced from SAP. Refresh the page to try again after a few minutes."
                    });
                    toastEvent.fire();
                }
            } else {
                console.log('inside error...');
                var errors = response.getError();
                console.log('error : '+response.getError()+' '+errors[0].message);
                //this.showToast(errors[0].message, 'Error Message', 'error');
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "",
                        "type":"Error",
                        "mode": "sticky",
                        "message":"Revision Check Process failed."
                    });
                    toastEvent.fire();
            }           
        });
        $A.enqueueAction(action);
    },
})