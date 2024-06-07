({
    doInit : function(component, event, helper) {
        var action = component.get("c.contractsignaturecheck");
        action.setParams({ conId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse == "false"){
                    component.set("v.disabled","true");
                    component.set("v.message","Booking team approval pending");
                }
                else if(storeResponse == "alreadysubmitted"){
                    component.set("v.disabled","true");
                    component.set("v.message","Already submitted / Booking team approval pending");
                }
            }
        });
        $A.enqueueAction(action);
    },                       
    
    sendforsignature : function(component, event, helper) {
        var action = component.get("c.getContractWf3");
        action.setParams({ conId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse[0] === "true"){
                    component.set("v.disabled","true");
                    component.set("v.message","Booking team approval pending");
                }else if(storeResponse[0] === "false"){
                    
                    //Added by Pavan kumar to generate the Adobe sign url for IBA-1266
                    // call helper method to generate Adobe Echo Sign URL
                    helper.getAdobeSignUrl(component, event, component.get("v.recordId"),storeResponse[1]);                    
                }
            }
        });
        $A.enqueueAction(action);
    }
})