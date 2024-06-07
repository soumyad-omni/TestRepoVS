({
	doInit : function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        console.log('Event '+evt);
        var markservreqId = component.get("v.recordId");
        console.log("Id mark : "+markservreqId);
        evt.setParams({
            componentDef  : "c:NewCampaignOverride",
            componentAttributes : {
                marketingservreq : markservreqId
            }
        });
        evt.fire();
}
})