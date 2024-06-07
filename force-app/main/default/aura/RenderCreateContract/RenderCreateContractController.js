({
	doInit : function(component, event, helper) {
        console.log("Inside js");
		var action = component.get("c.getContract");
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
                debugger; 
                console.log("Storeresponse 0 "+storeResponse[0]);
                console.log("Storeresponse 1 "+storeResponse[1]);
                console.log("Storeresponse 2 "+storeResponse[2]);
                console.log("Storeresponse 3 "+storeResponse[3]);
                console.log("Storeresponse 4 "+storeResponse[4]);
                console.log("Storeresponse 5 "+storeResponse[5]);
                console.log("Storeresponse 6 "+storeResponse[6]);
                if (storeResponse[6] != 'Valid User') {
                    component.set("v.message","Not a Booking Team User");
                    return; 
                }
                
                if(storeResponse[0] === 'Approved'){
                    var url="/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl="+storeResponse[3]+"&Id="+
                        component.get("v.recordId")+"&SC0=1&SC1=SalesforceFile&templateid="+storeResponse[2]+"&DS6&DS7=11&DS0=1&DS4=1&DataTagEnable=1&APDF=1&DefaultPDF=1&OFN="+storeResponse[1]+".CSN"+storeResponse[7]+"."+storeResponse[8]+"."+"{Template.Label}"+".cPrintout";//IBA-6018
                    console.log("URL : "+url);
                    component.set("v.message","Creating Contract");
                    window.location = url;
                }
                else
                    component.set("v.message","Contract Not Approved");
            }
        });
        $A.enqueueAction(action);
	}
})