({
    doInit : function(component, event, helper){
        //IBA-3242 Start
        
        var opts = [
            { id: 'Please Select', label: 'Please Select' },
            { id: 'CPDS –Central Pharmacy Dispensing Services', label: 'CPDS –Central Pharmacy Dispensing Services' },
            { id: 'IVCS-IV Compounding Services', label: 'IVCS-IV Compounding Services' },
            { id: 'IVX Workflow', label: 'IVX Workflow' },
            { id: 'PASS –Packaging and Service Subscription', label: 'PASS –Packaging and Service Subscription' },
            { id: 'CarePlus', label: 'CarePlus' }, //Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
            { id: 'ServerScale Subscription', label: 'ServerScale Subscription' }
        ];
        //IBA-3242 End //IBA-4819 Added ServerScale Subscription
        
        component.set("v.buttonsdisabled","true");
        var resetfalse = false;
        component.set("v.resettrue",resetfalse);
        console.log("resetfalse : "+resetfalse+"resettrue : "+component.get("v.resettrue"))
        var action = component.get("c.getUser");
        //action.setParams({ campId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.checkUser",storeResponse);
            }
        });
        $A.enqueueAction(action);
       
var isNotOmnicellServiceOrderType = component.get("c.isNotOmnicellServiceOrderType");
        isNotOmnicellServiceOrderType.setParams({ "recordID" : component.get("v.recordId") });
        
        isNotOmnicellServiceOrderType.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state + 'stroe--');
            if(state === "SUCCESS") {
                //component.set("v.disabled","false");
                 var responseResult = response.getReturnValue();
                if(responseResult === false){		//IBA-3242 Start
                	component.set("v.hasPulsarHeroProd",true);  
                    console.log('@@sourav'+responseResult);
                    var cmp = component.find('template');
                    cmp.set('v.body', []); // clear all options
                    console.log('SVD'+component.find("template").get("v.value"));
                    var body = cmp.get('v.body');
                    opts.forEach(function (opt) {
                        $A.createComponent(
                            'aura:html',
                            {
                                tag: 'option',
                                HTMLAttributes: {
                                    value: opt.id,
                                    text: opt.label
                                }
                            },
            
                            function (newOption) {
                                //Add options to the body
                                if (component.isValid()) {
                                    body.push(newOption);
                                    cmp.set('v.body', body);
                                }
                            })
                    });
                    component.find("template").set("v.value","Please Select")//IBA-3242
                    console.log('SVD2'+component.find("template").get("v.value"));
                }//IBA-3242 End
                console.log(responseResult + 'stroe--');
                 component.set("v.genericdrawers",responseResult);  
                 component.set("v.isNotServiceOrderType",responseResult);  
                   
                   
                
            }
        });
         var isSupplementApproval = component.get("c.isSupplementApproval");
                    isSupplementApproval.setParams({ "quoteId" : component.get("v.recordId") });                 
                    isSupplementApproval.setCallback(this, function(response1) {
                        var approvalState = response1.getState();                       
                        if(approvalState === "SUCCESS") {
                            //component.set("v.disabled","false");
                            var approvalResult = response1.getReturnValue();                           
                            component.set("v.isSupplement",approvalResult); 
                            
                            console.log(approvalResult + 'approvalResultSupplement--');
                        }
                    });
        //IBA-3867 (4625) Change starts
        var getSAPSalesOrgAndCurrency = component.get("c.getSAPSalesOrgAndCurrency");
        getSAPSalesOrgAndCurrency.setParams({ "recordID" : component.get("v.recordId") });
        getSAPSalesOrgAndCurrency.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state + 'stored--');
            if (state === "SUCCESS") {
        var isSalesOrgInt = response.getReturnValue();
        component.set("v.quoteSAPSalesOrg", isSalesOrgInt);
        var quoteSAPSalesOrg = component.get("v.quoteSAPSalesOrg");
         /*IBA-4711 Change starts AC*/
                var sections = [
                    { label: 'Summary Product Only', value: 'Summary Product Only' },
                    { label: 'Summary Service Only', value: 'Summary Service Only' },
                    { label: 'Summary by Par Location', value: 'Summary by Par Location' },
                    { label: 'Detail by Par Location', value: 'Detail by Par Location' },
                    { label: 'Print Config Pictures (1 pic default option)', value: 'Print Config Pictures (1 pic default option)' },
                    { label: 'Summary by Par Location with pictures', value: 'Summary by Par Location with pictures' }
                ];
                /*IBA-4711 Change Ends AC*/
                component.set("v.sections", sections);
            }
        });
        //IBA-3867 (4625) change ends
         var ismaPassSupplementApproval = component.get("c.ismaPassSupplementApproval");
                    ismaPassSupplementApproval.setParams({ "quoteId" : component.get("v.recordId") });                 
                    ismaPassSupplementApproval.setCallback(this, function(response1) {
                        var approvalState = response1.getState();                       
                        if(approvalState === "SUCCESS") {
                            var approvalResultma = response1.getReturnValue();                           
                            component.set("v.ismaSupplement",approvalResultma); 
                            console.log(approvalResultma + 'MAPASSapprovalResultSupplement--');
                        }
                    });
        
        $A.enqueueAction(isNotOmnicellServiceOrderType);
        $A.enqueueAction(getSAPSalesOrgAndCurrency); //IBA-3867 change
        $A.enqueueAction(isSupplementApproval);
        $A.enqueueAction(ismaPassSupplementApproval);
         //$A.enqueueAction(isNotOmnicellServiceOrderType);
        //helper.comparequotetrue(component,helper);
        /////////////Added by Sravan on 21 AUG
        var checkrevision = component.get("c.compare");
       // component.set("v.buttonsdisabled","true");
        checkrevision.setParams({ "recordID" : component.get("v.recordId") });
        checkrevision.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //component.set("v.disabled","false");
                var storeResponse = response.getReturnValue();
                if(storeResponse === "notexecuted"){
                	helper.comparequotetrue(component,helper);
                    helper.initializeprint(component,helper);
                	console.log('notexecuted');
                }
                else if(storeResponse === "Identical" || storeResponse === "turnoffrevisioncheck"){
                    //component.set("v.disabled","false");
                    //Added initializeprint on 13 NOV to comment batch execution check
                    helper.initializeprint(component,helper);
                	helper.comparequotetrue(component,helper);
                	console.log('Identical from check revision');
                }
                else{
                    component.set("v.buttonsdisabled","true");
                    component.set("v.disabled","true");
                    var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"message": storeResponse,
                        "duration": 30000    
                	});
                	toastEvent.fire();
                }
            }
            else{
                console.log('failed checkrevision');
                component.set("v.buttonsdisabled","true");
                component.set("v.disabled","true");
                var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"message": "Failed check revision. Please wait.",
                        "duration": 30000    
                	});
                toastEvent.fire();
            }
        });
        $A.enqueueAction(checkrevision);
        /////////Added by Sravan on 21 AUG
        
    },
	selectPrint : function(component, event, helper) {
        /*var test = component.get("v.isEditButtonClicked");
        console.log('test...' +test);*/
        component.set("v.selectedbutton","print");
        var quoteprintname;
        var isdraft=false;
        var quoteId = component.get("v.recordId");
		var selectedValues = component.get("v.selectedDocsList");
        var selectedExhibits = component.get("v.selectedexhibitsList");
        var selectedSections = component.get("v.selectedSectionsList");
        var layout = component.find("layout").get("v.value");
        var language = component.find("lang").get("v.value");
        var template = component.find("template").get("v.value");
        console.log('##SRV_Hero'+template);
        var agreementId = '';//component.find("agreementId").get("v.value");//added by jay cr-18666
        var output = component.find("output").get("v.value");
        var usalist = "false";
        var zerodollars = "false";
        var genericdrawers = "false";
        var productsunbundled = "false";
        var serviceonly = "false";
        var noofpictures = 0;
        var renderer = component.get("v.iframerender");
        var isNotServiceOrderType = component.get("v.isNotServiceOrderType");
        var editedterms;
		var isEditClicked = component.get("v.isEditButtonClicked");
        if(isNotServiceOrderType == true)
        {
            usalist = component.get("v.usalist");
            zerodollars = component.get("v.zerodollars");
            genericdrawers = component.get("v.genericdrawers");
            productsunbundled = component.get("v.productsunbundled");
            serviceonly = component.get("v.serviceonly");
            noofpictures = component.find("noofpictures").get("v.value");
        }
        var isSupplement = component.get("v.isSupplement");
        var ismsSupplement = component.get("v.ismaSupplement");//added for IBA-2290
  		/*if(isSupplement)
        {
          agreementId = component.find("agreementId").get("v.value");//added by jay cr-18666  
        }*/
        if(isSupplement && ismsSupplement ){
          agreementId = component.find("agreementId2").get("v.value");//added by jay cr-18666  //added for IBA-2290
          console.log('agreementId both True'+agreementId);
        }
        else if(isSupplement){
            agreementId = component.find("agreementId").get("v.value");//added by jay cr-18666
            console.log('agreementId Single true'+agreementId);
        }
        /* Following IF is added for SF-BUG-287*/
        //var checkUser = component.get("v.checkUser"); //added for sf-bug-287 
        //if(checkUser === "true") //If added for sf-bug-287 
        //{
        if(renderer === "true" && isNotServiceOrderType == true)
       		editedterms = component.find("editedterms").get("v.value");
        else
            //editedterms = ""; commented and replaced by below line for SF-BUG-287 
            editedterms = component.get("v.terms");
        //}
        var selectedcannprevious = component.get("v.selectedDocsListPrevious");
        /* Below added for UAT 259 and 261 */        
        /*if(event.getSource().get('v.label') == 'Print'){
            //component.set('c.isAlternate', true); 
            //
            var action9 = component.get("c.setPrintFlag");
            action9.setParams({ quoteId : component.get("v.recordId") });
            action9.setCallback(this, function(response) {
            var state9 = response.getState();
            if (state9 === "SUCCESS") {
                var storeResponse9 = response.getReturnValue();
                console.log('Value returned from SetPrintFlag' +storeResponse9);
                /*if(storeResponse9 === true){
                	var toastEvent = $A.get("e.force:showToast");
               		toastEvent.setParams({
                    "title": "Error!",
                    "message": "This Quote Can not be printed in alternate Currency"
                });
                toastEvent.fire();
                }
				                
            }
        });
        $A.enqueueAction(action9); 
            
        }*/
        /* Above added for UAT 259 and 261 */
        //var editedterms = component.find("editedterms").get("v.value");
        
        /*var callbatch = component.get("c.callBatch");
        callbatch.setParams({ qId : component.get("v.recordId"), isPrintGenericDrawer : genericdrawers});
        callbatch.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Updated!');
            }
        });
        $A.enqueueAction(callbatch);*/
        if(template=='CarePlus'){//IBA-3242 Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
            genericdrawers = true;
        }
        
        console.log('selected canned Language : '+selectedValues);
        console.log('selected Exhibits : '+selectedExhibits);
        console.log('selected sections : '+selectedSections);
        console.log('Layout : '+layout);
        console.log('OutPut : '+output);
        console.log('Language : '+language);
        console.log('Template : '+template);
        console.log('USA List  : '+usalist); 
        console.log('zerodollars  : '+zerodollars);
        console.log('genericdrawers : '+genericdrawers);
        console.log('productsunbundled : '+productsunbundled);
        console.log('No of Pictures : ' + noofpictures);
        console.log('Edited Terms : ' + editedterms);
        console.log('Previous Canned Lang : '+selectedcannprevious);
        console.log('agreementId '+agreementId);
        if(template=='Please Select'){ //Validation Add //IBA-3242
            console.log('Please Select '+template);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                       "message": "Please Select a Base Template",
                       "duration": 1000,    
                		"type": 'warning'    
            });
            toastEvent.fire();
        }
        else if(isSupplement && agreementId=='Please Select' && template !='CarePlus' && template !='ServerScale Subscription'){ //IBA-6201 Saptarsha Panthi.// Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
            console.log('Please Select Agree 283'+agreementId);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                       "message": "Please Select Agreement",
                       "duration": 1000,    
                		"type": 'warning'
            });
            toastEvent.fire();
        }
        else{
            	var action = component.get('c.updateQuote'); 
                action.setParams({
                    "quoteId": component.get("v.recordId"),
                    "selectedCannedLan": selectedValues,
                    "selectedExhibits": selectedExhibits,
                    "selectedSections": selectedSections,
                    "layout" : layout,
                    "language": language,
                    "template": template,
                    "output": output,
                    "usalist": usalist,
                    "zerodollars": zerodollars,
                    "genericdrawers": genericdrawers,
                    "productsunbundled": productsunbundled,
                    "serviceonly":serviceonly,
                    "noofpictures": noofpictures,
                    "editedterms": editedterms,
                    "selcannedPrev":selectedcannprevious,
                    "isdraft":isdraft,
                    "agreementType":agreementId,
                "isEditButtonClicked":isEditClicked
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    
                    console.log("state="+state);
                    if (state === "SUCCESS"){
                        quoteprintname = response.getReturnValue();
                        if(quoteprintname === 'Error'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            "title": "Error!",
                            "message": "Only System Admin, BusinessAdmin, Booking team and Deal Desk users can select Microsoft Word for output Format"
                        });
                        toastEvent.fire();
                           
                        }
                        else if(quoteprintname === 'NotApproved'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            "title": "Error!",
                            "message": "Quote Not Approved"
                        });
                        toastEvent.fire();
                           
                        }
                        else{
                        //Success message display logic.
                        //var toastEvent = $A.get("e.force:showToast");
                        //toastEvent.setParams({
                        //    "title": "Success!",
                        //    "message": "Quote record has been updated successfully."
                       // });
                       // toastEvent.fire();
                        var actionpar = component.get('c.updateparlocvalues');
                console.log('Inside helper');
                actionpar.setParams({
                    "qId": component.get("v.recordId"),
                    "selectedsec": component.get("v.selectedSectionsList"),
                    "template":	component.find("template").get("v.value"),
                    "isPrintGenericDrawer" : genericdrawers,
                    "isProductsUnbundled" : productsunbundled,
                "zerodollars" : zerodollars//Added for SF-BUG-725		
                 });
               
                actionpar.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS"){
                    }
                });
                
                $A.enqueueAction(actionpar);
                               
                        component.set('v.quoteprintname',quoteprintname);
                        console.log('Cmponent value : '+component.get('v.quoteprintname'));
                        console.log('Quote name : '+quoteprintname);
                        helper.deleteQuotePrintRecord(component,helper);
                        }
                        // window.open("/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("v.recordId")+"&TemplateGroup=QuotePrintoutBase,CongaQuotePrintOutSections,QuotePrintoutExhibits &SelectTemplates=0 &WPD=1 &DS7=1 &templateid={!Quote.Conga_Template_Id__c},{!Quote.Conga_Section_Values__c},{!Quote.Conga_Exhibit_Values__c} &SC1=SalesforceFile &DataTagEnable=1{!Quote.Conga_Section_Values__c} {!Quote.Conga_Printout_Output_Format__c} &FP0=2 &OFN={!Quote.QuoteNumber}+{!Quote.Quote_Revision__c} &QueryId=[QLICustom]a1C1k000000A26K,[ParLocation]a1C1k000000A1vw,[PIC]a1C1k000000A2OP,[BNDLE]a1C1k000000A26Z,[IVX]a1C1k000000A27S?pv0={!Quote.Id}~pv1=IVX, [PCWE]a1C1k000000A27S?pv0={!Quote.Id}~pv1=Performance+Center+(w.+EMM), [PCPO]a1C1k000000A27S?pv0={!Quote.Id}~pv1=Performance+Center+(PSOG+only), [CU]a1C1k000000A27S?pv0={!Quote.Id}~pv1=CRx+Upgrade, [SN]a1C1k000000A27S?pv0={!Quote.Id}~pv1=ServiceNow, [AESS]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Aesynt+Support+Services, [GAOMCL]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Generally+Available+(OMCL), [OMCLCP]a1C1k000000A28u?pv0={!Quote.Id}~pv1=OMCL+Cap+Program, [ROMCL]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Replacement+(OMCL), [SPO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+Product+Only, [SSO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+Service+Only, [SBPL]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+by+Par+Location, [DBPL]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location, [PCP1PDO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Print+Config+Pictures+(1+pic+default+option), [DPLWP]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location+with+pictures, [DBPLWPAS]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location+with+pictures+and+signoff, [SBPLWP]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+by+Par+Location+with+pictures,[UNBUNDLE]a1C1k000000A28G,[SALESTEXT]a1C1k000000A2N7, [ZERODOLLAR]a1C1k000000A2NC &DV0={!IF(OR(ISPICKVAL(Quote.Status,'E0013'),ISPICKVAL(Quote.Status,'E0021'),ISPICKVAL(Quote.Status,'E0014')),'','DRAFT')}");
                       // window.open("https://omnicell--fulldev.lightning.force.com//apex/APXTConga4__Conga_Composer?SolMgr=1 &serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("{!v.recordId}"));
                        //window.open("https://omnicell--fulldev.lightning.force.com//apex/APXTConga4__Conga_Composer?SolMgr=1 &serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("{!v.recordId}"));
                        //var navEvt = $A.get("e.force:navigateToSObject");
                        //navEvt.setParams({
                            //"recordId": component.get("{!v.recordId}"),
                        //});
                        //navEvt.fire();
                       // window.location ="/"+component.get("v.recordId");
                        
                    }else if (state === "INCOMPLETE") {
                        //Offline message display logic.
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "OFFLINE!",
                            "message": "You are in offline."
                        });
                        toastEvent.fire();
                    }else if (state === "ERROR") {
                        //Error message display logic.
                        var errors = response.getError();
                        console.log("error in Save"+errors);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }else {
                        //Unknown message display logic.
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "UNKOWN!",
                            "message": "Unknown error."
                        });
                        toastEvent.fire();
                    }
                });
                
                $A.enqueueAction(action);
        }
        
        
	},
    //Updated following method by sravan for SOW changes
    handleDocChange: function (component, event, helper) {
        //Get the Selected values
        var canlansel = component.get("v.cannedlansel");   
        var prevvalcan = component.get("v.prevselectedDocsList");
        var selectedValues = event.getParam("value");
        //Update the Selected Values  
        component.set("v.selectedDocsList", selectedValues);
        if(canlansel === false){
        	for(var i = 0; i<selectedValues.length; i++)
    		{
            	console.log("canlansel : "+canlansel);
            	prevvalcan.push(selectedValues[i]);
            	console.log("prevvvalcan : "+prevvalcan);
    		}
        }
        var newsel = component.get("v.selectedDocsList");
        var layout = component.find("layout").get("v.value");
        console.log("newsel : "+newsel);
        if(canlansel === "true"){
            console.log("prevvvalcan : "+prevvalcan);
            component.set("v.prevselectedDocsList",selectedValues);
            var savecan = component.get("c.saveCannedLan");
            savecan.setParams({ "terms" : component.get("v.terms"),
                               "quoteId" : component.get("v.recordId"),
                               "prevselectedCannedLan": prevvalcan,
                               "newselectedCannedLan" : newsel,
                               "layout" :layout,
                               "editcanlansel" : component.get("v.cannedlansel")});
            savecan.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    console.log('updated!!!!!');
                    var storeResponse = response.getReturnValue();
                    component.set("v.terms",storeResponse);
                }
                else{
                    console.log('failed savecan');
                }
            });
            $A.enqueueAction(savecan);
        }
    },
    handleExhibitChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.selectedexhibitsList", selectedValues);
    },
    handleSectionChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.selectedSectionsList", selectedValues);
    },
    resetterms : function(component,event,helper){
     /* var layout = component.find("layout").get("v.value");
        var selectedValues = component.get("v.selectedDocsList");
        var action = component.get('c.getCannedLanguage');
       // var action = component.get("c.getCannedLanguage");
        action.setParams({ "quoteId" : component.get("v.recordId"),"layout" : layout,"selectedCannedLan" : selectedValues,"reset" : "True"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                component.set("v.terms",storeResponse);
                component.set("v.resetterms",storeResponse);
                console.log(component.get("v.terms"));
            }
        });
        $A.enqueueAction(action);

     //component.set("v.terms",component.get("v.resetterms")); */
     /*Following lines of code added for SF-BUG-287*/
     /* if (confirm("Do you want to reset Canned Language?")) {*/
      component.set("v.cannedlansel","false");//Added by sravan for SOW changes	
      component.set("v.terms","");
      component.set("v.selectedDocsList",[]);
      component.set("v.resettrue",true); 
      console.log("RESTE True reset method: "+component.get("v.resettrue"));
      component.set("v.iframerender","false");
      component.set("v.isEditButtonClicked",false);//Added as part of sow anned language fixes
     /*}else {
    		alert("You pressed Cancel for Reset!");
  			}*/
     /*Above lines of code added for SF-BUG-287*/
    },
    editcannedlanguage : function(component,event,helper){
     //component.set("v.editTrue","true");   
	component.set("v.cannedlansel","true");//Added by sravan for SOW changes    
        console.log("Function started");
	component.set("v.isEditButtonClicked",true);
        var layout = component.find("layout").get("v.value");
        var selectedValues = component.get("v.selectedDocsList");
        var PastselectedValues = component.get("v.pastselected");
        var resettrue = component.get("v.resettrue");
        console.log("RESTE True : "+component.get("v.resettrue"));
        console.log("selectedValues"+selectedValues);
        /*Below Code added for SF-BUG-287 */
		var actionchk = component.get("c.chkCannedLanguage"); 
		actionchk.setParams({ "quoteId" : component.get("v.recordId"),"selectedCannedLan" : selectedValues});
		actionchk.setCallback(this, function(response) {
            var statechk = response.getState();
            if (statechk === "SUCCESS") {
                
                var storeResponsechk = response.getReturnValue();
                console.log("Resoponce1 is :" +storeResponsechk);
                component.set("v.checkChnCan",storeResponsechk);
                console.log("Resoponce2 is =:"+component.get("v.checkChnCan"));
                if (storeResponsechk === "TRUE") {
                    console.log("Inside TRUE  :");
                    var action = component.get('c.getCannedLanguage');
                   // var action = component.get("c.getCannedLanguage");
                    action.setParams({ "quoteId" : component.get("v.recordId"),"layout" : layout,"selectedCannedLan" : selectedValues,"resettrue" : resettrue});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            
                            var storeResponse = response.getReturnValue();
                            //console.log(storeResponse);
                            component.set("v.terms",storeResponse);
                            component.set("v.resetterms",storeResponse);
                            //console.log(component.get("v.terms"));
                        }
                    });
                    $A.enqueueAction(action);
                    
                   component.set("v.iframerender","true");
                }
                if (storeResponsechk === "FALSE") {
                    console.log("Inside FALSE  :");
                    if (confirm("Your Changes will reset Canned Language(Proceed)?")) 
                    {
                       var action = component.get('c.getCannedLanguage');
                   // var action = component.get("c.getCannedLanguage");
                    action.setParams({ "quoteId" : component.get("v.recordId"),"layout" : layout,"selectedCannedLan" : selectedValues,"resettrue" : resettrue});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            
                            var storeResponse = response.getReturnValue();
                            //console.log(storeResponse);
                            component.set("v.terms",storeResponse);
                            component.set("v.resetterms",storeResponse);
                            //console.log(component.get("v.terms"));
                        }
                    });
                    $A.enqueueAction(action);
                    
                   component.set("v.iframerender","true");
                    }
                      
                else {
                    //alert("You pressed Cancel for Reset!");  
                    var action4 = component.get("c.selectedCannedLan");
                    action4.setParams({ quoteId : component.get("v.recordId") });
                    action4.setCallback(this, function(response) {
                    var state4 = response.getState();
                     if (state4 === "SUCCESS") {
                            var storeResponse4 = response.getReturnValue();
                            component.set("v.selectedDocsList",storeResponse4);
                            component.set("v.selectedDocsListPrevious",storeResponse4);
                            component.set("v.pastselected",storeResponse4);                           
                            helper.editcannedlanguageinit(component,helper);

                        }
                    });
                    $A.enqueueAction(action4);
  						}
                }
                
            } else if (stateChk == 'ERROR') {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(actionchk);

        
		/*Above Code added for SF-BUG-287 */
        
        /* Following Block is commented and shifted inside */
        /*var action = component.get('c.getCannedLanguage');
       // var action = component.get("c.getCannedLanguage");
        action.setParams({ "quoteId" : component.get("v.recordId"),"layout" : layout,"selectedCannedLan" : selectedValues,"resettrue" : resettrue});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                //console.log(storeResponse);
                component.set("v.terms",storeResponse);
                component.set("v.resetterms",storeResponse);
                //console.log(component.get("v.terms"));
            }
        });
        $A.enqueueAction(action);
        
       component.set("v.iframerender","true"); */
       /* Following Block is commented and shifted inside */ 
    },
    formatChange : function (component, event, helper){
        
    },
    layoutchange : function(component,event,helper){
        console.log("User"+component.get("v.checkUser"));
         
        if(!component.get("v.checkUser")){
            var selval = component.get("v.selectedlayoutchange");
            //component.find("layout").set("v.value", selval);
           component.set("v.selectedlayout",selval);
        var toastEvent = $A.get("e.force:showToast");
               		toastEvent.setParams({
                    "title": "Error!",
                    "message": "Only Deal Desk, Legal, Admins are allowed to Change Print Layout."
                });
                toastEvent.fire();
        }
        else{
        console.log("inside layoutchange");
    	var layout = component.find("layout").get("v.value");
        console.log("Layout : "+layout);
        if(layout === "Omnicell" || layout === "Change Order Omnicell"){
            component.set("v.omnicelllayout","true");
            component.set("v.aesyntlayout","false");
        }
        if(layout === "Aesynt" || layout === "Change Order Aesynt"){
            component.set("v.aesyntlayout","true");
        	component.set("v.omnicelllayout","false");
        }
        component.set("v.selectedDocsList",'');
        }
    },
    sendtoopp : function(component,event,helper){
        component.set("v.selectedbutton","sendtoopp");
        var quoteprintname;
        var quoteId = component.get("v.recordId");
         var isdraft=false;
		var selectedValues = component.get("v.selectedDocsList");
        var selectedExhibits = component.get("v.selectedexhibitsList");
        var selectedSections = component.get("v.selectedSectionsList");
        var layout = component.find("layout").get("v.value");
        var language = component.find("lang").get("v.value");
        var template = component.find("template").get("v.value");
        var agreementId = '';//component.find("agreementId").get("v.value");//added by jay cr-18666
        var output = component.find("output").get("v.value");
         var usalist = "false";
        var zerodollars = "false";
        var genericdrawers = "false";
        var productsunbundled = "false";
        var serviceonly = "false";
        var noofpictures = 0;
        var renderer = component.get("v.iframerender");
        var isNotServiceOrderType = component.get("v.isNotServiceOrderType");
        var editedterms;
		var isEditClicked = component.get("v.isEditButtonClicked");
        if(isNotServiceOrderType == true)
        {
            usalist = component.get("v.usalist");
            zerodollars = component.get("v.zerodollars");
            genericdrawers = component.get("v.genericdrawers");
            productsunbundled = component.get("v.productsunbundled");
            serviceonly = component.get("v.serviceonly");
            noofpictures = component.find("noofpictures").get("v.value");
        }
        var isSupplement = component.get("v.isSupplement");
        if(isSupplement)
        {
          agreementId = component.find("agreementId").get("v.value");//added by jay cr-18666  
        }
        if(renderer === "true" && isNotServiceOrderType == true )
       		editedterms = component.find("editedterms").get("v.value");
        else
            //editedterms = ""; commented and replaced by below line for SF-BUG-287 
            editedterms = component.get("v.terms");
        var selectedcannprevious = component.get("v.selectedDocsListPrevious");
        //var editedterms = component.find("editedterms").get("v.value");
        
        console.log('selected canned Language : '+selectedValues);
        console.log('selected Exhibits : '+selectedExhibits);
        console.log('selected sections : '+selectedSections);
        console.log('Layout : '+layout);
        console.log('OutPut : '+output);
        console.log('Language : '+language);
        console.log('Template : '+template);
        console.log('USA List  : '+usalist); 
        console.log('zerodollars  : '+zerodollars);
        console.log('genericdrawers : '+genericdrawers);
        console.log('productsunbundled : '+productsunbundled);
        console.log('No of Pictures: ' + noofpictures);
        var action = component.get('c.updateQuote');
        action.setParams({
            "quoteId": component.get("v.recordId"),
            "selectedCannedLan": selectedValues,
            "selectedExhibits": selectedExhibits,
            "selectedSections": selectedSections,
            "layout" : layout,
            "language": language,
            "template": template,
            "output": output,
            "usalist": usalist,
            "zerodollars": zerodollars,
            "genericdrawers": genericdrawers,
            "productsunbundled": productsunbundled,
            "serviceonly":serviceonly,
            "noofpictures": noofpictures,
            "editedterms": editedterms,
            "selcannedPrev":selectedcannprevious,
            "isdraft":isdraft,
            "agreementType":agreementId,
            "isEditButtonClicked":isEditClicked
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            console.log("state="+state)
            if (state === "SUCCESS"){
                quoteprintname = response.getReturnValue();
                if(quoteprintname === 'Error'){
                	var toastEvent = $A.get("e.force:showToast");
               		toastEvent.setParams({
                    "title": "Error!",
                    "message": "Only System Admin, BusinessAdmin, Booking team and Deal Desk users can select Microsoft Word for output Format"
                });
                toastEvent.fire();
                   
                }
                else if(quoteprintname === 'NotApproved'){
                	var toastEvent = $A.get("e.force:showToast");
               		toastEvent.setParams({
                    "title": "Error!",
                    "message": "Quote Not Approved"
                });
                toastEvent.fire();
                }
                else{
                //Success message display logic.
                //var toastEvent = $A.get("e.force:showToast");
                //toastEvent.setParams({
                //    "title": "Success!",
                //    "message": "Quote record has been updated successfully."
               // });
               // toastEvent.fire();
               var actionpar = component.get('c.updateparlocvalues');
		console.log('Inside helper');
        actionpar.setParams({
            "qId": component.get("v.recordId"),
            "selectedsec": component.get("v.selectedSectionsList"),
            "template":	component.find("template").get("v.value"),
            "isPrintGenericDrawer" : genericdrawers,
            "isProductsUnbundled" : productsunbundled,
	    "zerodollars" : zerodollars//Added for SF-BUG-725
         });
       
        actionpar.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
            }
        });
        
        $A.enqueueAction(actionpar);
                component.set('v.quoteprintname',quoteprintname);
                console.log('Cmponent value : '+component.get('v.quoteprintname'));
                console.log('Quote name : '+quoteprintname);
                //helper.sendQuotePrintRecord(component,helper);
                helper.deleteQuotePrintRecord(component,helper);
                }
                // window.open("/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("v.recordId")+"&TemplateGroup=QuotePrintoutBase,CongaQuotePrintOutSections,QuotePrintoutExhibits &SelectTemplates=0 &WPD=1 &DS7=1 &templateid={!Quote.Conga_Template_Id__c},{!Quote.Conga_Section_Values__c},{!Quote.Conga_Exhibit_Values__c} &SC1=SalesforceFile &DataTagEnable=1{!Quote.Conga_Section_Values__c} {!Quote.Conga_Printout_Output_Format__c} &FP0=2 &OFN={!Quote.QuoteNumber}+{!Quote.Quote_Revision__c} &QueryId=[QLICustom]a1C1k000000A26K,[ParLocation]a1C1k000000A1vw,[PIC]a1C1k000000A2OP,[BNDLE]a1C1k000000A26Z,[IVX]a1C1k000000A27S?pv0={!Quote.Id}~pv1=IVX, [PCWE]a1C1k000000A27S?pv0={!Quote.Id}~pv1=Performance+Center+(w.+EMM), [PCPO]a1C1k000000A27S?pv0={!Quote.Id}~pv1=Performance+Center+(PSOG+only), [CU]a1C1k000000A27S?pv0={!Quote.Id}~pv1=CRx+Upgrade, [SN]a1C1k000000A27S?pv0={!Quote.Id}~pv1=ServiceNow, [AESS]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Aesynt+Support+Services, [GAOMCL]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Generally+Available+(OMCL), [OMCLCP]a1C1k000000A28u?pv0={!Quote.Id}~pv1=OMCL+Cap+Program, [ROMCL]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Replacement+(OMCL), [SPO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+Product+Only, [SSO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+Service+Only, [SBPL]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+by+Par+Location, [DBPL]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location, [PCP1PDO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Print+Config+Pictures+(1+pic+default+option), [DPLWP]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location+with+pictures, [DBPLWPAS]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location+with+pictures+and+signoff, [SBPLWP]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+by+Par+Location+with+pictures,[UNBUNDLE]a1C1k000000A28G,[SALESTEXT]a1C1k000000A2N7, [ZERODOLLAR]a1C1k000000A2NC &DV0={!IF(OR(ISPICKVAL(Quote.Status,'E0013'),ISPICKVAL(Quote.Status,'E0021'),ISPICKVAL(Quote.Status,'E0014')),'','DRAFT')}");
               // window.open("https://omnicell--fulldev.lightning.force.com//apex/APXTConga4__Conga_Composer?SolMgr=1 &serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("{!v.recordId}"));
                //window.open("https://omnicell--fulldev.lightning.force.com//apex/APXTConga4__Conga_Composer?SolMgr=1 &serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("{!v.recordId}"));
            	//var navEvt = $A.get("e.force:navigateToSObject");
    			//navEvt.setParams({
        			//"recordId": component.get("{!v.recordId}"),
    			//});
    			//navEvt.fire();
               // window.location ="/"+component.get("v.recordId");
                
            }else if (state === "INCOMPLETE") {
                //Offline message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "OFFLINE!",
                    "message": "You are in offline."
                });
                toastEvent.fire();
            }else if (state === "ERROR") {
                //Error message display logic.
                var errors = response.getError();
                console.log("error in Save"+errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "message": errors[0].message
                });
                toastEvent.fire();
            }else {
                //Unknown message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "UNKOWN!",
                    "message": "Unknown error."
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
        
    },
    draftPrint : function(component, event, helper) {
        component.set("v.selectedbutton","draft");
        var quoteprintname;
        var isdraft=true;
        var quoteId = component.get("v.recordId");
		var selectedValues = component.get("v.selectedDocsList");
        var selectedExhibits = component.get("v.selectedexhibitsList");
        var selectedSections = component.get("v.selectedSectionsList");
        var layout = component.find("layout").get("v.value");
        var language = component.find("lang").get("v.value");
        var template = component.find("template").get("v.value");
        var agreementId = '';//component.find("agreementId").get("v.value");//added by jay cr-18666
        var output = component.find("output").get("v.value");
        var usalist = "false";
        var zerodollars = "false";
        var genericdrawers = "false";
        var productsunbundled = "false";
        var serviceonly = "false";
        var noofpictures = 0;
        var renderer = component.get("v.iframerender");
        var isNotServiceOrderType = component.get("v.isNotServiceOrderType");
        var editedterms;
		var isEditClicked = component.get("v.isEditButtonClicked");
        console.log('SVD2'+component.find("template").get("v.value"));//IBA-3242
        if(isNotServiceOrderType == true ){
            usalist = component.get("v.usalist");
            zerodollars = component.get("v.zerodollars");
            genericdrawers = component.get("v.genericdrawers");
            productsunbundled = component.get("v.productsunbundled");
            serviceonly = component.get("v.serviceonly");
            noofpictures = component.find("noofpictures").get("v.value");
        }
        var isSupplement = component.get("v.isSupplement");
        var ismsSupplement = component.get("v.ismaSupplement");//added for IBA-2290
     /*    if(isSupplement)
        {
          agreementId = component.find("agreementId").get("v.value");//added by jay cr-18666  
        }*/
        
       if(isSupplement && ismsSupplement ){
          agreementId = component.find("agreementId2").get("v.value");//added by jay cr-18666  //added for IBA-2290
        }
        else if(isSupplement){
             agreementId = component.find("agreementId").get("v.value");//added by jay cr-18666
        }
        if(renderer === "true" && isNotServiceOrderType == true )
       		editedterms = component.find("editedterms").get("v.value");
        else
            editedterms = component.get("v.terms");
        var selectedcannprevious = component.get("v.selectedDocsListPrevious");
        
        console.log("Edited canned Lan : "+editedterms);
        console.log('selected canned Language : '+selectedValues);
        console.log('selected Exhibits : '+selectedExhibits);
        console.log('selected sections : '+selectedSections);
        console.log('Layout : '+layout);
        console.log('OutPut : '+output);
        console.log('Language : '+language);
        console.log('Template : '+template);
        console.log('USA List  : '+usalist); 
        console.log('zerodollars  : '+zerodollars);
        console.log('genericdrawers : '+genericdrawers);
        console.log('productsunbundled : '+productsunbundled);
        console.log('No of Pictures: ' + noofpictures);
        if(template=='CarePlus'){//IBA-3242 Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
            genericdrawers = true;
        }
        if(template=='Please Select'){ //Validation Add //IBA-3242
            console.log('Please Select '+template);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                       "message": "Please Select a Base Template",
                       "duration": 1000,    
                		"type": 'warning'    
            });
            toastEvent.fire();
        }
        else if(isSupplement && agreementId=='Please Select' && template !='CarePlus' && template !='ServerScale Subscription'){ //IBA-6201 Saptarsha Panthi. Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
            console.log('Please Select isSupplement '+isSupplement);
            console.log('Please Select template '+template);
            console.log('Please Select Agree 283'+agreementId);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                       "message": "Please Select Agreement",
                       "duration": 1000,    
                		"type": 'warning'
            });
            toastEvent.fire();
        }
        else{
            var action = component.get('c.updateQuote');
            action.setParams({
                "quoteId": component.get("v.recordId"),
                "selectedCannedLan": selectedValues,
                "selectedExhibits": selectedExhibits,
                "selectedSections": selectedSections,
                "layout" : layout,
                "language": language,
                "template": template,
                "output": output,
                "usalist": usalist,
                "zerodollars": zerodollars,
                "genericdrawers": genericdrawers,
                "productsunbundled": productsunbundled,
                "serviceonly":serviceonly,
                "noofpictures": noofpictures,
                "editedterms": editedterms,
                "selcannedPrev":selectedcannprevious,
                "isdraft":isdraft,
                "agreementType":agreementId,
                "isEditButtonClicked":isEditClicked
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                
                console.log("state="+state)
                console.log("quoteprintname= "+quoteprintname)
                if (state === "SUCCESS"){
                    quoteprintname = response.getReturnValue();
                    if(quoteprintname === 'Error'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": "Only System Admin, BusinessAdmin, Booking team and Deal Desk users can select Microsoft Word for output Format"
                    });
                    toastEvent.fire();
                       
                    }
                    else if(quoteprintname === 'NotApproved'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": "Quote Not Approved"
                    });
                    toastEvent.fire();
                    }
                    else{
                    //Success message display logic.
                    //var toastEvent = $A.get("e.force:showToast");
                    //toastEvent.setParams({
                    //    "title": "Success!",
                    //    "message": "Quote record has been updated successfully."
                   // });
                   // toastEvent.fire();
                   var actionpar = component.get('c.updateparlocvalues');
            console.log('Inside helper');
            actionpar.setParams({
                "qId": component.get("v.recordId"),
                "selectedsec": component.get("v.selectedSectionsList"),
                "template":	component.find("template").get("v.value"),
                "isPrintGenericDrawer" : genericdrawers,
                "isProductsUnbundled" : productsunbundled,
            "zerodollars" : zerodollars//Added for SF-BUG-725
             });
           
            actionpar.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                }
            });
            
            $A.enqueueAction(actionpar);
                    component.set('v.quoteprintname',quoteprintname);
                    console.log('Cmponent value : '+component.get('v.quoteprintname'));
                    console.log('Quote name : '+quoteprintname);
                    //helper.draftprintout(component,helper);
                    helper.deleteQuotePrintRecord(component,helper);
                    }
                    // window.open("/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("v.recordId")+"&TemplateGroup=QuotePrintoutBase,CongaQuotePrintOutSections,QuotePrintoutExhibits &SelectTemplates=0 &WPD=1 &DS7=1 &templateid={!Quote.Conga_Template_Id__c},{!Quote.Conga_Section_Values__c},{!Quote.Conga_Exhibit_Values__c} &SC1=SalesforceFile &DataTagEnable=1{!Quote.Conga_Section_Values__c} {!Quote.Conga_Printout_Output_Format__c} &FP0=2 &OFN={!Quote.QuoteNumber}+{!Quote.Quote_Revision__c} &QueryId=[QLICustom]a1C1k000000A26K,[ParLocation]a1C1k000000A1vw,[PIC]a1C1k000000A2OP,[BNDLE]a1C1k000000A26Z,[IVX]a1C1k000000A27S?pv0={!Quote.Id}~pv1=IVX, [PCWE]a1C1k000000A27S?pv0={!Quote.Id}~pv1=Performance+Center+(w.+EMM), [PCPO]a1C1k000000A27S?pv0={!Quote.Id}~pv1=Performance+Center+(PSOG+only), [CU]a1C1k000000A27S?pv0={!Quote.Id}~pv1=CRx+Upgrade, [SN]a1C1k000000A27S?pv0={!Quote.Id}~pv1=ServiceNow, [AESS]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Aesynt+Support+Services, [GAOMCL]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Generally+Available+(OMCL), [OMCLCP]a1C1k000000A28u?pv0={!Quote.Id}~pv1=OMCL+Cap+Program, [ROMCL]a1C1k000000A28u?pv0={!Quote.Id}~pv1=Replacement+(OMCL), [SPO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+Product+Only, [SSO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+Service+Only, [SBPL]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+by+Par+Location, [DBPL]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location, [PCP1PDO]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Print+Config+Pictures+(1+pic+default+option), [DPLWP]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location+with+pictures, [DBPLWPAS]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Detail+by+Par+Location+with+pictures+and+signoff, [SBPLWP]a1C1k000000A2AH?pv0={!Quote.Id}~pv1=Summary+by+Par+Location+with+pictures,[UNBUNDLE]a1C1k000000A28G,[SALESTEXT]a1C1k000000A2N7, [ZERODOLLAR]a1C1k000000A2NC &DV0={!IF(OR(ISPICKVAL(Quote.Status,'E0013'),ISPICKVAL(Quote.Status,'E0021'),ISPICKVAL(Quote.Status,'E0014')),'','DRAFT')}");
                   // window.open("https://omnicell--fulldev.lightning.force.com//apex/APXTConga4__Conga_Composer?SolMgr=1 &serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("{!v.recordId}"));
                    //window.open("https://omnicell--fulldev.lightning.force.com//apex/APXTConga4__Conga_Composer?SolMgr=1 &serverUrl={!API.Partner_Server_URL_370} &Id="+component.get("{!v.recordId}"));
                    //var navEvt = $A.get("e.force:navigateToSObject");
                    //navEvt.setParams({
                        //"recordId": component.get("{!v.recordId}"),
                    //});
                    //navEvt.fire();
                   // window.location ="/"+component.get("v.recordId");
                    
                }else if (state === "INCOMPLETE") {
                    //Offline message display logic.
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "OFFLINE!",
                        "message": "You are in offline."
                    });
                    toastEvent.fire();
                }else if (state === "ERROR") {
                    //Error message display logic.
                    var errors = response.getError();
                    console.log("error in Save"+errors);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                }else {
                    //Unknown message display logic.
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "UNKOWN!",
                        "message": "Unknown error."
                    });
                    toastEvent.fire();
                }
            });
            
            $A.enqueueAction(action);
        }
        
	},
    sendToVF : function(component, event, helper) {
         component.set("v.iframerender","true");
        var message = component.get("v.message");
        var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, vfOrigin);
    },
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);      
    },
    //IBA-1736 : Pabitra
    //close the Print Error confirmation dialog and call helper to show message
    closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", "false");
      helper.closeModal(component,helper);
   },//end IBA-1736
  
  //IBA-1736 : Pabitra
  //close the dialog and go for print
   submitPrint: function(component, event, helper) {
      // Set isModalOpen attribute to false
      component.set("v.isModalOpen", "false");
      helper.submitPrint(component,helper);
   }//end IBA-1736
    
})