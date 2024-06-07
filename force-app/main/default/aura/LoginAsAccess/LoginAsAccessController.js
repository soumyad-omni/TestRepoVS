({
    doInit : function(component, event, helper) 
    { 
        helper.checkLoginAsAccessAssigned(component); 
    },
    loginAsAccess : function(component, event, helper) 
    {
        helper.loginAsAccess(component);  
    }
})