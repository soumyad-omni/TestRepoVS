({
	onInit : function(component, event) {
		var action = component.get("c.getApplixAssetSummarys");
        action.setParams({ accountId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.lstApplixAssetSummary',response.getReturnValue());
            }
            else {
                var errors = response.getError();
                this.showToast(errors[0], 'Error Message', 'error');
            }
        });
        $A.enqueueAction(action);
	},
    showToast : function(errorMsg, title, toastType) {

        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                title : title,
                message: errorMsg,
                type: toastType
            });
            toastEvent.fire();
        }else{
            alert(errorMsg);
        }
    },
})