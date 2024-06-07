({
    getData : function(component, event) {
        component.set("v.Spinner", true);
        var action = component.get("c.getData");
        action.setParams({opportunityid : component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("state: "+ state);
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                console.log("resultData---> "+ resultData);
                component.set("v.Spinner", false);
                if(resultData.HowManyContractYears == 0 || resultData.HowManyContractYears==1){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'How Many Contract Years? field do not have a value greater than one ',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                else{
                    var Contract_Year = resultData.conYear;
                    var HowManyContractYearsValue = resultData.HowManyContractYears;
                    var Name = resultData.name;
                    var SpecialtyOpenDate = resultData.specialtyOpenDate;
                    var competitorValue = resultData.competitorValue;
                    var stageOptions = resultData.stageValue.split(';');
                    var forecastOption = resultData.forecastCategory.split(';');
                    var ForecastProbabilityOption = resultData.forecastProbability.split(';');
                    var legalResourceRequiredValueOption = resultData.legalResourceRequired.split(';');//IBA-4200
                    var compellingEventValueOption = resultData.compellingEvent.split(';');//IBA-4200
                    var seismicRestraintRequiredValueOption = resultData.seismicRestraintRequired.split(';');//IBA-4200
                    var CADDrawingsObtainedValueOption = resultData.CADDrawingsObtained.split(';');//IBA-4200
                    
                    var defaultStage= '1 Solution Design';//IBA-4200
                    var defaultSeismicRestraint= 'No';//IBA-4200
                    var defaultCADDrawings= 'No';//IBA-4200
                    var noOfSec=[];
                    for (var i=1; i< HowManyContractYearsValue; i++){
                        var yr = i+1;
                        var cDate = 'Opportunity Year ' + yr;
                        noOfSec.push({dataAuraId : cDate,
                                      oppName: Name,
                                      specialtyOpenDateValue : SpecialtyOpenDate,
                                      expectedCloseDateValue : '',
                                      stageNameValue : defaultStage ,
                                      ContractYearValue : Contract_Year,
                                      forecastCategoryValue : '' ,
                                      forecastProbabilityValue : '',
                                      competitorValue : competitorValue,
                                      CustomerTypeValue : resultData.CustomerType,
                                      CurrencyIsoCodeValue: resultData.OpportunityCurrency,
                                      AccountNameValue: resultData.AccountName,
                                      OpportunityRecordTypeValue: resultData.OpportunityRecordType,
                                      HowManyContractYearsValue : HowManyContractYearsValue,
                                      legalResourceRequiredValue : '',//IBA-4200
                                      compellingEventValue : '',
                                      seismicRestraintRequiredValue : defaultSeismicRestraint,
                                      CADDrawingsObtainedValue : defaultCADDrawings //IBA-4200 - End
                                     });
                    }
                    console.log('noOfSec--> ',  noOfSec);
                    console.log('defaultStage--> ',  defaultStage);
                    component.set("v.mydata", noOfSec);
                    component.set("v.StageOption", stageOptions);
                    component.set("v.ForecastOption", forecastOption);
                    component.set("v.ForecastProbabilityOption", ForecastProbabilityOption);
                    component.set("v.defaultStage",defaultStage );
                    component.set("v.legalResourceRequiredValueOption", legalResourceRequiredValueOption);
                    component.set("v.compellingEventValueOption", compellingEventValueOption);
                    component.set("v.seismicRestraintRequiredValueOption", seismicRestraintRequiredValueOption);
                    component.set("v.CADDrawingsObtainedValueOption", CADDrawingsObtainedValueOption);//IBA-4200 - End
                }
            }
        });
        $A.enqueueAction(action);
    },
    passData:function(component, event) {
        var action = component.get("c.saveData");
        var data = component.get("v.mydata");
        let ContractYears= 2;
        var OpporunityDetails=[];
        for(var i=0; i< data.length; i++){
            
            console.log('ContractYears', ContractYears);
            OpporunityDetails.push({Name : data[i].oppName,
                                //    Contract_Year__c : data[i].ContractYearValue,
                                    Contract_Year__c : ContractYears++,
                                    Specialty_Open_Date__c : data[i].specialtyOpenDateValue,
                                    CloseDate : data[i].expectedCloseDateValue,
                                    StageName :  data[i].stageNameValue,
                                    Pipeline_Category__c : data[i].forecastCategoryValue,
                                    Forecast_Probability__c : data[i].forecastProbabilityValue,
                                    Associated_Opportunity__c : component.get("v.recordId"),
                                    Competitor__c : data[i].competitorValue,
                                    Opportunity__c : 'Specialty',
                                    CustomerType__c : data[i].CustomerTypeValue,
                                    How_many_contract_years__c : data[i].HowManyContractYearsValue ,
                                    CurrencyIsoCode : data[i].CurrencyIsoCodeValue,
                                   // ExpectedInstallDate__c : data[i].expectedInstallDateValue,
                                    AccountID  :   data[i].AccountNameValue,
                                    RecordTypeId : data[i].OpportunityRecordTypeValue,
                                    Legal_Resource_Required__c : data[i].legalResourceRequiredValue, //IBA-4200 - Start
                                    Compelling_Event__c : data[i].compellingEventValue,
                                    Seismic_Restraint_Required__c : data[i].seismicRestraintRequiredValue,
                                    CAD_Drawings_Obtained_if_Carousel_XR2__c : data[i].CADDrawingsObtainedValue //IBA-4200 - End
                                   });
             ContractYears= ContractYears++;
        }
        console.log('OpporunityDetails-->',OpporunityDetails);
        action.setParams({
            opportunityDetails : JSON.stringify(OpporunityDetails),
            opportunityid : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("state: "+ state);
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Opportunities are created successfully.',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);     
    }
})