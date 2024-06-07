({
	doInit : function(component, event, helper) { 
		console.log('Controller Called...');
        helper.helperMethod(component, event);
        helper.getAccount(component, event);
    },
    toggleSection : function(component, event, helper){
        helper.toggleSection(component, event);
    },
    downloadCSV :function(component, event, helper){
        var accountDetails = component.get("v.AccountDetails");
        var csv=helper.getCSVBody(component); 
        if(csv==null)
            return ;

        var elementLink=document.createElement('a');
        elementLink.href='data:application/vnd.ms-excel,'+encodeURI(csv);
        elementLink.target='_self';
        elementLink.download=accountDetails.Name+'_Credit_Export.xls';
        document.body.appendChild(elementLink);
        elementLink.click();
        $A.get('e.force:refreshView').fire();
    }
})