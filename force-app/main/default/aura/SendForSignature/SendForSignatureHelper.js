({ 
    //Added by Pavan kumar to generate the Adobe sign url for IBA-1266
    getAdobeSignUrl : function(component, event,recordId,templateId) {        
        var action = component.get("c.getAdobeSignUrl");
        action.setParams({ recordId : recordId,templateId : templateId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var adobeUrl = response.getReturnValue();
                component.set("v.message","Quote Signature");
                console.log(component.get("v.message"));
                console.log('TEMPLATE ID',templateId);
                console.log('adobeUrl',adobeUrl);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": adobeUrl
                });
                urlEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})