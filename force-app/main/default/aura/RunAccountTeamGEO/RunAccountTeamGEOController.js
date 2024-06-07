({
	doInit : function(component, event, helper) {
        console.log("Inside doInit");
        var action = component.get("c.runAccountTeamBatch");
        //action.setParams({ campId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("Success");
                var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                navigateEvent.fire();
                //component.set("v.checkUser", storeResponse);
                //console.log("Status: "+storeResponse);
            }
        });
        $A.enqueueAction(action);
	}
})