({
	helperMethod : function() {
		
	},
    fetchFormDetails : function(component, event) 
    {
		var action = component.get("c.getFormDetails");
        action.setParams({ accountid : component.get("v.recordId")});
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.isButtonShow", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
	},
    navigateToFormPrintPageComp : function(component, event) 
    {
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:FormPrintPage",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
	}
})