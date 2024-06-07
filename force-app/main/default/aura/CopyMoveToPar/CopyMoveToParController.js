({
    doInit: function(component, event, helper) {
        helper.fetchQuoteLines(component);
        helper.prepareParOptions(component);
        component.set('v.columns', [
            {label: 'Product', fieldName: 'Product_Code__c', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'number'},
            {label: 'Par Location', fieldName: 'Par_Location__c', type: 'text'}
        ]);
    },
    getQuoteLines: function(component, event, helper) {
        helper.fetchQuoteLines(component);
        helper.prepareParOptions(component);
    },
	closeModal: function(component, event, helper) {
        component.set("v.isCopyMoveModalOpen", false);
    },
    copyMoveAll: function(component, event, helper) {
        var selectedToPar = component.get("v.parToListSelected");
        //alert(selectedToPar);
        if(!selectedToPar || selectedToPar.length==0)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message": "select atleast one par To."
            });
            toastEvent.fire();
        }else
        {
            helper.copyMovePars(component, component.get("v.quoteLines"));
        }
    },
    copyMoveSelected: function(component, event, helper) {
        var selectedToPar = component.get("v.parToListSelected");
        var selectedQuoteLines = component.find("quoteLineTable").getSelectedRows();
        if(!selectedToPar || selectedToPar.length==0)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message": "select atleast one par To."
            });
            toastEvent.fire();
        }else if(!selectedQuoteLines || selectedQuoteLines.length==0)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message": "select atleast one Quote Line."
            });
            toastEvent.fire();
        }else
        {
            helper.copyMovePars(component, selectedQuoteLines);
        }
        //alert(selectedToPar);
        //component.set("v.isCopyMoveModalOpen", false);
    },
    handleSelectedToPar: function(component, event, helper) {
        var parToList = event.getParam("values");
        console.log('parToList--',parToList);
        component.set("v.parToListSelected", parToList);
    }
})