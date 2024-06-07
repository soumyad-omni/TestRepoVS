({
    doInit : function(component, event, helper) {
        var action = component.get('c.updateSegment');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var responseResult = response.getReturnValue();
            console.log("state="+state)
            component.set("v.Message","");
            
           
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})