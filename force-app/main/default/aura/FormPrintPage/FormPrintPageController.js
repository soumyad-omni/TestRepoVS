({
    init : function(component, event, helper) {
       // helper.fetchAccHelper(component);        
        helper.getColumn(component);
        helper.getForms(component, helper);
    },
    
    handleRowAction : function(component, event, helper){
        var selRows = event.getParam('selectedRows');
        component.set("v.saveIds",selRows);
        console.log('selRows: '+ selRows.length);
    },
    doInit : function(component, event, helper){
        // call the helper function         
        // helper.getColumn(component);
        // helper.getForms(component);
    },
    // this function call on click on the next page button 
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        //helper.fetch(component, helper);
        helper.getForms(component, helper);
    },
    // this function call on click on the previous page button  
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        //helper.fetch(component, helper);
        helper.getForms(component, helper);
    },
    
    printFrm : function(component, event, helper){
        var delIdList = component.get("v.saveIds");
        var noOfIdsSelect = delIdList.length;
        var action = component.get('c.printForm');
        console.log('delIdList: '+ delIdList.length);
        if(noOfIdsSelect <= 0) {
        	var msg = 'Please select a Form to Print';
            var tEvent = $A.get("e.force:showToast");
            tEvent.setParams({
            	"title": "Error!",
                "type" : "error",
                "message": msg
            });
            tEvent.fire();
        }else{
            action.setParams({lstId : delIdList});
            action.setCallback(this, function(response) {
            var state = response.getState();
            var acc = component.get("v.recordId");
            console.log("State: "+ acc);
            component.set("v.printDisabled",true);
            if (state === "SUCCESS") {
             var returnSuccess= response.getReturnValue();
                if(returnSuccess.length >0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Redirecting to Conga."
                });
                toastEvent.fire();   
                    var Name;
                    var SAP;
                    var queryId;
                    var templateId;
                    var action_return = component.get('c.nameReturn');
					action_return.setParams({accountid : acc});
                    
                    action_return.setCallback(this, function(response) {
        		    var state = response.getState();
                         //alert('state:'+state);
                      if (state === "SUCCESS") { 
                           var resultArray = response.getReturnValue();
                         Name= resultArray.Name;
                        SAP = resultArray.SAP_Customer_Number__c;
                          // alert('Name:'+Name+'SAP:'+SAP);
                          }
                     });
                    $A.enqueueAction(action_return);
                     var action_queryids = component.get('c.getIds');
                     action_queryids.setCallback(this,function(response) {
        			    var state = response.getState();
                         //alert('State'+state);
                          if (state === "SUCCESS") {  
                             //   alert('State'+response.getReturnValue());
                    	 var ids = response.getReturnValue();  
                              queryId= ids[0].queryid__c;
                              templateId= ids[0].templateIds__c;
                              //alert('**************************');
                               window.location= '/apex/APXTConga4__Conga_Composer?sessionid={!$Api.Session_ID}&serverUrl={!API.Partner_Server_URL_370}&id='+acc+'&QueryId=[congaquery1]'+queryId+'&TemplateId='+templateId+'&TemplateGroup=FormPrintTemplate&OFN='+SAP+'.'+Name+'.Form+Printout&DS7=1&defaultpdf=1&SC1=SalesforceFile&ReturnPath='+acc; 
                        }        
                 });
                      $A.enqueueAction(action_queryids);
                      var action_flow = component.get('c.CallFlow');
                     action_flow.setParams({accountid : acc});
                    $A.enqueueAction(action_flow);

                }                                              
            console.log("Success: "+ returnSuccess);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        	});
        }
        
        $A.enqueueAction(action);
    },
})