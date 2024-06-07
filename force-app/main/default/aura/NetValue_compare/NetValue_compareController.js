({
    doInit : function(component, event, helper){
    var action = component.get('c.isrendered');
    
    action.setParams({ "key" : component.get("v.recordId") });
    action.setCallback(this,function(result){
        component.set('v.rendered',result.getReturnValue());
         console.log(result.getReturnValue());
    });
      $A.enqueueAction(action);
              
    },
    comp : function (component, event, helper) {
        
        var action = component.get('c.getvalue');
        
        var success = $A.get("e.force:showToast");
        success.setParams({
            "title": "Success!",
            "message": "Please refresh the page to see the changes.",
            "type": "success"
        });
        
        var failure = $A.get("e.force:showToast");
        failure.setParams({
            "title": "Failure!",
            "message": "Error retrieving Sales Order net value.",
            "type": "error"
        });
    
        action.setParams({ "key" : component.get("v.recordId") });
        action.setCallback(this,function(result){
            component.set('v.flag',result.getReturnValue());
         	console.log(result.getReturnValue());
            var state = result.getReturnValue();
            if (state === true) {
                success.fire();
            }
            else {
                failure.fire();
            }
        });
          $A.enqueueAction(action);
    }
});