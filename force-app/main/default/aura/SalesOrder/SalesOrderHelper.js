({
	InvokeClass : function(component,event,helper) {
		
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Quote Conversion Started. Please check back in few minutes. Do not click the button again",
            "type": "success"
        });
        toastEvent.fire();        
		
		//var action = component.get("c.updateCheck");
		var action = component.get("c.callOutMethod");
        action.setParams({quoteId : component.get("v.recordId") });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        
        
	},
            fetchquotedetails : function(component, event) 
    {
		var action = component.get("c.getquotedetails");
        action.setParams({ quoteId : component.get("v.recordId")});
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.isButtonShow", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
	}
})