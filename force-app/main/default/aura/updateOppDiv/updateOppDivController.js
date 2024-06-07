({
    doInit : function(component, event, helper) {
        var action = component.get('c.updateDiv');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var responseResult = response.getReturnValue();
            console.log("state="+state)
            component.set("v.Message","");
            
            console.log(responseResult);
            
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info',
                message: 'Batch is running at the Background',
                duration:' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'dismissible'
            });
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    }
})