({
	higherleveiItem_helper: function(component, event, helper) {
      
         var action = component.get('c.fetchQuoteLine');
         action.setParams({quoteId : component.get("v.recordId") });
         action.setCallback(this, function(response) {
      //store state of response
         var state = response.getState();
         if (state === "SUCCESS") {
         var storeResponse = response.getReturnValue();
      //set response value in HigherLevel attribute on component.
             component.set("v.HigherLevel", storeResponse);
        }
  });
  $A.enqueueAction(action);
},
    
  BaseURL_helper: function(component, event, helper) {
      
         var action = component.get('c.baseURL');
         action.setParams({quoteId : component.get("v.recordId") });
         action.setCallback(this, function(response) {
      //store state of response
         var state = response.getState();
         if (state === "SUCCESS") {
         var storeResponse = response.getReturnValue();
      //set response value in BaseURL attribute on component.
             component.set("v.BaseURL", storeResponse);
             console.log('baseurl...'+storeResponse);
        }
  });
  $A.enqueueAction(action);
}, 
    legacycreateddate: function(component, event, helper) {
      
         var action = component.get('c.legacycreateddate');
         action.setParams({quoteId : component.get("v.recordId") });
         action.setCallback(this, function(response) {
      //store state of response
         var state = response.getState();
         if (state === "SUCCESS") {
         var storeResponse = response.getReturnValue();
      //set response value in HigherLevel attribute on component.
             component.set("v.legCrDate", storeResponse);
        }
  });
  $A.enqueueAction(action);
}
    
    /*updatelockedcheckbox_helper : function(component,event,helper) {
		
		var action = component.get("c.updateCheck");
        action.setParams({quoteId : component.get("v.recordId") });
        
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        
	}*/
})