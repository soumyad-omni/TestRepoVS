({
    doInit : function(component, event, helper){
        /*var checkjob = component.get("c.checkfuturejob");
        //checkjob.setParams({ "qId" : component.get("v.recordId") });
        checkjob.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var storeresponse = response.getReturnValue();
                if(storeresponse === true){
                	component.set("v.disabled","true");
            		component.set("v.message","Cast Iron job is running. Please wait.");
                    //helper.dojobcheck(component,event,helper);
                }
            }
            else{
                component.set("v.disabled","false");
                component.set("v.message","");
                console.log('failed check job');
            }
        });
        $A.enqueueAction(checkjob);*/
        
        var checkstat = component.get("c.checkStatus");
        checkstat.setParams({ "qId" : component.get("v.recordId") });
        checkstat.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var storeresponse = response.getReturnValue();
                if(storeresponse === true){
                    component.set("v.disabled","true");
                }
            }
        });
        $A.enqueueAction(checkstat);
    },
    sendQuote : function(component, event, helper) {
        var checkrev = component.get("c.getRevisionNum");
        checkrev.setParams({ "qId" : component.get("v.recordId") });
        checkrev.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var storeresponse = response.getReturnValue();
                if(storeresponse === true){
                    console.log('not sending');
                }
                else{
                    var checkjob = component.get("c.checkfuturejob");
                    checkjob.setParams({ "qId" : component.get("v.recordId") });
                    checkjob.setCallback(this, function(response) {
                        var state = response.getState();
                        if(state === "SUCCESS") {
                            var storeresponse = response.getReturnValue();
                            if(storeresponse === true){
                                //component.set("v.disabled","true");
                                component.set("v.message","Sync is currently running");
                            }
                            else{
                                console.log('sending');
                                helper.dojobcheck(component,event,helper);
                            }
                        }
                        else{
                            component.set("v.disabled","false");
                            component.set("v.message","");
                            console.log('failed check job');
                        }
                    });
                    $A.enqueueAction(checkjob);
                    
                }
            }
        });
        $A.enqueueAction(checkrev);
    }
})