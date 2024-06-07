({
	doInit : function(component,event,helper){ 
        var queues = [];
        var chaction = component.get("c.getChRecordId");
        chaction.setParams({ qId : component.get("v.recordId") });
        chaction.setCallback(this, function(response) {
            var stateCh = response.getState();
            if (stateCh === "SUCCESS") {
                var storeResponseCh = response.getReturnValue();
                if(storeResponseCh === 'noid'){
                    component.set("v.chId","false");
                }
                else{
                	component.set("v.chrecordId",storeResponseCh);
                    component.set("v.chId","true");
                	console.log("Chevron Id : "+component.get("v.chrecordId"));
                }
             }
        });
        $A.enqueueAction(chaction);
        
        var isPending = false;
        var action = component.get("c.getPendingQueues");
        action.setParams({ qaId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.Pendingqueues",storeResponse);
                //console.log("Storeresponse length : "+storeResponse.length);
                queues.push(storeResponse);
                /*for(var i = 0;i<storeResponse.length;i++){
                	queues.push(storeResponse[i]);    
                	console.log("Queues----------------------"+queues[i]);
                }*/
                console.log("Queues----------------------"+queues);
                console.log("Pending Queues : "+component.get("v.Pendingqueues"));
            }
        });
        $A.enqueueAction(action);
        var action2 = component.get("c.getApprovedQueues");
        action2.setParams({ qaId : component.get("v.recordId") });
        action2.setCallback(this, function(response) {
            var state2 = response.getState();
            if (state2 === "SUCCESS") {
                 var arrayOfMapKeys = [];
                // store the response of apex controller (return map)     
                var StoreResponse2 = response.getReturnValue();
                console.log('StoreResponse' + StoreResponse2);
                // set the store response[map] to component attribute, which name is map and type is map.   
                component.set('v.fullMap', StoreResponse2);
 
                for (var singlekey in StoreResponse2) {
                    arrayOfMapKeys.push(singlekey);
                }
                // Set the all list of keys on component attribute, which name is lstKey and type is list.     
                component.set('v.lstKey', arrayOfMapKeys);
                
            }
        });
        $A.enqueueAction(action2);
		var action3 = component.get("c.getRejectedQueues");
        action3.setParams({ qaId : component.get("v.recordId") });
        action3.setCallback(this, function(response) {
            var state3 = response.getState();
            if (state3 === "SUCCESS") {
                var arrayOfMapKeys1 = [];
                // store the response of apex controller (return map)     
                var StoreResponse3 = response.getReturnValue();
                console.log('StoreResponse' + StoreResponse3);
                // set the store response[map] to component attribute, which name is map and type is map.   
                component.set('v.fullMap1', StoreResponse3);
 
                for (var singlekey in StoreResponse3) {
                    arrayOfMapKeys1.push(singlekey);
                }
                // Set the all list of keys on component attribute, which name is lstKey and type is list.     
                component.set('v.lstKey1', arrayOfMapKeys1);
            }
        });
        $A.enqueueAction(action3);
        var action4 = component.get("c.getApprovedDate");
        action4.setParams({ qaId : component.get("v.recordId") });
        action4.setCallback(this, function(response) {
            var state4 = response.getState();
            if (state4 === "SUCCESS") {
                var storeResponse4 = response.getReturnValue();
                component.set("v.ApprovedDates",storeResponse4);
                console.log("Approved Dates : "+component.get("v.ApprovedDates"));
            }
        });
        $A.enqueueAction(action4);
        
        var action5 = component.get("c.getQueuesNotStarted");
        action5.setParams({ qaId : component.get("v.recordId") });
        action5.setCallback(this, function(response) {
            var state5 = response.getState();
            if (state5 === "SUCCESS") {
                var storeResponse5 = response.getReturnValue();
                component.set("v.queuesnotstarted",storeResponse5);
                console.log("Not Started Queues : "+component.get("v.queuesnotstarted"));
            }
        });
        $A.enqueueAction(action5);
        
        /*var action6 = component.get("c.updateAssignedto");
        action6.setParams({ qaId : component.get("v.recordId")});
        action6.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Quote Approval Record Updated");
            }
        });
        $A.enqueueAction(action6);*/

    },
    
    handleSelect : function (component, event, helper) {
    	var toastEvent = $A.get("e.force:showToast");
               		toastEvent.setParams({
                    "title": "Warning!",
                    "message": "Status of Approval can be changed through the approval history related list only"
                });
                toastEvent.fire();
         var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                navigateEvent.fire();
    }
})