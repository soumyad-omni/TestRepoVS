({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Product Code', fieldName: 'Product_Code__c', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'number'},
            {label: 'Par Location', fieldName: 'Par_Location__c', type: 'text'}
        ]);
    },
	closeModal: function(component, event, helper) {
        component.set("v.isCopyConfigModalOpen", false);
    },
    handleSearch: function(component, event, helper) {
        component.set("v.isSearching", true);
        helper.doSearch(component);
    },
    copyAll: function(component, event, helper) {
        var quoteLines = component.get("v.matchQuoteLines");
        helper.copyQuoteLinesToSource(component, quoteLines);
    },
    copySelected: function(component, event, helper) {
        var quoteLines = component.find("matchingQuoteLineTable").getSelectedRows();
        if(quoteLines && quoteLines.length>0){
            helper.copyQuoteLinesToSource(component, quoteLines);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message": "Please select atleast one quote line to copy."
            });
            toastEvent.fire();
        }
    },
})