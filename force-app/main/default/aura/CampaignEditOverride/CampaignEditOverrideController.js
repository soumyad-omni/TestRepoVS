({
    doInit : function(component, event, helper) {
        
       var action = component.get("c.getStatus");
        action.setParams({ campId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.checkUser", storeResponse);
                console.log("Status: "+storeResponse);
            }
        });
        $A.enqueueAction(action);
        
    },
	
    onSave : function(component, event, helper) {
        
                // Navigate back to the record view
                var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                navigateEvent.fire();
           
	},
    onCancel : function(component, event, helper) {
    
        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    },
    //1913-Start
    submit : function(component, event, helper) {
        var type = component.find("typeId").get("v.value");
        //var subType = component.find("campSubTypeId").get("v.value");
        var campReg = component.find("campRegId").get("v.value");
        var marketPortfolioSegment = component.find("marketPSId").get("v.value");
        if(type != 'Program'){
            //console.log(campReg);
            //console.log(marketPortfolioSegment);
            if($A.util.isEmpty(campReg) || $A.util.isEmpty(marketPortfolioSegment)){
                console.log('Issues with null');
                var msg = 'Campaign Region, Market Portfolio Segment fields needs to be filled to proceed further';
                var tEvent = $A.get("e.force:showToast");
                tEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": msg
                });
                tEvent.fire();
            }else{
                component.find("Edit").submit();
                var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                navigateEvent.fire();
                console.log('else');
            }
        }else{
            component.find("Edit").submit();
            var navigateEvent = $A.get("e.force:navigateToSObject");
            navigateEvent.setParams({ "recordId": component.get('v.recordId') });
            navigateEvent.fire();
            console.log('else');
        }
    }
    //1913-Ends
})