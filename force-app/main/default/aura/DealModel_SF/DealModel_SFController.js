({ 
   /*  //Code for mobile functionality starts here
    onInit : function(component, event, helper) {
       var myPageRef = component.get("v.pageReference");
        console.log('===@@@pageref====',myPageRef);
        
        //Get the recordId from the PageReference
        let pr = component.get("v.pageReference");
        if (pr && pr.state && pr.state.recordId) {
            component.set('v.recordId', pr.state.recordId);
        }
        
        helper.getData(component, event);
    }*/ //Code for Mobile Functioanlity ends here
    
	openDealCalculator : function(component, event, helper) {
		component.set('v.showDealCalculator',true);
        helper.initCmp(component, event);
	},
    closeDealCalculator : function(component, event, helper) {
		component.set('v.showDealCalculator',false);
        var childComp = component.find('childComp');
        childComp.callReset();
    },
    toggleSection : function(component, event, helper){
        helper.toggleSection(component, event);
	},
    calculateDiscount : function(component, event, helper){
        helper.calculateDiscount(component, event);
    },
    reset : function(component, event, helper){
        helper.reset(component, event);
        var childComp = component.find('childComp');
        childComp.callReset();
    },
    savePDF : function(component, event, helper){
        helper.savePDF(component, event);
    },
    save : function(component, event, helper){
        helper.save(component, event);
    },
    isNumberKey : function(component, event, helper){
        helper.isNumberKey(component, event);
    },
    onKeyUp: function(component, event, helper){
        helper.onKeyUp(component, event);
    },
    handleResetEvent : function(cmp, event,helper) {
        helper.reset(cmp, event);
    },
    handleDiscountEvent : function(cmp, event,helper) {
        helper.calculateDiscount(cmp, event);
    }
    
})