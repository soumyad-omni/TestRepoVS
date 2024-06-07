({
    AccountSegmentSync : function(component, event, helper) {
        var action = component.get('c.updateTiExtDataAcctSeg');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("state="+state)
            if(state === "SUCCESS"){           
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Account Segment update batch is processing."
                });
                toastEvent.fire();
                
            }else if(state === "ERROR"){
                var errors = response.getError();
                console.log("error in processing "+errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "message": errors[0].message
                });
                toastEvent.fire();   
            } else{
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