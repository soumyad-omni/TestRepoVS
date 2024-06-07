({
    doInit : function(component, event, helper) 
    { 
        helper.fetchFormDetails(component, event);
    },
    navigateToFormPrintPage : function(component, event, helper) {
        helper.navigateToFormPrintPageComp(component);
    }
})