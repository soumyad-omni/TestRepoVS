(
    {
        checkLoginAsAccessAssigned : function(component,event){
            var action = component.get("c.isLoginAccessPermAssigned");
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    component.set("v.isButtonShow", response.getReturnValue());
                }            
            });
            $A.enqueueAction(action);
        },   
        
        loginAsAccess : function(component, event) {
            var action = component.get("c.grantLoginAsAccess");
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    // $A.get('e.force:refreshView').fire(); 
                    component.set("v.isButtonShow", response.getReturnValue());
                }            
            });
            $A.enqueueAction(action);
        }
    })