({
    getColumn : function(component, event) {        
        component.set('v.mycolumns', [
            //{label: 'Id', fieldName: 'Id', type: 'text'},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Template Name', fieldName: 'disco__Form_Template_Name__c', type: 'text'},
            {label: 'ParLocation Name', fieldName: 'Form_PAR_Location_Name__c', type: 'text'},
            {label: 'Status', fieldName: 'disco__Status__c', type: 'text'}          
        ]);
    },
     
    getForms : function(component, event) {
        var action = component.get("c.getForms");
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();
         // set the parameters to method  
        action.setParams({
            accountid : component.get("v.recordId"),
            'pageSize' : pageSize,
            'pageNumber' : pageNumber
        });
        action.setCallback(this,function(response){
            // store the response return value 
            var state = response.getState();
            console.log("state: "+ state);
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                //console.log("resultData: "+ typeof resultData.length);
                var v = component.get("v.pageNumber");
                //console.log("component.get(v.pageNumber): "+ typeof v);
                if(resultData.length < component.get("v.pageSize")){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }
                component.set("v.dataSize", resultData.length);
                component.set("v.mydata", resultData);
            }
        });
        $A.enqueueAction(action);
    }
})