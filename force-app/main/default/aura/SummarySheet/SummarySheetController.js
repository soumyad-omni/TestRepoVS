({
	doInit : function(component, event, helper) {
        console.log("Inside js");
        component.set("v.ObjectType","QuoteApproval");
        var url;
		var action = component.get("c.getQuoteApproval");
        action.setParams({ qaId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State : "+response.getState());
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("Store response : "+storeResponse);
                //component.set("v.contract", storeResponse);
                //console.log("Status: "+storeResponse);
                //var con = component.get("v.contract");
                //console.log("Contract"+component.get("v.contract"));
                console.log(storeResponse[2]);
               
                    url ="/apex/APXTConga4__Conga_Composer?SolMgr=1?"+storeResponse[1]+"&Id="+
                        component.get("v.recordId")+"&SelectTemplates=0&templateid="+storeResponse[2]+"&QMode=SalesforceFile&DS7=2&WDP=1&OFN="+storeResponse[0];
                    console.log("URL : "+url);
             }
        });
        $A.enqueueAction(action);
		var action1 = component.get("c.getUserBooking");
        //action1.setParams({ conId : component.get("v.recordId") });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State : "+response.getState());
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("Store response : "+storeResponse);
                //component.set("v.contract", storeResponse);
                //console.log("Status: "+storeResponse);
                //var con = component.get("v.contract");
                //console.log("Contract"+component.get("v.contract"));
                console.log(storeResponse[0]);
               if(storeResponse === "true"){
                    component.set("v.message","Generating Smart Sheet");
                    window.location = url;
                }
                else
                    component.set("v.message","Not a Booking Team User");
             }
        });
        $A.enqueueAction(action1);	
    }
})