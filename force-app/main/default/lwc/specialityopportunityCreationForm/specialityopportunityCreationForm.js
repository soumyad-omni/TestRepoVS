import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSpecialtyOpportunity from '@salesforce/apex/OpportunityRelatedListController.createSpecialtyOpportunity';
//import the named import to fetch the values of a picklist
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

//import the object from which you want to fetch the field
import OPP_OBJECT from '@salesforce/schema/Opportunity';

export default class SpecialityopportunityCreationForm extends LightningElement {
    @api getRecordTypeId;
    @api getRecordTypeName;
    
    @api getAccountId;
    @api getOppId;
    hasError = false;
    oppformData = {}; // Object variable to store form data
    modalflag;
    requiredFields = ['Name','AccountId','OpportunityGroup__c','StageName','CloseDate','Pipeline_Category__c','CAD_Drawings_Obtained_if_Carousel_XR2__c','Forecast_Probability__c','Compelling_Event__c','Legal_Resource_Required__c','Seismic_Restraint_Required__c'];
    @track splButton = false;
    @track splButton = false;
    @track OppTypePicklistOptions = [];
    @track OppGroupPicklistOptions = [];
    @track selectedOppGrpValue = '';
    @track selectedOppTypeValue = '';
    @track errorMsg = '';
    @track noValSelect = true;

    @wire(getPicklistValuesByRecordType, { objectApiName: OPP_OBJECT, recordTypeId: '$getRecordTypeId' })
    
    picklistValues({error, data}){
    	if(data){
        	console.log(data.picklistFieldValues.Opportunity__c);
            this.selectedOppGrpValue = data.picklistFieldValues.OpportunityGroup__c.defaultValue.value;
            this.OppGroupPicklistOptions = data.picklistFieldValues.OpportunityGroup__c.values;
            this.selectedOppTypeValue = data.picklistFieldValues.Opportunity__c.defaultValue.value;
            this.OppTypePicklistOptions = data.picklistFieldValues.Opportunity__c.values;
        }else if(error){
        	console.log(error);
        }
    }
    handleoppGrpChange(event) {
        console.log(event.detail.value);
        this.selectedOppGrpValue = event.detail.value;
    }
    handleoppTypeChange(event) {
        console.log(event.detail.value);
        this.selectedOppTypeValue = event.detail.value;
    }

    
    closeModal(){   
        console.log('ADV Opp Close')            
        this.modalflag = false;
        this.buttonType = 'Close';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'specialtyOpp', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    proceedNext(){
        this.modalflag = false;
        this.buttonType = 'OppNext';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'specialtyOpp', btntype: this.buttonType, newOpp: this.getnewOpp}});
        this.dispatchEvent(closeEvent);
    }

    handleSubmit(event){
        this.closeModal(event);
    }

    handleOppSave(event){
        this.splButton = true;
        this.hasError = false;
        this.closeToast();
        const fields = this.template.querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            this.oppformData[field.fieldName] = field.value;
        });
        this.oppformData['RecordTypeId'] = this.getRecordTypeId;
        this.oppformData['OpportunityGroup__c'] = this.selectedOppGrpValue;
        this.oppformData['Opportunity__c'] = this.selectedOppTypeValue;
        this.oppformData['How_many_contract_years__c'] = "1";
        this.oppformData['Contract_Year__c'] = "1";
        for (const field of fields) {
            if(this.requiredFields.includes(field.fieldName)){
                if(this.oppformData[field.fieldName] == null || this.oppformData[field.fieldName] == ''){
                    this.hasError = true;
                    field.focus();
                }
            }
        }
        if(!this.hasError){
            this.showToast('Processing', 'Opportunity is being created', 'processing');
            this.createSpecialtyOpportunity();
        }
        else{
            this.splButton = false;
        }        
    }    

    createSpecialtyOpportunity(){
        createSpecialtyOpportunity({ recordsToCreate: JSON.stringify(this.oppformData)})
            .then(result => {
                if(result.success){
                    // Handle success
                    this.getOppId = result.oppDetails.Id;
                    this.showToast('Success', result.message , 'success');
                    this.getnewOpp = result.oppDetails;
                    this.proceedNext();
                }
                else{
                    this.showToast('Error', result.message, 'error');
                    this.splButton = false;
                }                 
            })
            .catch(error => {
                this.splButton = false;
                console.error('Error creating records:', error);
                this.showToast('Error', error.body.message, 'error');
                // Handle error
            });
    }

    showToast(title, message, variant) {
        if(variant == 'error'){//mode: 'sticky',
            this.errorMsg = message;
            this.isToastVisible = true;
        }
        else{
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(event);
        } 
    }

    @track isToastVisible = false;    
    closeToast() {
        if(this.isToastVisible){
            this.errorMsg = '';
            this.isToastVisible = false;
        }        
    }

    handleSelectionChange(event) {
        this.selectedValues = event.detail.value;
        this.toggleRequiredMessageVisibility();
    }

    toggleRequiredMessageVisibility() {
        this.noValSelect = this.selectedValues.length === 0;
    }
}