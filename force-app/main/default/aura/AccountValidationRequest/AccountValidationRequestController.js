({
    doInit: function(component) {
        var intRecType = component.get("v.recordId"); 
        //alert('**** intRecType ' + intRecType);
        var action = component.get('c.getAccInitValue');
        action.setParams({ 'sAccId' : intRecType });
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert('**** state ' + state);
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                if(!result.acc.Require_Review__c)
                {
                    result.acc.Request_Comment__c = '';
                }
                component.set('v.obj', result);
                console.log(component.get('v.obj'));
                
            }
        });
		$A.enqueueAction(action);
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    onRecordSuccess : function(component, event, helper) {
        // Navigate back to the record view
        /*var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
        var inputCmp = component.find("inputCmp");
        var value = inputCmp.get("v.value");  
        
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
         var cmpTarget = cmp.find('MainDiv');
        $A.util.removeClass(cmpTarget, 'slds-modal__container');
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Request Response',
            message: 'An Email Notification Sent to Account Validation Team',
            duration:'4000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();*/
        
    },
    onRecordSubmit: function(component, event, helper) {
        component.set("v.Submitdisabled",true);
        //component.set('v.obj.acc.Request_Comment__c', component.get('v.comment'));
		var action = component.get('c.updateAccountValue');
        action.setParams({ 'acc' : component.get('v.obj').acc });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('**** state ' + state);
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == 'SUCCESS')
                {
                    // Navigate back to the record view
                    var navigateEvent = $A.get("e.force:navigateToSObject");
                    navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                    navigateEvent.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Request Response',
                        message: 'An Email Notification Sent to Account Validation Team',
                        duration:'4000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Request Response',
                        message: result,
                        duration:'4000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors[0]);
                if (errors) {
                    errors.forEach(function myFunction(item) {
                        console.log(item);
                        console.log(item[0]);
                    });
                }
            }
        });
		$A.enqueueAction(action);
    },
    handleCancel : function(component, event, helper) {
        /*var cmpTargetForEdit = component.find('editForm');
        $A.util.removeClass(cmpTargetForEdit, 'slds-fade-in-open');*/
    }
    
})