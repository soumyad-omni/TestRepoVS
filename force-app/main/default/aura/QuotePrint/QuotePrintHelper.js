({
    initializeprint : function(component,helper){
        /////////////Added by Sravan on 21 AUG
        component.set("v.buttonsdisabled","true");//Added by sravan for SF-BUG-724 on 2 MARCH
        var initializequoteprint = component.get("c.initializePrint");
        initializequoteprint.setParams({ "qId" : component.get("v.recordId") });
        initializequoteprint.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
              console.log('initializing print'); 
            }
            else{
                console.log('failed initializing print');
            }
        });
        $A.enqueueAction(initializequoteprint);
        
        
        
        /////////Added by Sravan on 21 AUG
    },
    /////////Added by Sravan on 21 AUG
    comparequotetrue : function(component,helper){
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
        /* Added by DG for 259 & 261 */
        /*console.log('Inside Do Init');
        var action8 = component.get("c.checkPrintCurrency");
        var quoteId = component.get("v.recordId");
        action8.setParams({ "quoteId": component.get("v.recordId")          
        });        
        action8.setCallback(this, function(response) {
            var state = response.getState();
            console.log('after call state :'+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.checkPrintCurrency1",storeResponse);
                console.log('Inside Successs' + storeResponse);
                console.log('Inside Successs' + component.get("v.checkPrintCurrency1"));
            }
        });
        $A.enqueueAction(action8);*/
        /* Added by DG for 259 and 261 */        
        var action5 = component.get("c.selectedPrintLayout");
        action5.setParams({ quoteId : component.get("v.recordId") });
        action5.setCallback(this, function(response) {
            var state5 = response.getState();
            if (state5 === "SUCCESS") {
                var storeResponse5 = response.getReturnValue();
                component.set("v.selectedlayout",storeResponse5);
                component.set("v.selectedlayoutchange",storeResponse5);
                console.log("selected value "+component.get("v.selectedlayout")+" "+storeResponse5);
                if(storeResponse5 === null)
                    component.find("layout").set("v.value", "Omnicell");
                else
                    component.find("layout").set("v.value", storeResponse5);       
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
            }
        });
        $A.enqueueAction(action5);
        
        //Commented by Sravan on April 4
       /* var upqtline = component.get("c.updateQuoteLine");
        upqtline.setParams({ qtId : component.get("v.recordId") });
        upqtline.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var storeResponse = response.getReturnValue();
                //component.set("v.checkUser",storeResponse);
                console.log('Updated!');
            }
        });
        $A.enqueueAction(upqtline);*/
        var action1 = component.get("c.CannedLanguagesOmnicell");
        //action.setParams({ campId : component.get("v.recordId") });
        action1.setCallback(this, function(response) {
            var state1 = response.getState();
            if (state1 === "SUCCESS") {
                var storeResponse1 = response.getReturnValue();
                var items = [];
                for (var i = 0; i < storeResponse1.length; i++) {
                    var item = {
                    "label": storeResponse1[i],
                    "value": storeResponse1[i],
                    };
                    items.push(item);
                }
                component.set("v.cannedlanguage",items);
                component.set("v.buttonsdisabled","false");//Added by sravan for SF-BUG-724 on 2 MARCH
            }
        });
        $A.enqueueAction(action1);
        var action2 = component.get("c.CannedLanguagesAesynt");
        //action.setParams({ campId : component.get("v.recordId") });
        action2.setCallback(this, function(response) {
            var state2 = response.getState();
            if (state2 === "SUCCESS") {
                var storeResponse2 = response.getReturnValue();
                var items = [];
                for (var i = 0; i < storeResponse2.length; i++) {
                    var item = {
                    "label": storeResponse2[i],
                    "value": storeResponse2[i],
                    };
                    items.push(item);
                }
                component.set("v.cannedlanaesynt",items);
                component.set("v.buttonsdisabled","false");//Added by sravan for SF-BUG-724 on 2 MARCH
            }
        });
        $A.enqueueAction(action2);
        
        var action4 = component.get("c.selectedCannedLan");
        action4.setParams({ quoteId : component.get("v.recordId") });
        action4.setCallback(this, function(response) {
            var state4 = response.getState();
            if (state4 === "SUCCESS") {
                var storeResponse4 = response.getReturnValue();
                component.set("v.selectedDocsList",storeResponse4);
                component.set("v.selectedDocsListPrevious",storeResponse4);
                component.set("v.pastselected",storeResponse4);
                /* Following Block of code is added for SF-BUG-287*/
                helper.editcannedlanguageinit(component,helper);
                /* Above Block of code is added for SF-BUG-287 */
                
            }
        });
        $A.enqueueAction(action4);
        var action6 = component.get("c.selectedexhibits");
        action6.setParams({ quoteId : component.get("v.recordId") });
        action6.setCallback(this, function(response) {
            var state6 = response.getState();
            if (state6 === "SUCCESS") {
                var storeResponse6 = response.getReturnValue();
                component.set("v.selectedexhibitsList",storeResponse6);
                //component.set("v.pastselected",storeResponse6);
                
            }
        });
        $A.enqueueAction(action6);
        //component.set("v.buttonsdisabled","false");//Commented by sravan for SF-BUG-724 on 2 MARCH
        /////////Added by Sravan on 21 AUG
      /*  var callbatch = component.get("c.callBatch");
        callbatch.setParams({ qId : component.get("v.recordId"), isPrintGenericDrawer : "TRUE"});
        callbatch.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.disabled","false");
                console.log('Updated!');
            }
        });
        $A.enqueueAction(callbatch);*/
    },
    editcannedlanguageinit : function(component,helper){
        var layout = component.find("layout").get("v.value");
        var selectedValues = component.get("v.selectedDocsList");
        var PastselectedValues = component.get("v.pastselected");
        var resettrue = component.get("v.resettrue");
        
        console.log("quoteId%%" + component.get("v.recordId"));
        console.log("layout%%%" + layout);
        console.log("selectedCannedLan%%%" + selectedValues);
        console.log("resettrue%%%" + resettrue);
                
        var action = component.get('c.getCannedLanguage');
       // var action = component.get("c.getCannedLanguage");       
        action.setParams({ "quoteId" : component.get("v.recordId"),"layout" : layout,"selectedCannedLan" : selectedValues,"resettrue" : resettrue});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                console.log("r%%%......." +storeResponse);
                component.set("v.terms",storeResponse);
                component.set("v.resetterms",storeResponse);
                console.log("j%%%........." +component.get("v.terms"));
            }
        });
        $A.enqueueAction(action);
        
       //component.set("v.iframerender","true"); 
    },
    deleteQuotePrintRecord : function(component,helper) {
        var selbutton = component.get("v.selectedbutton");
        var actioncheck = component.get('c.checkBatch');
        var batchstatus = "";
        actioncheck.setParams({
            "qId": component.get("v.recordId")
         });
        actioncheck.setCallback(this, function(response){
            var state = response.getState();
            component.set("v.disabled","true");
            component.set("v.buttonsdisabled","true");
            if (state === "SUCCESS"){
              var checkbatch  = response.getReturnValue();
                if(checkbatch === "finished"){
                    if(component.get("v.compexecute") === false){ // soumyad IBA-1632
                    component.set("v.compexecute", true); // soumyad IBA-1632
                    if(selbutton === "print")
                        helper.congaredirect(component,helper);
                    else if(selbutton === "draft")
                        helper.congaredirectdraft(component,helper);
                    else
                        helper.congaredirectsendtoopp(component,helper);
                    }
                }
                else if(checkbatch === "failed"){
                    batchstatus = "failed";
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "message": "Batches failed to execute, Please contact System Administrator",
                        "duration": 30000    
                        });
                        toastEvent.fire();
                   window.setTimeout(
    $A.getCallback(function() {
        window.location="/"+component.get("v.recordId");
    }), 20000
    ); 
                    
                    component.set("v.disabled","true");
                    component.set("v.buttonsdisabled","true");
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    if(batchstatus != "failed"){
                        toastEvent.setParams({
                        "mode": "pester",   
                        "message": "PROCESSING: Please wait, preparing data for the print.",
                        "duration": 30000  
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", true);
                    }
                }
                
            }
          
        });
        
        $A.enqueueAction(actioncheck);
        
        
       // if(urlcallback === '1'){
        //execute callApexMethod() again after 5 sec each
        if(batchstatus != "failed"){
            window.setInterval(
                $A.getCallback(function() { 
                    helper.deleteQuotePrintRecord(component,helper);
                }), 40000
            );
        }
          //}
    },
    
    sendQuotePrintRecord : function(component,helper) {
      /*  var qpname = component.get("v.quoteprintname");
        var url;
        console.log('QP Name from helper : '+qpname);
        var action = component.get('c.sendQuotePrintRecord');
        console.log('Inside helper');
        action.setParams({
            "qpName": qpname,
            "quoteId": component.get("v.recordId")
         });
       
        action.setCallback(this, function(response){
            var state = response.getState();
            url = response.getReturnValue();
            console.log("URL : "+url);
            console.log("state="+state)
            if (state === "SUCCESS"){
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
                console.log("error in Delete"+errors);
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
        
        $A.enqueueAction(action);*/
        var actioncheck = component.get('c.checkBatch');
        actioncheck.setParams({
            "qId": component.get("v.recordId")
         });
        actioncheck.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS"){
              var checkbatch  = response.getReturnValue();
                if(checkbatch === "finished"){
                    //helper.printurl(component,helper);
                    helper.congaredirectsendtoopp(component,helper);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "message": "PROCESSING: Please wait, preparing data for the print.",
                        "duration": 6000000    
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", true);
                        
                }
                
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
                console.log("error in Delete"+errors);
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
        
        $A.enqueueAction(actioncheck);
        
        /*var actioncal = component.get('c.updatequotelinewithtotalvaluesupdate');
                console.log('Inside helper updated quote lines');
                actioncal.setParams({
                "qId": component.get("v.recordId")
                });
                
                actioncal.setCallback(this, function(response){
                    console.log("inside actioncal setback");
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var retval = response.getReturnValue();
                        console.log("URL : "+url);
                        console.log("inside actioncal setback success");
                        if(retval === 'updated'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": " Redirecting to Conga."
                        });
                        toastEvent.fire();
                        window.location = url;
                        }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "message": retval+": Please wait, preparing data for the print.",
                        "duration": 5000000
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", true);
                        }
                    }
                    else{
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Occured while updating quote lines"
                        });
                        toastEvent.fire();*/
                        
                    //}
    /*
                    var that=this
                    setTimeout( function(){
                    $(that).parent().parent().css('visibility','hidden');
                    },500000000);         */       //});
                //$A.enqueueAction(actioncal);
        window.setInterval(
            $A.getCallback(function() { 
                helper.sendQuotePrintRecord(component,helper);
            }), 30000
        );
        
    },
    draftprintout : function(component,helper) {
       /* var qpname = component.get("v.quoteprintname");
        var url;
        console.log('QP Name from helper : '+qpname);
        var action = component.get('c.quotedraftprint');
        console.log('Inside helper');
        action.setParams({
            "qpName": qpname,
            "quoteId": component.get("v.recordId")
         });
        action.setCallback(this, function(response){
            var state = response.getState();
            url = response.getReturnValue();
            console.log("URL : "+url);
            console.log("state="+state)
            if (state === "SUCCESS"){
                
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
                console.log("error in Delete"+errors);
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
        
        $A.enqueueAction(action);*/
        var actioncheck = component.get('c.checkBatch');
        actioncheck.setParams({
            "qId": component.get("v.recordId")
         });
        actioncheck.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS"){
              var checkbatch  = response.getReturnValue();
                if(checkbatch === "finished"){
                    //helper.printurl(component,helper);
                    helper.congaredirectdraft(component,helper);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "message": "PROCESSING: Please wait, preparing data for the print.",
                        "duration": 6000000    
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", true);
                        
                }
                
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
                console.log("error in Delete"+errors);
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
        
        $A.enqueueAction(actioncheck);
        
        /* var actioncal = component.get('c.updatequotelinewithtotalvaluesupdate');
                console.log('Inside helper updated quote lines');
                actioncal.setParams({
                "qId": component.get("v.recordId")
                });
                actioncal.setCallback(this, function(response){
                    console.log("inside actioncal setback");
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var retval = response.getReturnValue();
                        console.log("URL : "+url);
                        console.log("inside actioncal setback success");
                        if(retval === 'updated'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": " Redirecting to Conga."
                        });
                        toastEvent.fire();
                        window.location = url;
                        }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "message": retval+": Please wait, preparing data for the print.",
                        "duration": 5000000    
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", true);
                        }
                    }
                    else{
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Occured while updating quote lines"
                        });
                        toastEvent.fire();
                        */
                        
                    //}
                //});
                //$A.enqueueAction(actioncal);
        window.setInterval(
            $A.getCallback(function() { 
                helper.draftprintout(component,helper);
            }), 30000
        );
    },
    congaredirectdraft : function(component,helper) {
        component.set("v.isDraftPrint", "true");//IBA-1736 : Pabitra
        var qpname = component.get("v.quoteprintname");
        var url;
        console.log('QP Name from helper : '+qpname);
        var action = component.get('c.quotedraftprint');
        console.log('Inside helper');
        action.setParams({
            "qpName": qpname,
            "quoteId": component.get("v.recordId")
         });
        /*var toastEventcal = $A.get("e.force:showToast");
                        toastEventcal.setParams({
                        "message": "Please wait, Preparing data for the print."
                        });
                        toastEventcal.fire();*/
        action.setCallback(this, function(response){
            var state = response.getState();
            url = response.getReturnValue();
            console.log("URL : "+url);
            console.log("state="+state)
            if (state === "SUCCESS"){
                //Success message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Redirecting to Conga."
                });
                toastEvent.fire();
                console.log("url : "+url);
                window.location = url;
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
                console.log("error in Delete"+errors);
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
        
        // soumyad IBA-1632 start
        var action1 = component.get("c.compareQuoteLine");
        action1.setParams({
            "recordID": component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var statecomp = response.getState();
            if(statecomp==='SUCCESS'){
                console.log('response: ', response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue().message === 'Different'){
                  //IBA-1736
                    if(component.get("v.checkUser")){
                       component.set("v.isModalOpen", "true"); 
                   } //end IBA-1736
                  else{
                     	var toastEvent = $A.get("e.force:showToast");
	                    toastEvent.setParams({
                        "message": 'Quote printout has errors so printing this quote has been stopped. Please contact IT on Slack for help.',
                        "duration": 300000    
                        });
                        toastEvent.fire();
                   } 
                }               
           		else {
                    console.log('in else enque aciton');
                    $A.enqueueAction(action);
                }
            }
            else if (statecomp === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action1);
        // soumyad IBA-1632 end
        
        /*var actioncal = component.get('c.updatequotelinewithtotalvaluesupdate');
                console.log('Inside helper updated quote lines');
                actioncal.setParams({
                "qId": component.get("v.recordId")
                });
                
                actioncal.setCallback(this, function(response){
                    console.log("inside actioncal setback");
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var retval = response.getReturnValue();
                        console.log("URL redirect : "+url);
                        console.log("inside actioncal setback success");
                        //if(retval === 'updated'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": " Redirecting to Conga."
                        });
                        toastEvent.fire();
                        //window.location = url;
                        //}
                        
                    }
                    else{
                        //var toastEvent = $A.get("e.force:showToast");
                        //toastEvent.setParams({
                        //"title": "Error!",
                        //"message": "Error Occured while updating quote lines"
                        //});
                        //toastEvent.fire();
                        
                    }
                                    });
                $A.enqueueAction(actioncal);*/
        
    
    },
    
    congaredirectsendtoopp : function(component,helper) {
        var selectedSections = component.get("v.selectedSectionsList");
        var qpname = component.get("v.quoteprintname");
        var url;
        console.log('QP Name from helper : '+qpname);
        var action = component.get('c.sendQuotePrintRecord');
        console.log('Inside helper');
        action.setParams({
            "qpName": qpname,
            "quoteId": component.get("v.recordId")
         });
       /* var toastEventcal = $A.get("e.force:showToast");
                        toastEventcal.setParams({
                        "message": "Please wait, preparing data for the print.",
                        "duration": 5000000    
                        });
                        toastEventcal.fire();*/
        
        action.setCallback(this, function(response){
            var state = response.getState();
            url = response.getReturnValue();
            console.log("URL : "+url);
            console.log("state="+state)
            if (state === "SUCCESS"){
                //Success message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Sending Quote."
                });
                toastEvent.fire();
              window.location = url;
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
                console.log("error in Delete"+errors);
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
        
        /*var actioncal = component.get('c.updatequotelinewithtotalvaluesupdate');
                console.log('Inside helper updated quote lines');
                actioncal.setParams({
                "qId": component.get("v.recordId")
                });
                
                actioncal.setCallback(this, function(response){
                    console.log("inside actioncal setback");
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var retval = response.getReturnValue();
                        console.log("URL redirect : "+url);
                        console.log("inside actioncal setback success");
                        //if(retval === 'updated'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": " Redirecting to Conga."
                        });
                        toastEvent.fire();
                        window.location = url;
                        //}
                        
                    }
                    else{
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Occured while updating quote lines"
                        });
                        toastEvent.fire();*/
                        
                 /*   }
                                    });
                $A.enqueueAction(actioncal);*/
        
    
    },
    
    congaredirect : function(component,helper) {
        //var url = component.get("v.selectedurl");
        var url;
        component.set("v.isPrint", "true"); //IBA-1736 : Pabitra
        var qpname = component.get("v.quoteprintname");
        var urlcallback = '0';
        console.log('QP Name from helper : '+qpname);
        
        
        var action = component.get('c.deleteQuotePrintRecord');
        //var url;
        console.log('Inside helper');
        
        action.setParams({
            "qpName": qpname,
            "quoteId": component.get("v.recordId")
         });
        action.setCallback(this, function(response){
            var state = response.getState();
            url = response.getReturnValue();
            
            console.log("state="+state)
            if (state === "SUCCESS"){
              
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Redirecting to Conga."
                });
                toastEvent.fire();
                console.log("url : "+url);
                window.location = url;
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
                console.log("error in Delete"+errors);
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
        
        
        
        // soumyad IBA-1632 start
        var action1 = component.get("c.compareQuoteLine");
        action1.setParams({
            "recordID": component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var statecomp = response.getState();
            if(statecomp==='SUCCESS'){
                console.log('response: ', response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue().message === 'Different'){
                    //IBA-1736 : Pabitra
                    if(component.get("v.checkUser")){
                       component.set("v.isModalOpen", "true"); 
                   	} //end IBA-1736
                    else{
                        toastEvent.setParams({
                        "message": 'Quote printout has errors so printing this quote has been stopped. Please contact IT on Slack for help.',
                        "duration": 300000    
                        });
                        toastEvent.fire();
                    }
                } 
                else {
                    $A.enqueueAction(action);
                }
            }
            else if (statecomp === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action1);
        // soumyad IBA-1632 end
        /*var actioncal = component.get('c.updatequotelinewithtotalvaluesupdate');
                console.log('Inside helper updated quote lines');
                actioncal.setParams({
                "qId": component.get("v.recordId")
                });
                
                actioncal.setCallback(this, function(response){
                    console.log("inside actioncal setback");
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var retval = response.getReturnValue();
                        console.log("URL redirect : "+url);
                        console.log("inside actioncal setback success");
                        //if(retval === 'updated'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Success!",
                        "message": " Redirecting to Conga."
                        });
                        toastEvent.fire();
                        window.location = url;
                        //}
                        
                    }
                    else{
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Occured while updating quote lines"
                        });
                        toastEvent.fire();*/
                        
                 /*   }
                                  
             });
                $A.enqueueAction(actioncal);*/
    },
    //IBA-1736 : Pabitra
    //closeModal shows error message
    closeModal : function(component,helper){
        var toastEvent = $A.get("e.force:showToast");
	                    toastEvent.setParams({
                        "message": 'Quote printout has errors so printing this quote has been stopped. Please contact IT on Slack for help.',
                        "duration": 300000    
                        });
      toastEvent.fire();
    },//end IBA-1736
    
    //IBA-1736 : Pabitra
    //submitPrint method redirects to conga for print based on draft or print option selected
    submitPrint : function(component,helper){
		var url;
        var printAction;
        var qpname = component.get("v.quoteprintname");
        
        if(component.get("v.isDraftPrint")){
    		var printAction = component.get('c.quotedraftprint');
        }
        if(component.get("v.isPrint")){
        	printAction = component.get('c.deleteQuotePrintRecord');
        }
        
        printAction.setParams({
            "qpName": qpname,
            "quoteId": component.get("v.recordId")
         });

        printAction.setCallback(this, function(response){
            var state = response.getState();
            url = response.getReturnValue();
            console.log("URL : "+url);
            console.log("state="+state)
            if (state === "SUCCESS"){
                //Success message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Redirecting to Conga."
                });
                toastEvent.fire();
                console.log("url : "+url);
                window.location = url;
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
                console.log("error in Delete"+errors);
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
    	$A.enqueueAction(printAction);
	} //end IBA-1736
    
})