({
    fetchQuoteLines : function(component, event) {
        var action = component.get("c.getQuoteLines");        
        action.setParams({ quoteId :component.get("v.buildRequest.Quote__c")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                records.forEach(function(record){                  
                    
                    if(record.Product__c != null){
                        record.ProductLink = '/'+record.Product__c;
                        record.ProductName = record.Product__r.Name; 
                    }
                    
                    if(record.Pricing_Reference_Model__c != null){
                        record.ProductReferenceModelLink = '/'+record.Pricing_Reference_Model__c;
                        record.ProductName = record.Pricing_Reference_Model__r.Name;
                    }
                });
                component.set("v.data", records);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    addLines : function(component, event) {
        
        var action = component.get("c.createOfflineBuildRequestLines");
        action.setParams({ quoteId :component.get("v.buildRequest.Quote__c"),recordId : component.get("v.buildRequest.Id"),quoteLines : component.get("v.selectedLines")});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                
                // throw success toast message at the top
                this.toastMessage(component, event);
                
                // redirect user to offline buid request
                this.redirectToOfflineBuildRequest(component, event);
            }else if(status === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage",errors[0]);
                        component.set("v.isError",true);
                        component.set("v.addLinesClicked",false);
                    }
                }            
            }
        });
        
        $A.enqueueAction(action);
    },
    
    toastMessage : function (component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Offline Build Request Lines are added successfully."
        });
        toastEvent.fire();
    },
    
    redirectToOfflineBuildRequest : function (component, event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})