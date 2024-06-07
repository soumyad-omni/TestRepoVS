({  
    onInit: function(component, event, helper) { 
        
        // read any error messages or set sap id
        const recordId  = component.get("v.recordId");
		console.log("LJN onInit Called value " + recordId);
        
        //helper.getSAPNumber(component,recordId);

        //if( component.get("v.sap_account_id") == '') {
        //   console.log("sap id " + component.get("v.sap_account_id")); 
        //}
        //helper.getAccountErrors(component,recordId);
     
        // is account validated
     	// does sap number exist
     	helper.apex(component,'checkSAPNumber',{ recordId : recordId })
        	.then(function(result){
            	console.log('Call 1 : ' , result );
            	if (result == ''){
                    // sap number not found, check for error message
                	return helper.apex(component,'checkAccountErrorLog',{ recordId : recordId });
        		}
            	else{
                    //sap number found
                	//component.set("v.isError", false);
                    
                    component.set("v.sap_account_id",result); 
                	return (result);
            	}
        	})
        	.then(function(result){
            	console.log('Call 2 : ' , result); 
            	component.set("v.rtnMessage",result);
                
                let sapId = component.get("v.sap_account_id");
                console.log('SAP Id: ' + sapId ); 
                if(sapId == undefined ){
                    
                	let mLength = result.length;
                	console.log('Message Length: ' + mLength ); 
                
                	// if length of result = 10, then is sap number
                	if (mLength > 10) {
   						component.set("v.isError", true);
                	}                    
                }
                component.set("v.isReady", true);
                /*
                let mLength = result.length;
                console.log('Message Length: ' + mLength ); 
                
                // if length of result = 10, then is sap number
                if (mLength > 10) {
   					component.set("v.isError", true);
                }
                component.set("v.isReady", true);
            	//console.log('Error 2 Setting: ' + component.get("v.isError") );  
            	//if(component.get("v.isError")){component.set("v.isReady", true);}
            	*/
            
        	});
        	// optionally more chainings here
    },
    
    displayMessage : function(component,evt) {
        
        // called from component onChange
        console.log("onChange event called");
        //console.log("old value: " + evt.getParam("oldValue")); // false
        //console.log("current value: " + evt.getParam("value"));
        
        let message = component.get("v.rtnMessage");  
        let isError = component.get("v.isError");
         console.log("error setting: " + isError);
        
        let toastEvent = $A.get('e.force:showToast');
        if (toastEvent){ 
            if(isError){
                toastEvent.setParams({
                    'type': 'error',
                    'message': message, //"SAP Account Failed :" + message, 
                    //'title': "Error"
                });
            }
            else if(!isError && message.length == 0){
                //alert('do nothing');
            }/*
            else{
                toastEvent.setParams({
                    'type': 'success',
                    'message': "SAP Account (" + message + ") Created Successfully", 
                    'title': "Success"
                });  
            }*/
            toastEvent.fire();  
        } 
        //$A.get('e.force:refreshView').fire();
    },
    handleRefresh: function(component,event,helper){
        
        // does not occur until record is saved
        var eventType = event.getParam('type');
        var eventMessage = event.getParam('message');

        console.log("Event MM  " + eventType + " " + eventMessage);
        console.log("handle refresh called");
        alert("page refresh " ); 
        //event.stopPropagation();
    },
})