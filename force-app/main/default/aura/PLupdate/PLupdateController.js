({
    doInit : function(component, event, helper) {
        var action = component.get('c.startPLcalc');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var responseResult = response.getReturnValue();
            console.log("state="+state)
            component.set("v.Message","");
            
            
                 var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"message": "Product Line update Batch submitted!",
                        "duration": 30000    
                	});
                 toastEvent.fire();
            
           
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})