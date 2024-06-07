({
  init : function(component, event, helper){
       helper.getData(component, helper);
    },
    
     handleExit : function(component, event, helper) {
    $A.get("e.force:closeQuickAction").fire()
  },
    saveClick : function(component, event, helper) {
        console.log('OpportunityName', component.get("v.mydata"));//IBA-4200 - Start
        var validationCheck = true;
        var validationMessage = '';
        var data = component.get("v.mydata");
        for(var i=0; i< data.length; i++){
            if(data[i].legalResourceRequiredValue == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Legal Resource Required?';
            }
            if(data[i].compellingEventValue == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Compelling Event';
            }
            if(data[i].seismicRestraintRequiredValue == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Seismic Restraint Required';
            }
            if(data[i].CADDrawingsObtainedValue == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in CAD Drawings Obtained (if Carousel/XR2)';
            }
            if(data[i].forecastCategoryValue == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Forecast Category';
            }
            if(data[i].forecastProbabilityValue == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Forecast Probability';
            }
            if(data[i].oppName == ''){
                validationCheck = false;
                validationMessage = 'Please enter a Opportunity Name';
            }
            if(data[i].expectedCloseDateValue == ''){
                validationCheck = false;
                validationMessage = 'Please choose the Expected Close Date';
            }
        }
        if(validationCheck){
            helper.passData(component, helper);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: validationMessage,
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
        }                                       //IBA-4200 - End
      
  },
     showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
     hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);      
    }
    
})