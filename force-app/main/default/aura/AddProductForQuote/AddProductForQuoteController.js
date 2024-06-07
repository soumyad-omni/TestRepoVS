({
    doInit : function(component, event, helper) { 
        helper.doInit(component);
    },
    handleQuoteLinesRefresh : function(component, event, helper) { 
        helper.doInit(component);
    },
    doActionPar : function(component, event, helper) { 
        var params = event.getParam("arguments");
        if (params) {
            var param1 = params.param;
            console.log('Controller Called..'+param1);
        }        
        helper.getParLocations(component, event);
        helper.getQuotelinesParN(component, event); 
    },
    getPrdInfo : function(component, event, helper) { 
        console.log('Controller Called..');
        helper.helperMethod(component, event);
    },
    onPicklistChange: function(component, event, helper) {
        //get the value of select option
        var selectedIndustry = component.find("InputAccountIndustry");
        if(selectedIndustry.get("v.value") === 'all')
            helper.getQuotelines(component, event);
        else
        	helper.getQuotelinesPar(component, event);
    },
    onPicklistChangeProd : function(component, event, helper) {
        //get the value of select option
        var selectedIndustry = component.find("InputAccountIndustry2");
        if(selectedIndustry.get("v.value") === 'all')
            helper.getQuotelines(component, event);
        else
        	helper.getQuotelinesProd(component, event);
    },
    openModel: function(component, event, helper) {
        //helper.getPickList(component, event, helper);
        //component.set("v.isShiptoOpen",true);
        component.set("v.isOpen", true);
        component.set("v.selectedbutton","Preview");
        helper.checkPreviewCheckbox(component, event);
        helper.helperMethod(component, event);
        helper.getQuotelines(component, event);
        helper.getParLocations(component, event);
        helper.getProductsForPickList(component, event);
    },
    nextToPar: function(component, event, helper) {
        component.set("v.isShiptoOpen",false);
        component.set("v.isOpenMOdal",true);
    },
    backToShipTo: function(component, event, helper) {
        component.set("v.isShiptoOpen",true);
        component.set("v.isOpenMOdal",false);
    },
    closeModelModalToPar: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isShiptoOpen", false);
        
    },
    closeModelModal: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpenMOdal", false);
        
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
        component.set("v.isAddParModalOpen", true);
        component.set("v.isImageModalOpen", false);
        
    },
    next: function(component, event, helper) {
        console.log('parlocationName1-- '+component.get("v.parlocationName1"));
        console.log('parlocationName2-- '+component.get("v.parlocationName2	"));
        let parLocationList =[];
        if(component.get("v.parlocationName1") !== undefined){
            parLocationList.push(component.get("v.parlocationName1"));
        }
        if(component.get("v.parlocationName2") !== undefined){
            parLocationList.push(component.get("v.parlocationName2"));
        }
        if(component.get("v.parlocationName3") !== undefined){
            parLocationList.push(component.get("v.parlocationName3"));
        }
        if(component.get("v.parlocationName4") !== undefined){
            parLocationList.push(component.get("v.parlocationNamer4"));
        }
        if(component.get("v.parlocationName5") !== undefined){
            parLocationList.push(component.get("v.parlocationName5"));
        }
        component.set("v.parLocationList",parLocationList);
        component.set("v.isOpenMOdal",false);
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
        helper.helperMethod(component, event);
        helper.getQuotelines(component, event);
        helper.getParLocations(component, event);
        helper.getProductsForPickList(component, event);
        //helper.getQuotedetails(component, event);
        
    },
    deleteMethod: function(component, event, helper){
    	helper.deleteQuoteLine(component, event);
        helper.helperMethod(component, event);
        helper.getQuotelines(component, event);
        helper.getParLocations(component, event);
        helper.getProductsForPickList(component, event);
        helper.getQuotelinesParN(component, event);
	},
    updateQuoteLines: function(component, event, helper){
        
        helper.updateQuoteLineHelper(component, event);
        helper.helperMethod(component, event);
        helper.getParLocations(component, event);
        helper.getProductsForPickList(component, event);
        helper.getQuotelinesParN(component, event); 
    },
    handleEdit : function(component, event, helper){
        component.set("v.isEdit",true);
    },
 saveQuoteProducts: function(component, event, helper) {        
        helper.copyQuoteLines(component, event);
        helper.helperMethod(component, event);
        helper.getQuotelines(component, event);
        helper.getParLocations(component, event);
        helper.getProductsForPickList(component, event);
    },
    saveProductsLookup: function(component, event, helper) {
       // var product = component.get("v.selItem");
        //console.log('product+++ '+JSON.stringify(product));
        //console.log('product-- '+product.val);
        /*helper.createQuoteLineLookup(component, event);
        helper.helperMethod(component, event);
        helper.getQuotelines(component, event);
        helper.getParLocations(component, event);
        helper.getProductsForPickList(component, event);*/
    },
    searchProductsCtrl: function(component, event, helper) {
        helper.searchProducts(component, event);
    },
    //IBA-1768- Moved this logic from Controler Js to helper js
    saveProductsForAllPar: function(component, event, helper) {
        component.set("v.selectedbutton","Add to All Pars");
        helper.checkForErrorsAndSave(component, event); 
    },
    //IBA-1768- Moved this logic from Controler Js to helper js
    saveProducts: function(component, event, helper) {
        component.set("v.selectedbutton","Add to Par");
        helper.checkForErrorsAndSave(component, event);
    },
    previewImage: function(component, event, helper) {
        component.set("v.selectedbutton","Preview");
        helper.checkPreviewCheckbox(component, event);
    },
    //showtext: function(component, event, helper) {
        //helper.showsometext(component, event);
    //},
    showCaseDeleteModal: function(component, event, helper) {
        var prd = event.target.id;
        var artId = component.get("v.recordId");
        var qty = component.get("v.myNumber");
        var obj= document.getElementById(prd);
        obj.disabled = true;
       // component.set("v.myNumber", 0);
        console.log('prd: ' +prd);
        console.log('qty: ' +qty);
        console.log('quoteid: ' +artId);
        if(qty > 0) {
            helper.CreateQuoteLine(component, event);
            helper.helperMethod(component, event);
            helper.getQuotelines(component, event);
            helper.getParLocations(component, event);
            helper.getProductsForPickList(component, event);
        }
        else {
            console.log('Please enter Quantity');
            var msg = 'Please enter Quantity';
            helper.showmsg(msg, '', 'error');
            obj.disabled = false;
        }
        
    },
    createQL : function(component, event) {
        var val1 = component.get("v.fields");
        var val2 = component.get("v.fields1");
        // var idx = event.target.id;
        //alert(idx);  
        console.log('prd....' +val1.Product);
        console.log('qty....' +val1.Quantity);
        console.log('prd....' +val2.Product);
        console.log('qty....' +val2.Quantity);
    },
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    //IBA-2004 start
    sortByProduct: function(component, event, helper) {
        var tabName = event.currentTarget.id;
        if(tabName == 'srchProd' || tabName == 'allProd' || tabName == 'alaCarteProd' 
           || tabName == 'srchDes' || tabName == 'allDes' || tabName == 'alaCarteDes'){
        	helper.sortByProductItem(component,helper,tabName);    
        } else if(tabName.endsWith('map')){
        	helper.sortByProdItemMap(component,helper,tabName);    
        }
        var a=component.get("v.sortAsc");
        if(tabName == 'srchProd' || tabName == 'allProd' || tabName == 'alaCarteProd' || tabName.endsWith('prdmap'))
        	component.set("v.product",a);
        else if(tabName == 'srchDes' || tabName == 'allDes' || tabName == 'alaCarteDes' || tabName.endsWith('desmap')) 
           	component.set("v.desc",a); 
    } //IBA-2004 end
})