/** Client-Side Controller **/
({
    doInit: function (component, event, helper) {
        var options = [
        ];
        var action = component.get("c.getPrintOptions");
        component.set("v.listOptions", options);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {   
                var resultArray = response.getReturnValue();
                var options = [];
                resultArray.forEach(function(result)  { 
                    options.push({ value: result.Name, label: result.Name});
                });
                component.set("v.listOptions", options);
            } else {
                console.log('Failed with state: ' + state);
            }
        });
        $A.enqueueAction(action); 
    },
    handleChange: function (component, event) {
        var selectedOptionsList = event.getParam("value");
        console.log(selectedOptionsList);
        component.set("v.selectedArray", selectedOptionsList);
        
    },
    
})