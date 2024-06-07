({
	fetchQuotePars : function(component, event) 
    {
		var action = component.get("c.getQuotePar");
        action.setParams({ quoteId : component.get("v.recordId"), isOnload : "Yes" });
 
        action.setCallback(this, function(response){
            component.set("v.showSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.parList", response.getReturnValue());
                if(response.getReturnValue())
                {
                    component.set("v.quoteNumber", response.getReturnValue()[0].Quote__r.Quote_Number__c);
                    component.set("v.selectedParForQuote",response.getReturnValue()[0].Par__c);
                    var childCmp = component.find("addProductForQuoteCmp");
                    childCmp.sampleMethod(response.getReturnValue()[0].Par__c);
                }
            }
            else
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    saveQuotePar : function(component, event) 
    {
		var action = component.get("c.createQuotePar");
        action.setParams({ quoteId : component.get("v.recordId"),
                          newQuotePars: component.get("v.newParList")});
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.parList", response.getReturnValue());
                component.set("v.isAddParModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Quote Par are created/updated."
                });
                toastEvent.fire();
                var refreshEvent = $A.get("e.c:QuoteLinesRefresh");
                refreshEvent.fire();
            }
            else
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    renameParSave : function(component, event) 
    {
		var action = component.get("c.renameQuotePar");
        action.setParams({ quoteId : component.get("v.recordId"),
                          renameQuoteParMap: component.get("v.renamePar")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.parList", response.getReturnValue());
                component.set("v.isRenameModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Quote Par is renamed."
                });
                toastEvent.fire();
                var refreshEvent = $A.get("e.c:QuoteLinesRefresh");
                refreshEvent.fire();
                var childCmp = component.find("addProductForQuoteCmp");
                childCmp.sampleMethod(component.get("v.renamePar"));
            }
            else
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    deleteParHelper : function(component, event) 
    {
		var action = component.get("c.deleteQuotePar");
        action.setParams({ quoteId : component.get("v.recordId"),
                          deleteQuoteParMap: component.get("v.deletePar")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.parList", response.getReturnValue());
                component.set("v.isDeleteModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Quote Par is deleted."
                });
                toastEvent.fire();
                var refreshEvent = $A.get("e.c:QuoteLinesRefresh");
                refreshEvent.fire();
            }
            else
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    saveInterim : function(component) 
    {
		var action = component.get("c.saveInterimOff");
        action.setParams({ quoteId : component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                console.log('state----: success');
                var shwmsg = response.getReturnValue();
                console.log('Response---: ', shwmsg);
                if(shwmsg == true) {
                    var msg = 'This configuration is reserved for Institutional Pharmacy customers only.  Approval required by NAC � Dir. of Sales';
                    var tEvent = $A.get("e.force:showToast");
                    tEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": msg
                    });
                    tEvent.fire();
                }else{
                	var navEvt = $A.get("e.force:navigateToSObject");
                	navEvt.setParams({
                    	"recordId": component.get("v.recordId"),
                    	"slideDevName": "related"
                	});
                	navEvt.fire();
                }
            }
            else
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log("Error message: " + errors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})