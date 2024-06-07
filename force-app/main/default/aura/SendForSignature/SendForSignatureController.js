({
	doInit : function(component, event, helper) {
        console.log("Inside js");
		var action = component.get("c.getQuote");
        action.setParams({ conId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log("Store response : "+storeResponse);
                //component.set("v.contract", storeResponse);
                //console.log("Status: "+storeResponse);
                //var con = component.get("v.contract");
                //console.log("Contract"+component.get("v.contract"));
                console.log(storeResponse[0]);
                if(storeResponse[0] === "NoQuoteApproval"){
                    component.set("v.message","No Quote Approval Found");
                }
                else if(storeResponse[0] != "NotApproved" && storeResponse[1] != "NotSupplementQuote"){
                 /*   var url="/apex/echosign_dev1__AgreementTemplateProcess?masterid="+component.get("v.recordId")+"&templateId="+storeResponse[0];
                        console.log("URL : "+url);
                    component.set("v.message","Quote Signature");
                    console.log(component.get("v.message"));
                    window.location = url; */
                  helper.getAdobeSignUrl(component, event, component.get("v.recordId"),storeResponse[0]);    
                    
                }
                else if(storeResponse[1] === "NotSupplementQuote"){
                    component.set("v.message","Not a supplement Quote");
                }
                else
                    component.set("v.message","Quote Not Approved");
            }
        });
        $A.enqueueAction(action);
	}
})