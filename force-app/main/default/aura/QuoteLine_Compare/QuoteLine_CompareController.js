({
    compare : function(component, event, helper){
        
        var action = component.get("c.compareQuoteLine");
        action.setParams({
            "recordID": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            component.set('v.mycolumns', [
                {label: 'Source', fieldName: 'Source',  type: 'text'},
                {label: 'Product', fieldName: 'Product',  type: 'text'},
                {label: 'Qty',  fieldName: 'Qty', type: 'text'},
                {label: 'Contract List Price', fieldName: 'Contract_List_Price',  type: 'text'},
                {label: 'Unit Price', fieldName: 'Unit_Price',  type: 'text'},
                {label: 'Extended Price', fieldName: 'Extended_Price',  type: 'text'},
                {label: 'Unit Services', fieldName: 'Unit_Services',  type: 'text'},
                {label: 'Extended Services', fieldName: 'Extended_Services',  type: 'text'},
                {label: 'Renewal', fieldName: 'isRenewal',  type: 'text'}
                
            ]);
            console.log('Coloums: ', "v.mycolumns");
            var state = response.getState();
            if(state==='SUCCESS'){
                console.log('response: ', response.getReturnValue());
                component.set("v.strmsg",response.getReturnValue().message);   
                component.set("v.isFieldmatch",response.getReturnValue().isFieldmatch);
                
                component.set("v.lstsubcompare", response.getReturnValue().lstsubcompare);
                component.set("v.mydata", response.getReturnValue().lstsubcompare);
                component.set("v.isModalOpen", true);
            }
            else if (state === 'ERROR'){
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
        $A.enqueueAction(action);
    },
    sortData: function(component, fieldName, sortDirection){
        var data = component.get("v.mydata");
        var reverse = sortDirection !== 'asc';
        data = Object.assign([],
                             data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
                            );
        component.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
        ? function(x) { return primer(x[field]) }: function(x) { return x[field] };
        
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    
    closeModel : function(component, event, helper){
        
        component.set("v.isModalOpen", false);
    }
})