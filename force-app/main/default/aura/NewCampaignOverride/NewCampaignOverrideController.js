({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
    },
    createRecord : function (component, event, helper) {
        console.log("Id : "+ component.get("v.marketingservreq"));
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Campaign",
            "defaultFieldValues"    : {
         		"Campaign_Approval__c" : component.get("v.marketingservreq")
			}  
            
        });
        createRecordEvent.fire();
    }
})