/**********************************************************************
Name:  ScheduleAccountUpdateComponentController
Copyright © 2018
======================================================
======================================================
Purpose: 
This JavaScript Controller has been created for the component "ScheduleAccountUpdateComponent.cmp" which was included in Lightning Record Page of "Target Initiative" object
on click of lightning button Batch Scheduler will be scheduled
                                                            
======================================================
======================================================
History:                                                   
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          6/8/2018 	Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/
({
	schedule : function(component, event, helper) {
	var tarIntFields = component.get("v.tarIntFields");
	if(tarIntFields.Name != ''){
		//debugger;
			//alert("Batch will be Scheduled to update the child Accounts.");
		alert("Batch will be processed to update the child Accounts.");
			var d = new Date();
			var h = d.getHours();
			var m = d.getMinutes()+5;
		var s = d.getSeconds();
		var da = d.getDate();
		var mn = d.getMonth()+1;
		var yr = d.getFullYear();
		var recId = component.get("v.recordId");
		var action = component.get('c.scheduleBatch');
		action.setParams({"sec" : s,"min" : m,"hr" : h,"da" : da,"mn" : mn,"yr" : yr,"recId" : recId});
		action.setCallback(this, function(response){
			var state = response.getState();
		if(state === "SUCCESS"){           
		    var nextFireTime = response.getReturnValue();
		    //alert('Batch Execution Time  - '+nextFireTime);
		    alert("The Batch is Processing...");
		}else if(state === "ERROR"){
		    var errors = response.getError();
		    if(errors){
			if(Array.isArray(errors) && errors.length > 0){
			    console.log('Error Message :-'+errors[0].message);
			}else{
			    console.log('Unknown error');
			}
		    }
		}
		});

		$A.enqueueAction(action);        

		}
	}

})