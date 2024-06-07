({
	doInit : function(component, event, helper) {
        var action = component.get("c.getError");
        action.setParams({ "aId" : component.get("v.recordId") });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state === "SUCCESS"){
                component.set("v.obj",result.getReturnValue());   
            }
        });
        $A.enqueueAction(action);
        
        
    }
})