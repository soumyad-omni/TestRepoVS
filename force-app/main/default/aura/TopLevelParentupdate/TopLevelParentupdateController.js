({
    doInit : function(component, event, helper) {
        var action = component.get('c.updateTopLevelParent');
        action.setParams({
            "accountId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("state="+state)
            if (state === "SUCCESS"){
                var response = response.getReturnValue();
                if(response === "Updated"){
                    component.set("v.Message",response);
                    //Success message display logic.
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Account Team has been updated successfully."
                    });
                    toastEvent.fire();
                    window.location ="/"+component.get("v.recordId");
                }
                else{
                    component.set("v.Message",response);
                }
            }else if (state === "INCOMPLETE") {
                //Offline message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "OFFLINE!",
                    "message": "You are in offline."
                });
                toastEvent.fire();
            }else if (state === "ERROR") {
                //Error message display logic.
                var errors = response.getError();
                console.log("error in Save"+errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "message": errors[0].message
                });
                toastEvent.fire();
            }else {
                //Unknown message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "UNKOWN!",
                    "message": "Unknown error."
                });
                toastEvent.fire();
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})