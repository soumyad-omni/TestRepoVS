({
    doInit : function(component, event, helper) {
        var action = component.get('c.createChildRecord');
        action.setParams({
            "quoteId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("state="+state)
            if (state === "SUCCESS"){
                var response = response.getReturnValue();
                if(response != ''){
                    window.location ="/"+response;
                }
                else{
                    component.set("v.Message",response);
                }
            }
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    }
})