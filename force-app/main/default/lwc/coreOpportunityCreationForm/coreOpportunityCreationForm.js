import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCoreOpportunity from '@salesforce/apex/OpportunityRelatedListController.createCoreOpportunity';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';

export default class CoreOpportunityCreationForm extends LightningElement {
    @api getRecordTypeName;
    @api getRecordTypeId;
    @api getAccountId;
    @api getOppId;
    @api getnewOpp;
    hasError = false;
    oppformData = {}; // Object variable to store form data
    modalflag;
    requiredFields = ['Name','AccountId','StageName','OpportunityGroup__c','CloseDate','Pipeline_Category__c','CAD_Drawings_Obtained_if_Carousel_XR2__c','Forecast_Probability__c','Compelling_Event__c','Legal_Resource_Required__c','Seismic_Restraint_Required__c'];
    @track coreButton = false;
    @track OppTypePicklistOptions = [];
    @track OppGroupPicklistOptions = [];
    @track selectedOppGrpValue = '';
    @track selectedOppTypeValue = '';
    @track errorMsg = '';
    @track noValSelect = true;
    @track changeOrderTypeFlag = false; //IBA-6128 Sourav
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
        if(event.detail.value == 'Change Order - Debit' || event.detail.value == 'Change Order - Credit'){//IBA-6128 Sourav
            this.changeOrderTypeFlag = true;
        }
        else{
            this.changeOrderTypeFlag = false;
        }
        this.selectedOppTypeValue = event.detail.value;
    }

    closeModal(){   
        console.log('ADV Opp Close')            
        this.modalflag = false;
        this.buttonType = 'Close';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'coreOpp', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    proceedNext(){
        console.log('ADV Opp Next')           
        this.modalflag = false;
        this.buttonType = 'OppNext';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'coreOpp', btntype: this.buttonType, newOpp: this.getnewOpp}});
        this.dispatchEvent(closeEvent);
    }

    handleSubmit(event){
        this.closeModal(event);
    }    

    handleOppSave(event){
        this.coreButton = true;
        this.hasError = false;
        this.closeToast();
        const fields = this.template.querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            this.oppformData[field.fieldName] = field.value;
        });
        this.oppformData['RecordTypeId'] = this.getRecordTypeId; 
        this.oppformData['OpportunityGroup__c'] = this.selectedOppGrpValue;
        this.oppformData['Opportunity__c'] = this.selectedOppTypeValue; 
        console.log(this.oppformData['OpportunityGroup__c']);
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
            this.createCoreOpportunity();
        }
        else{
            this.coreButton = false;
        }
                 
    }    

    createCoreOpportunity(){
        createCoreOpportunity({ recordsToCreate: JSON.stringify(this.oppformData)})
            .then(result => {
                if(result.success){
                    this.getOppId = result.oppDetails.Id;
                    this.showToast('Success', result.message , 'success');
                    this.getnewOpp = result.oppDetails;
                    this.proceedNext();
                }
                else{
                    this.showToast('Error', result.message, 'error');
                    this.coreButton = false;
                }                
            })
            .catch(error => {
                this.coreButton = false;
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