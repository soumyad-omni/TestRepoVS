({
	doInit : function(component, event, helper) {
        console.log("Inside js");
        var url;
		var action = component.get("c.getContract");
        action.setParams({ conId : component.get("v.recordId") });
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
                console.log(storeResponse[0]);
               
                    url ="/apex/APXTConga4__Conga_Composer?SolMgr=1?"+storeResponse[3]+"&Id="+
                        component.get("v.recordId")+"&templateid="+storeResponse[2]+"&emailadditionalto="+storeResponse[5]+"&EmailTemplateId="+storeResponse[4]+"&DS7=2&QMode=SendEmail&AC0=0&LG4=0";
                    console.log("URL : "+url);
             }
        });
        $A.enqueueAction(action);
		var action1 = component.get("c.getUser");
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
                    component.set("v.message","Sending Email");
                    window.location = url;
                }
                else
                    component.set("v.message","Not a Booking Team User");
             }
        });
        $A.enqueueAction(action1);	
    }
})