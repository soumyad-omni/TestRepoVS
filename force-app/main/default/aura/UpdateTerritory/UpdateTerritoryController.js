({
    doInit : function(component, event, helper) {
        var action = component.get('c.updateTerritory');
        action.setParams({
            "accountId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var responseResult = response.getReturnValue();
            console.log("state="+state)
            component.set("v.Message","");
            component.set("v.isNotAdminUser",responseResult);
            console.log(responseResult);
            var isNotAdminUser = component.get("v.isNotAdminUser");
            console.log(isNotAdminUser);
            if(isNotAdminUser == true)
            {
                 var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"message": "Only Business Admins and System Administrators can change owner of an account.",
                        "duration": 30000    
                	});
                 toastEvent.fire();
            }
           
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})