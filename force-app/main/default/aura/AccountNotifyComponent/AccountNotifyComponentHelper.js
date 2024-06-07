({
    /*  
    getAccountErrors : function(cmp, recId){ //, sapAccountNo,shouldWait) {
        
        // do not run if sap id already correct
        const action = cmp.get("c.checkAccountErrorLog");
        action.setBackground();
        action.setParams({recordId: recId});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {

                // call returns SAP Id if no error messages
                let src = response.getReturnValue();
                //console.log("Server Returned: " + src.substring(0,src.length-1) + " Length: " + src.length);
                console.log("Server Returned: " + src + " Length: " + src.length);
				
                let mLength = src.length; //.substring(0,src.length-1).length;
                
                console.log("src value " + src);
                console.log("src size " + mLength);
                
                // if greater than 10, its an error message
                if (mLength == 0 || mLength > 10){
                    if (mLength == 0)
                    	cmp.set("v.rtnMessage","SAP ID Not Returned");
                    else
                        cmp.set("v.rtnMessage",src);    
                    cmp.set("v.isError", true);
                    cmp.set("v.isReady", true);
                }
                else {
                    
                    cmp.set("v.isError", false); // no error
                    cmp.set("v.rtnMessage",  src); // set message
                    cmp.set("v.isReady", true);
                    
                    console.log("setting SAP " + src);
                }
              
                // force page refresh
                //$A.get('e.force:refreshView').fire(); 
                //cmp.set("v.isError", true);
                
            } else if (state === "ERROR") {
                cmp.set("v.isError", true);
                cmp.set("v.errorMessage", response.getError()[0].message);
        	}
        });
		$A.enqueueAction(action);
    },
    
    getSAPNumber : function(cmp, recId){
        // check if SAP Account Id exists
        const action = cmp.get("c.checkSAPNumber");
        action.setBackground();
        action.setParams({recordId: recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                // call returns SAP Id if no error messages
                let src = response.getReturnValue();
                console.log("sap id from code " + src); 
                return src;
                //cmp.set("v.sap_account_id",src);

            } else if (state === "ERROR") {
                cmp.set("v.isError", true);
                cmp.set("v.errorMessage", response.getError()[0].message);
        	}
        });
		$A.enqueueAction(action);
    }, 
  
    showToast : function(errorMsg, title, toastType) {
        console.log("Show Toast in Helper");
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

    firstPromise: function(){ 
        .then(
            // resolve handler
            $A.getCallback(function(result) {
                return anotherPromise();
            }),

            // reject handler
            $A.getCallback(function(error) {
                console.log("Promise was rejected: ", error);
                return errorRecoveryPromise();
            })
        )
        .then(
            // resolve handler
            $A.getCallback(function() {
                return yetAnotherPromise();
            })
        );
    },
    */
    apex : function( cmp, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = cmp.get("c." + apexAction + "");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
	},
})