({
    doInit : function(component, event, helper)
    {   
        component.set("v.spinner", true);
        var action = component.get("c.getUserDetails");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                //console.log('response-->'+JSON.stringify(response.getReturnValue()));
                component.set("v.UserDetails",response.getReturnValue());
                component.set("v.UserDetailsSize",response.getReturnValue().length);
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Error:",
                    "message": "Unable to retrieve user details. Please contact System Administrator",
                    "mode":"sticky"
                });
                toastEvent.fire();
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    downloadCSV :function(component, event, helper){
        var accountDetails = component.get("v.UserDetails");
        var csv=helper.getCSVBody(component); 
        if(csv==null)
            return ;
        
        var date = new Date();
         var dateTime = ("00" + (date.getMonth() + 1)).slice(-2)
                        + "" + ("00" + date.getDate()).slice(-2)
                        + "" + date.getFullYear() 
                        + "_" + ("00" + date.getHours()).slice(-2) 
         				+ "" + ("00" + date.getMinutes()).slice(-2);

        var elementLink=document.createElement('a');
        elementLink.href='data:application/vnd.ms-excel,'+encodeURI(csv);
        elementLink.target='_self';
        elementLink.download='Frozen_User_Report_Export_'+dateTime+'.xls';
        document.body.appendChild(elementLink);
        elementLink.click();
        $A.get('e.force:refreshView').fire();
    }
})