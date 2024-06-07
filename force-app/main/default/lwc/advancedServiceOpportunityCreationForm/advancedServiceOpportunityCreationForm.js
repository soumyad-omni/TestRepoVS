import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAdvsOpportunity from '@salesforce/apex/OpportunityRelatedListController.createAdvsOpportunity';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';

export default class AdvancedServiceOpportunityCreationForm extends LightningElement {
    @api getRecordTypeName;
    @api getRecordTypeId;
    @api getAccountId;
    @api getOppId;
    hasError = false;
    oppformData = {}; // Object variable to store form data
    modalflag;
    buttonType;
    requiredFields = ['Name','AccountId','StageName','OpportunityGroup__c','CloseDate','Pipeline_Category__c','CAD_Drawings_Obtained_if_Carousel_XR2__c','Forecast_Probability__c','Compelling_Event__c','Legal_Resource_Required__c','Seismic_Restraint_Required__c'];
    @track advsButton = false;
    @track OppTypePicklistOptions = [];
    @track OppGroupPicklistOptions = [];
    @track selectedOppGrpValue = '';
    @track selectedOppTypeValue = '';
    @track errorMsg = '';
    @track noValSelect = true;
    @track changeOrderTypeFlag = false; //IBA-6128 Sourav
    @track advsRenFlag = false;//IBA-6128 Sourav
    @wire(getPicklistValuesByRecordType, { objectApiName: OPP_OBJECT, recordTypeId: '$getRecordTypeId' })

    picklistValues({error, data}){
    	if(data){
            this.selectedOppGrpValue = data.picklistFieldValues.OpportunityGroup__c.defaultValue.value;
            this.OppGroupPicklistOptions = data.picklistFieldValues.OpportunityGroup__c.values;
            this.selectedOppTypeValue = data.picklistFieldValues.Opportunity__c.defaultValue.value;
            this.OppTypePicklistOptions = data.picklistFieldValues.Opportunity__c.values;
        }else if(error){
        	console.log(error);
        }
    }

    handleoppGrpChange(event) {
        this.selectedOppGrpValue = event.detail.value;
    }
    handleoppTypeChange(event) {
        console.log(event.detail.value);
        if(event.detail.value == 'Change Order - Debit' || event.detail.value == 'Change Order - Credit'){ //IBA-6128 Sourav
            this.changeOrderTypeFlag = true;
        }
        else{
            this.changeOrderTypeFlag = false;
        }
        if(event.detail.value == 'Adv Svc Renewal'){ //IBA-6128 Sourav
            this.advsRenFlag = true;
        }
        else{
            this.advsRenFlag = false;
        }
        this.selectedOppTypeValue = event.detail.value;
    }

    closeModal(){  
        this.modalflag = false;
        this.buttonType = 'Close';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'advsOpp', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    proceedNext(){
        this.modalflag = false;
        this.buttonType = 'OppNext';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'advsOpp', btntype: this.buttonType, newOpp: this.getnewOpp}});
        this.dispatchEvent(closeEvent);
    }

    handleSubmit(event){
        this.closeModal(event); 
    }

    handleOppSave(event){
        this.advsButton = true;
        this.hasError = false;
        this.closeToast();
        const fields = this.template.querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            this.oppformData[field.fieldName] = field.value;
        });
        this.oppformData['RecordTypeId'] = this.getRecordTypeId;
        this.oppformData['OpportunityGroup__c'] = this.selectedOppGrpValue;
        this.oppformData['Opportunity__c'] = this.selectedOppTypeValue; 
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
            this.createAdvsOpportunity();
        }
        else{
            this.advsButton = false;
        }                         
    }

    createAdvsOpportunity(){
        createAdvsOpportunity({ recordsToCreate: JSON.stringify(this.oppformData)})
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
                    this.advsButton = false;
                }                
            })
            .catch(error => {
                this.advsButton = false;
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