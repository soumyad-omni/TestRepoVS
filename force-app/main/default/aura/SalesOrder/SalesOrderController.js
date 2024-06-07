({
	    doInit : function(component, event, helper) 
    { 
    	helper.fetchquotedetails(component, event);
    },
    buttonAction : function(component, event, helper) {
        helper.InvokeClass(component,event,helper);
        //let button = event.getSource();
        //button.set('v.disabled',true);
	}
})