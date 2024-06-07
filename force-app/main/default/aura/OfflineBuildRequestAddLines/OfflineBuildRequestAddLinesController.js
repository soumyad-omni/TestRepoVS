({
    init : function(component, event, helper) {   
        
        component.set('v.columns', [
            {label: 'Item Number', fieldName: 'SAP_Line_Number__c', type: 'text'},
            {label: 'Product', fieldName: 'ProductLink', type: 'url',typeAttributes: {label: { fieldName: 'ProductName' }, target: '_blank'}},
            {label: 'Pricing Reference Model', fieldName: 'ProductReferenceModelLink', type: 'url',typeAttributes: {label: { fieldName: 'PricingReferenceModelName' }, target: '_blank'}},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'number'},
            {label: 'PAR location', fieldName: 'Par_Location__c', type: 'text'}
        ]);
    },
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {            
            console.log("Record is loaded successfully.");            
        }
        
        helper.fetchQuoteLines(component,event);
    },
    
    updateSelectedRows : function(component, event, helper) {   
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for(var i = 0; i < selectedRows.length; i++ ) {            
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedLines", setRows);
        component.set('v.selectedRowsCount', selectedRows.length);
    },
        
    addLines : function(component, event, helper) {  
        component.set("v.addLinesClicked",true);
        helper.addLines(component, event);
    },
    
    cancel : function(component, event, helper) {   
        helper.redirectToOfflineBuildRequest(component, event);
    },    
})