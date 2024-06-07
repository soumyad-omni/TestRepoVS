({
	onInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        console.log('===@@@pageref====',myPageRef);
        
        //Get the recordId from the PageReference
        let pr = component.get("v.pageReference");
        if (pr && pr.state && pr.state.recordId) {
            component.set('v.recordId', pr.state.recordId);
        }
        
        helper.getData(component, event);
    },
    navigateToViewAll : function(component, event, helper) {
        helper.navigateToViewAll(component, event);
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    handleOpenButtonClick: function(cmp, event, helper) {
        cmp.set("v.isOpen", !cmp.get("v.isOpen"));
    }    
})