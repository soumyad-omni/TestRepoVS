({
	schedule : function(component, event, helper) {
        alert("Batch will be processed to default the opportunityteam.");
        var action = component.get('c.scheduleBatch');
        action.setCallback(this, function(response){
        	var state = response.getState();
        if(state === "SUCCESS"){           
            var nextFireTime = response.getReturnValue();
            alert("The Batch is Processing...");
        }else if(state === "ERROR"){
            var errors = response.getError();
            if(errors){
                if(Array.isArray(errors) && errors.length > 0){
                    console.log('Error Message :-'+errors[0].message);
                }else{
                    console.log('Unknown error');
                }
            }
        }
        });
        $A.enqueueAction(action);           
	}
})