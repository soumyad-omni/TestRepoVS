({
    doInit : function(component) { 
        console.log('Controller Called..');
        component.set("v.fields.Product", "MED-FRM-1010-1");
        component.set("v.fields1.Product", "MED-FRM-1010-3");
        component.set("v.selectedTabId","allproducts");
        this.helperMethod(component, event);
        this.getQuotelines(component, event);
        this.getParLocations(component, event);
        this.getProductsForPickList(component, event);
        this.getQuotelinesParN(component, event);
    },
    getPickList: function(component, event, helper) {
        var quoteId = component.get("v.recordId");
		var action = component.get('c.getShipToPicklist');
        action.setParams({ quoteId : quoteId});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.wrapperListN', response.getReturnValue().allPickList);
                component.set('v.firstPickList', response.getReturnValue().firstPickList);
            }else {
                var errors = response.getError();
                console.log('error : '+response.getError()+' '+errors[0].message);
                this.showToast(errors[0].message, 'Error Message', 'error');
            }
        });
        $A.enqueueAction(action);
    },
    searchProducts : function(component, event, helper) {
        component.set("v.spinner",true);
        var quoteId = component.get("v.recordId");
         console.log('Check the recordId...' +quoteId);
        //call apex class method
        var action = component.get('c.searchProducts');
        console.log('Check the Action...' +action);
        action.setParams({ quoteId : quoteId , searchText : component.get("v.searchText")});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('rj...' +JSON.stringify(response.getReturnValue()));
                //set response value in wrapperList attribute on component.
                var wrapperList = component.get("v.wrapperList");
                wrapperList["searchLstPrd"] = response.getReturnValue().searchLstPrd;
                component.set('v.wrapperList', wrapperList);
                /*
                component.set('v.wrapperList', response.getReturnValue());
                var result = response.getReturnValue();
                result = result.medPrd;
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.mapValues", arrayMapKeys);
                */
                component.set("v.isSearchOpen",true);
                component.set("v.selectedTabId","searchProducts");
            }else {
                var errors = response.getError();
                console.log('error : '+response.getError()+' '+errors[0].Message);
                this.showToast(errors[0].message, 'Error Message', 'error');
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
    },
    helperMethod: function(component, event, helper) {
        console.log('helper');
        var quoteId = component.get("v.recordId");
        //call apex class method
        var action = component.get('c.getProductInfo');
        action.setParams({ quoteId : quoteId});
        action.setCallback(this, function(response) {
            //store state of response
                            console.log('rj...1' +JSON.stringify(response.getReturnValue()));

            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('rj...' +JSON.stringify(response.getReturnValue()));
                //set response value in wrapperList attribute on component.
                component.set('v.wrapperList', response.getReturnValue());
                var result = response.getReturnValue();
                result = result.medPrd;
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.mapValues", arrayMapKeys);
            }else {
                var errors = response.getError();
                console.log('error : '+response.getError()+' '+errors[0].message);
                this.showToast(errors[0].message, 'Error Message', 'error');
            }
        });
        $A.enqueueAction(action);
    },
    updateQuoteLineHelper: function(component, event, helper) {
        component.set("v.spinner", true); 
        var quoteId = component.get("v.recordId");
    	var quoteLineList = component.get("v.wrapperListQuote");
        console.log('quoteLineList-- '+JSON.stringify(quoteLineList));
        var action = component.get("c.updateQuoteLinesCtrl");        
        action.setParams({ quoteId : quoteId , quoteLineWrapperList : JSON.stringify(quoteLineList)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrapperListQuote",response.getReturnValue());
                component.set("v.spinner", false); 
                var msg = 'Quote Line Updated Successfully';
                this.showToast(msg, '', 'success');
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);
    },
    deleteQuoteLine: function(component, event, helper) {        
        component.set("v.spinner", true); 
        var quoteId = component.get("v.recordId");
    	var quoteLineList = component.get("v.wrapperListQuote");
        console.log('quoteLineList delete-- '+JSON.stringify(quoteLineList));
        var action = component.get("c.deleteQuoteLinesCtrl");        
        action.setParams({ quoteId : quoteId , quoteLineWrapperList : JSON.stringify(quoteLineList)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrapperListQuote",response.getReturnValue());
                component.set("v.spinner", false); 
                var msg = 'Quote Line Updated Successfully';
                this.showToast(msg, '', 'success');
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);
    },
    getParLocations : function(component, event, helper) {
        console.log('*********'+component.get("v.selectedParForQuote"));
        var quoteId = component.get("v.recordId");
        var action = component.get("c.getParLocationCtrl");        
        var inputIndustry = component.find("InputAccountIndustry");
        action.setParams({ quoteId : quoteId});
        var opts=[];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.parList",response.getReturnValue());
                opts.push({
                class: "optionClass",
                label: "Show All Lines",
                value: "all"
            });
            for(var i=0;i< response.getReturnValue().length;i++){
                
                if(component.get("v.selectedParForQuote") === response.getReturnValue()[i]){
                    console.log(component.get("v.selectedParForQuote"));
                	console.log(response.getReturnValue()[i]);
                    opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i],selected: "true"});
                }
                else{
                    opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
            }
            inputIndustry.set("v.options", opts);
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);

    },
    getProductsForPickList : function(component, event, helper) {
        var quoteId = component.get("v.recordId");
        var action = component.get("c.getProductPicklistCtrl");        
        var inputIndustry = component.find("InputAccountIndustry2");
        action.setParams({ quoteId : quoteId});
        var opts=[];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                opts.push({
                    class: "optionClass",
                    label: "Show All Products",
                    value: "all"
                });
                for(var i=0;i< response.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
                inputIndustry.set("v.options", opts);
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);

    },
    getQuotelines : function(component, event, helper) {
        var quoteId = component.get("v.recordId");
        var action = component.get("c.getQuoteLinesCtrl");        
        action.setParams({ quoteId : quoteId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrapperListQuote",response.getReturnValue());
                component.set('v.data',response.getReturnValue());
                component.set('v.columns', [
                    {label: 'Par Location', fieldName: 'Par_Location__c', type: 'text'},
                    {label: 'Product', fieldName: 'Product_Code__c', type: 'reference' ,editable: true},
                    {label: 'Unit Price', fieldName: 'Conga_Unit_Price__c', type: 'currency' },
                    {label: 'Extended Price', fieldName: 'Conga_Extended_Price__c', type: 'currency'},
                    {label: 'Quantity', fieldName: 'Quantity__c', type: 'number' ,editable: true}
       			 ]);
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);

    },
    
    getQuotelinesParN: function(component, event, helper) {
        var quoteId = component.get("v.recordId");
        var action = component.get("c.getQuoteLinesCtrlPar");        
        action.setParams({ quoteId : quoteId,par: component.get("v.selectedParForQuote")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()--- '+JSON.stringify(response.getReturnValue()));
                component.set("v.wrapperListQuote",response.getReturnValue());
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);

    },
    getQuotelinesPar: function(component, event, helper) {
        var quoteId = component.get("v.recordId");
        var selectedIndustry = component.find("InputAccountIndustry");
        var action = component.get("c.getQuoteLinesCtrlPar");        
        action.setParams({ quoteId : quoteId,par: selectedIndustry.get("v.value")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrapperListQuote",response.getReturnValue());
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);

    },
    getQuotelinesProd: function(component, event, helper) {
        var quoteId = component.get("v.recordId");
        var selectedIndustry = component.find("InputAccountIndustry2");
        var action = component.get("c.getQuoteLinesCtrlProd");        
        action.setParams({ quoteId : quoteId,prod : selectedIndustry.get("v.value")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrapperListQuote",response.getReturnValue());
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }            
        });
        $A.enqueueAction(action);

    },
    createQuoteLineLookup: function(component, event, helper) {
        component.set("v.spinner", true); 
        var quoteId = component.get("v.recordId");
       // var product = component.get("v.selItem");
        //console.log('product+++ '+product);
        //console.log('product-- '+product.val);
        var action = component.get("c.createQuoteLinesLookup");        
        action.setParams({ product : product.val , quoteId : quoteId, parName : component.get("v.selectedParForQuote")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.wrapperListQuote",response.getReturnValue());
                console.log('Success........');
                component.set("v.spinner", false); 
                var msg = 'Quote Line Added Successfully';
                this.showToast(msg, '', 'success');
                
                component.set("v.openModal", true);
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
              //  var obj1= document.getElementById(prd);
        		// obj1.disabled = false;
            }
            /*var isOpen = component.get("v.isOpen");
            isOpen = false;
            component.set("v.isOpen", isOpen);*/
            
        });
         $A.enqueueAction(action);
    },
    createQuoteLinesForAllPar: function(component, event, helper) {
        component.set("v.spinner", true); 
        var selectedProducts = this.fetchSelectedProducts(component);
        console.log('selectedProducts--  ',selectedProducts.length);
        var quoteId = component.get("v.recordId");
        var action = component.get("c.createQuoteLinesForAllParA");        
        action.setParams({ selectedProducts : selectedProducts, 
                          quoteId : quoteId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wrapperListQuote",response.getReturnValue());
                component.set("v.spinner", false); 
                var msg = 'Quote Line Added Successfully';
                this.showToast(msg, '', 'success');
                component.set("v.openModal", true);
            }
            else {
                console.log('Error........');
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    createQuoteLines: function(component, event, helper) {
        component.set("v.spinner", true); 
        var selectedProducts = this.fetchSelectedProducts(component);
        console.log('selectedProducts--  ',selectedProducts.length);
        var quoteId = component.get("v.recordId");
        var action = component.get("c.createQuoteLinesA"); 
        action.setParams({selectedProducts : selectedProducts,
                          quoteId : quoteId, 
                          parName : component.get("v.selectedParForQuote")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.wrapperListQuote",response.getReturnValue());
                component.set("v.spinner", false); 
                var msg = 'Quote Line Added Successfully';
                this.showToast(msg, '', 'success');
                component.set("v.openModal", true);
            }
            else {
                console.log('Error........'); 
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                component.set("v.spinner", false); 
            }            
        });
        $A.enqueueAction(action);
        
    },
    copyQuoteLines: function(component, event, helper) {
        component.set("v.spinner", true);         
        var quoteId = component.get("v.recordId");
       // var copyQuoteId = component.get("v.selItem");
        console.log('QId-- '+quoteId);
        console.log('copyQId-- '+copyQuoteId.val);
        if(quoteId === copyQuoteId.val){
            var msg = 'Cannot add current quote line';
            this.showToast(msg, '', 'warning');
            component.set("v.spinner", false);
        }
        else{
            var action = component.get("c.copyQuoteLines");        
            action.setParams({ copyQuoteId : copyQuoteId.val , quoteId : quoteId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    component.set("v.wrapperListQuote",response.getReturnValue());
                    console.log('Success........');
                    component.set("v.spinner", false); 
                    var msg = 'Quote Line Added Successfully';
                    this.showToast(msg, '', 'success');
                    
                    component.set("v.openModal", true);
                }
                else {
                    this.showToast(response.getError()[0].message, 'Error!', 'error');
                    console.log('Error........'); 
                    //  var obj1= document.getElementById(prd);
                    // obj1.disabled = false;
                }
                /*var isOpen = component.get("v.isOpen");
                isOpen = false;
                component.set("v.isOpen", isOpen);*/
            
        	});
            $A.enqueueAction(action);
        }
    },
    
    CreateQuoteLine: function(component, event, helper) {
        console.log('inside helper....');
        var prd = event.target.id;
        var artId = component.get("v.recordId");
        var qty = component.get("v.myNumber");
        console.log('prd: ' +prd);
        console.log('qty: ' +qty);
        console.log('quoteid: ' +artId);
        var action = component.get("c.createQuoteLine");
        action.setParams({ qid : artId,prd: prd,qty: qty});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success........');
                var msg = 'Quote Line Added Successfully';
                this.showToast(msg, '', 'success'); 
                 var obj= document.getElementById(prd);
        		 obj.disabled = false;
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
                var obj1= document.getElementById(prd);
        		 obj1.disabled = false;
            }
             
            
        });
        $A.enqueueAction(action);
        
    },
    
    createQuoteLinesFromc4cAsserts: function(component, event)
    {
        var productList = component.get("v.productList");
        console.log('productList---'+JSON.stringify(productList));
        var selectedProducts = [];
        var validSelectedProducts = [];
        if(productList)
        {
            productList.forEach(function(product){
                if(product.isSelected)
                {
                    selectedProducts.push(product);
                }
            });
            if(selectedProducts.length>0)
            {
                selectedProducts.forEach(function(product){
                if(product.quantity)
                {
                    validSelectedProducts.push(product);
                }
            	});
                if(selectedProducts.length == validSelectedProducts.length)
                {
                    //Create QuoteLines
                    this.CreateQuoteLineApex(component, validSelectedProducts);
                }else
                {
                    this.showToast("Enter Quantity for all selected products.","Error","error");
                }
            }else
            {
                this.showToast("Select Atleast one Product.","Error","error");
            }
        }
    },
    CreateQuoteLineApex: function(component, validSelectedProducts) 
    {
        var newQuoteLines = [];
        validSelectedProducts.forEach(function(product){
            newQuoteLines.push({"RecordTypeId":"0121N000001M5AGQA0",
                                "Quote__c":component.get("v.recordId"),
                                "Product__c":product.Product__c,
                                "Quantity__c":product.quantity,
                                "Par_Location__c":product.parLocation}); 
        });
        
        var action = component.get("c.createQLineForc4c");
        action.setParams({ newQuoteLines : newQuoteLines});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('createQLineForc4c--Success..');
                this.showToast('Quote Line Added Successfully', '', 'success');
                this.getQuotedetails(component, event);
                this.getQuotelines(component, event);
            }
            else {
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                console.log('Error........'); 
            }
        });
        $A.enqueueAction(action);
    },
    fetchSelectedProducts : function(component) 
    {
        var selectedProducts = [];
        var productWrapper = component.get('v.wrapperList');
        var dwProductMap = component.get("v.mapValues");
        if(productWrapper.searchLstPrd && productWrapper.searchLstPrd.length >0)
        {
            productWrapper.searchLstPrd.forEach(function(eachProd){
                if(eachProd.isSelected)
                {
                   selectedProducts.push(eachProd); 
                }
            });
        }
        if(productWrapper.allLstPrd && productWrapper.allLstPrd.length >0)
        {
            productWrapper.allLstPrd.forEach(function(eachProd){
                if(eachProd.isSelected)
                {
                   selectedProducts.push(eachProd); 
                }
            });
        }
        if(productWrapper.lstPrd && productWrapper.lstPrd.length >0)
        {
            productWrapper.lstPrd.forEach(function(eachProd){
                if(eachProd.isSelected)
                {
                   selectedProducts.push(eachProd); 
                }
            });
        }
        if(dwProductMap && dwProductMap.length >0)
        {
            dwProductMap.forEach(function(eachCatProdList){
                if(eachCatProdList && eachCatProdList.value && eachCatProdList.value.length >0)
                {
                    eachCatProdList.value.forEach(function(eachProd){
                        if(eachProd.isSelected)
                        {
                            selectedProducts.push(eachProd); 
                        }
                    });
                }
            });
        }
        console.log('total selected Products ? - '+selectedProducts.length);
        var quoteLinesToAdd = [];
        if(selectedProducts && selectedProducts.length>0)
        {
            selectedProducts.forEach(function(eachProduct){
                quoteLinesToAdd.push({sObjectType:"Quote_Line__c",
                                      Quantity__c:eachProduct.quantity,
                                      Product__c:eachProduct.productItem.Id});
            });
        }
        return quoteLinesToAdd;
    },
    //IBA-1768 New Logic added
    checkForErrorsAndSave: function(component, event, helper) {
        component.set("v.spinner", true); 
        var selectedProducts = this.fetchSelectedProducts(component);
        var quoteId = component.get("v.recordId");
        var action = component.get("c.checkErrorMesssage"); 
        var selectedBtn = component.get("v.selectedbutton");
        action.setParams({selectedProducts : selectedProducts,
                          quoteId : quoteId, 
                          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isTrue = response.getReturnValue();
                component.set("v.spinner", false);
                if(isTrue == true) {
                     var msg = 'XT Select cabinets can only be used when Order Type is Quote-Purchase';
                     this.showToast(msg, '', 'Error');
                }else {
                    if(selectedBtn == "Add to Par") {
                        this.saveProducts(component);
                    }
                    if(selectedBtn == "Add to All Pars") {
                        this.saveProductsForAllPar(component);
                    }
                    
                }
               // var msg = 'Quote Line Added Successfully';
               // this.showToast(msg, '', 'success');
            }
            else {
                console.log('Error........'); 
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                component.set("v.spinner", false); 
            }            
        });
        $A.enqueueAction(action);
        
    },
    //IBA-2126 Start
    checkPreviewCheckbox: function(component, event, helper) {
        component.set("v.spinner", true); 
        var selectedProducts = this.fetchSelectedProducts(component);
        var quoteId = component.get("v.recordId");
        var action = component.get("c.previewImageError"); 
        var selectedBtn = component.get("v.selectedbutton");
        action.setParams({selectedProducts : selectedProducts,
                          quoteId : quoteId, 
                          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isTrue = response.getReturnValue();
                component.set("v.spinner", false);
                if(isTrue == 1) {
                    var msg = 'Error! Please select only one product';
                     this.showToast(msg, '', 'Error');
                }else if(isTrue == 2){
                    var msg = 'No Image to display!';
                     this.showToast(msg, '', 'Error');
                }else if(isTrue == 0){
                    if(selectedBtn == "Preview") {
                        this.pullImage(component);
                    }
                }
            }
            else {
                console.log('Error........'); 
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                component.set("v.spinner", false); 
            }            
        });
        $A.enqueueAction(action);
    },
    pullImage: function(component, event, helper) {
    component.set("v.spinner", true); 
        var selectedProducts = this.fetchSelectedProducts(component);
        var quoteId = component.get("v.recordId");
        var action = component.get("c.pullImageDetails");
        action.setParams({selectedProducts : selectedProducts,
                          quoteId : quoteId, 
                          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isTrue = response.getReturnValue();
                component.set("v.spinner", false);
                if(isTrue != null) {
                    component.set("v.imageId", isTrue);
                    component.set("v.isImageModalOpen", true);
                }
            }
            else{
                console.log('Error........'); 
                this.showToast(response.getError()[0].message, 'Error!', 'error');
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    //IBA-2126 End
    /*getQuotedetails: function(component, event, helper)
    {
        var action = component.get('c.getAssetsInfo');
        action.setParams({
            "quoteId":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var ordertype = response.getReturnValue().qte.Order_Type__c;
                console.log('-ordertype-'+ordertype);
                if((ordertype == "ZQLI" || ordertype == "ZQL3") && !$A.util.isUndefinedOrNull(response.getReturnValue().c4cAsset)) 
                {
                    component.set("v.productList", response.getReturnValue().c4cAsset);
                    component.set("v.isRenewalQuote", true);
                    //component.find("pagination").prepare();
                }
                else{
                     component.set("v.isRenewalQuote", false);
                } 
                //component.set("v.isRenewalQuote", true);
                //component.set("v.productList", response.getReturnValue().c4cAsset);
            }
            else {
                var errors = response.getError();
                console.log('error : '+response.getError()+' '+errors[0].Message);
                this.showToast(errors[0], 'Error Message', 'error');
            }
        });
         
        component.set('v.Spinner', false);
        $A.enqueueAction(action);
    },*/
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
    showmsg : function(errorMsg, title, toastType) {
        this.showToast(errorMsg, title, 'error'); 
    },
    //IBA-1768- Moved this logic from Controler Js to helper js
    saveProducts: function(component, event, helper) {
        //alert(component.get("v.selectedParForQuote")); 
        var productList = component.get("v.wrapperList");
        var selected = false;
        for(var product in productList){
            if(product.isSelected){selected = true;}
        } 
        //helper.createQuoteLines(component, event); 
        //helper.helperMethod(component, event);
        //helper.getQuotelines(component, event);       
        if(component.get("v.isRenewalQuote"))
        {
            this.createQuoteLinesFromc4cAsserts(component, event);
        }else{
            this.createQuoteLines(component, event); 
            this.helperMethod(component, event);
            this.getQuotelines(component, event);
            this.getParLocations(component, event);
            this.getProductsForPickList(component, event);
			this.getQuotelinesParN(component, event);            
        }
		
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
       // component.set("v.isOpen", false);
    },
    //IBA-1768- Moved this logic from Controler Js to helper js
    saveProductsForAllPar: function(component, event, helper) {
        //alert(component.get("v.selectedParForQuote"));
        var productList = component.get("v.wrapperList");
        var selected = false;
        for(var product in productList){
            if(product.isSelected){selected = true;}
        } 
        //helper.createQuoteLines(component, event); 
        //helper.helperMethod(component, event);
        //helper.getQuotelines(component, event);       
        if(component.get("v.isRenewalQuote"))
        {
            this.createQuoteLinesFromc4cAsserts(component, event);
        }else{
            this.createQuoteLinesForAllPar(component, event); 
            
            this.helperMethod(component, event);
            this.getQuotelines(component, event);
            this.getParLocations(component, event);
            this.getProductsForPickList(component, event);
			this.getQuotelinesParN(component, event);   
        }
		
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
       // component.set("v.isOpen", false);
    },
    //IBA-2004 start
    sortByProductItem: function(component,helper,field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
        	prodItm = "productItem",
            sortFld = "ProductCode",
        	records;
        if(field == 'srchProd' || field == 'srchDes'){
        	records = component.get("v.wrapperList.searchLstPrd"); 
        } else if(field == 'allProd' || field == 'allDes'){
        	records = component.get("v.wrapperList.allLstPrd");    
        } else if(field == 'alaCarteProd' || field == 'alaCarteDes'){
        	records = component.get("v.wrapperList.lstPrd");    
        } 
        sortAsc = sortField != prodItm || !sortAsc;
        if(field == 'srchProd' || field == 'allProd' || field == 'alaCarteProd'){
        	records = this.sortProductCode(records,sortAsc,prodItm);    
        } else if(field == 'srchDes' || field == 'allDes' || field == 'alaCarteDes'){
        	records = this.sortDescription(records,sortAsc,prodItm);    
        }        
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", prodItm);
        if(field == 'srchProd' || field == 'srchDes'){
            component.set("v.wrapperList.searchLstPrd", records);
        } else if(field == 'allProd' || field == 'allDes'){
        	component.set("v.wrapperList.allLstPrd", records); 
        } else if(field == 'alaCarteProd' || field == 'alaCarteDes'){
        	records = component.set("v.wrapperList.lstPrd", records);    
        } 
    },
    sortByProdItemMap: function(component,helper,tabName) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
        	records = component.get("v.mapValues"),
            prodItm = "productItem",
        	finalRecords = [],
        	field = tabName.substring(0, tabName.length-6);
        if(records && records.length >0)
        {
            records.forEach(function(eachCatProdList){
                if(eachCatProdList && eachCatProdList.value && eachCatProdList.value.length >0 
                   && eachCatProdList.key == field)
                {
                    console.log('eachCatProdList.key :'+ eachCatProdList.key); 
                    var recordList = eachCatProdList.value;
                    sortAsc = sortField != prodItm || !sortAsc;
                    if(tabName.endsWith('prdmap')){
                    	recordList = helper.sortProductCode(recordList,sortAsc,prodItm);    
                    } else {
                        recordList = helper.sortDescription(recordList,sortAsc,prodItm);
                    }
                    finalRecords.push({key: eachCatProdList.key, value: recordList});
                } else {
                    finalRecords.push({key: eachCatProdList.key, value: eachCatProdList.value});
                }
            });
        }
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", prodItm);
        component.set("v.mapValues", finalRecords);
    },
    sortProductCode : function(records,sortAsc,prodItm){
    	records.sort(function(a,b){
        var t1 = a[prodItm].ProductCode == b[prodItm].ProductCode,
            t2 = (!a[prodItm].ProductCode && b[prodItm].ProductCode) || (a[prodItm].ProductCode < b[prodItm].ProductCode);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });	
        return records;
    },
    sortDescription : function(records,sortAsc,prodItm){
    	records.sort(function(a,b){
        var t1 = a[prodItm].Description == b[prodItm].Description,
            t2 = (!a[prodItm].Description && b[prodItm].Description) || (a[prodItm].Description < b[prodItm].Description);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });	
        return records;
    } //IBA-2004 end
    
})