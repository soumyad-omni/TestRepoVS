({
    doInit : function(component, event, helper) 
    { 
        //component.set("v.recordId","0Q00r0000006kJ7CAI");
        helper.fetchQuotePars(component, event);
        //var parList = ["Par 1"];
        //component.set("v.parList", parList);
    },
    navigateToQuote : function(component, event, helper) 
    { 
        helper.saveInterim(component);
        /*
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
        */
    },
    navigateToRecord : function(component, event, helper) 
    { 
		var parName = event.getSource().get("v.value");
        component.set("v.selectedParForQuote",parName);
        var childCmp = component.find("addProductForQuoteCmp");
        childCmp.sampleMethod(parName);
        /*//alert(parName);
        var aa = "'"+parName+"'";
        var cmpDiv = event.getSource();
        //alert(cmpDiv);
        $A.util.addClass(parName, 'changeStyle');*/
    },
    copyConfigFromQuote : function(component, event, helper) 
    { 
        //Add Copy Configuration from Quote logic
        component.set("v.isCopyConfigModalOpen", true);
        component.find("CopyConfigFromQuote").set("v.matchingQuoteId",null);
        component.find("CopyConfigFromQuote").set("v.searchKey",'');
        component.find("CopyConfigFromQuote").set("v.matchQuoteLines", []);
    },
    dealCalculator : function(component, event, helper) 
    { 
        //Add Deal Calculator
    },
    massChangeProduct : function(component, event, helper) 
    { 
        //Add Deal Calculator
    },
    renamePar : function(component, event, helper) 
    { 
        //alert("rename par");
        component.set("v.isRenameModalOpen", true);
        var renameIndex = event.getSource().get("v.name");
        component.set("v.renamePar",component.get("v.parList")[renameIndex]);
        component.set("v.renameParIndex", renameIndex);
    },
    deletePar : function(component, event, helper) 
    { 
        component.set("v.isDeleteModalOpen", true);
        var deleteIndex = event.getSource().get("v.name");
        component.set("v.deletePar",component.get("v.parList")[deleteIndex]);
    },
    copyPar : function(component, event, helper) 
    { 
        var copyIndex = event.getSource().get("v.name");
        component.set("v.selectedPar", component.get("v.parList")[copyIndex].Par__c);
        component.set("v.isCopyParModalOpen", true);
        
        component.find("CopyMovePar").set("v.copyMove", "Copy");
        component.find("CopyMovePar").set("v.title", "Cop To Par");
        
        component.find("CopyMovePar").set("v.quoteLines", "[]");
        component.find("CopyMovePar").getQuoteLines();
    },
    movePar : function(component, event, helper) 
    { 
        var moveIndex = event.getSource().get("v.name");
        component.set("v.selectedPar", component.get("v.parList")[moveIndex].Par__c);
        component.set("v.isCopyParModalOpen", true);
        
        component.find("CopyMovePar").set("v.copyMove", "Move");
        component.find("CopyMovePar").set("v.title", "Move To Par");
        
        component.find("CopyMovePar").set("v.quoteLines", "[]");        
        component.find("CopyMovePar").getQuoteLines();
    },
    deleteRow : function(component, event, helper) 
    { 
        var index = event.getParam("indexVar");
        var parList = component.get("v.parList");
        parList.splice(index, 1); 
        component.set("v.parList", parList);
    },
    removeRow : function(component, event, helper) 
    { 
        var index = event.getSource().get("v.name");
        var parList = component.get("v.newParList");
        parList.splice(index, 1); 
        component.set("v.newParList", parList);
    },
    addRow : function(component, event, helper) 
    { 
        var parList = component.get("v.newParList");
        parList.push({"Par__c":"", "Quote__c":component.get("v.recordId")}); 
        component.set("v.newParList", parList);
    },
    openModel: function(component, event, helper) 
    {
        var newParList = [];
        newParList.push({"Par__c":"", "Quote__c":component.get("v.recordId")}); 
        component.set("v.newParList", newParList);
        component.set("v.isAddParModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isAddParModalOpen", false);
        component.set("v.isRenameModalOpen", false);
        component.set("v.isDeleteModalOpen", false);
    },
    
    savePar: function(component, event, helper) {
        var allowClose = true;
        var validParNames = true;	//within 35 characters
        var parList = component.find("parName");
        //var parVals = [];
        if(parList)
        {
            if(Array.isArray(parList))
            {
                console.log('comp array len---'+parList.length);
                for(var i=0;i<parList.length;i++)
                {
                    var parName = parList[i].get("v.value");
                    console.log('parName--'+parName);
                    allowClose = allowClose && parName !="";
                    validParNames = validParNames && parName.length < 35;
                    // parVals.push(parName);
                }
                //console.log('parVals-len-'+parVals.length);
            }else{
                var parName = parList.get("v.value");
                allowClose = allowClose && parName !="";
                validParNames = validParNames && parName.length < 35;
                //parVals.push(parName);
            }
        }
        if(parList && allowClose && validParNames)
        {
            helper.saveQuotePar(component);
        }else if(!allowClose){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "Fill all the Par Names to Save."
            });
            toastEvent.fire();
        }else if(!validParNames){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "Par Name should be within 35 characters to Save."
            });
            toastEvent.fire();
        }
    },
    renameSavePar: function(component, event, helper) 
    {
        helper.renameParSave(component);
    },
    deleteParConfirm: function(component, event, helper) 
    {
        helper.deleteParHelper(component);
    }
})