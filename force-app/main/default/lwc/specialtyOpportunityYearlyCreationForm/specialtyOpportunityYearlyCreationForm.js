import { LightningElement,track,api,wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Opp_Speciality from "@salesforce/label/c.Opp_Speciality";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createOpp from '@salesforce/apex/SpecialityopportunityCreation_apex.createOpp';

import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import YEAR_FIELD from "@salesforce/schema/Opportunity.How_many_contract_years__c";
import COMP_FIELD from "@salesforce/schema/Opportunity.Competitor__c";
import CUST_FIELD from "@salesforce/schema/Opportunity.CustomerType__c";
import CURR_FIELD from "@salesforce/schema/Opportunity.CurrencyIsoCode";
import ACC_FIELD from "@salesforce/schema/Opportunity.AccountId";
const fields = [NAME_FIELD, YEAR_FIELD, COMP_FIELD, CUST_FIELD, CURR_FIELD, ACC_FIELD];


export default class SpecialtyOpportunityYearlyCreationForm extends LightningElement {
    @api recordId;    
    opptyData;
    @track isShowModal = false;
    @track isLoading = false;
    @track recurrFlag = false;
    oppName;
    oppYr;
    competitorValue;
    CustomerTypeValue;
    CurrencyIsoCodeValue;
    AccountNameValue;
    OpportunityRecordTypeValue;
    @track splYrButton = false;
    @track itemList = [
    ];

    @wire(getRecord, { recordId: '$recordId', fields})
    wiredRecord({ error, data }) {
        if (data) {
            // Store fetched record data
            this.opptyData = data;
            console.log(data);
            // Perform additional logic to prepare computed data
            this.prepareComputedData();
        } else if (error) {
            console.error('Error fetching record: ', error);
        }
    }

    prepareComputedData() {
        if(!this.recurrFlag){
            this.recurrFlag = true;
            this.isShowModal = true;
            this.oppName = getFieldValue(this.opptyData, NAME_FIELD);
            this.oppYr= getFieldValue(this.opptyData, YEAR_FIELD);
            this.competitorValue= getFieldValue(this.opptyData, COMP_FIELD);
            this.CustomerTypeValue= getFieldValue(this.opptyData, CUST_FIELD);
            this.CurrencyIsoCodeValue= getFieldValue(this.opptyData, CURR_FIELD);
            this.AccountNameValue= getFieldValue(this.opptyData, ACC_FIELD);

            console.log(this.CustomerTypeValue);
            console.log(this.oppYr);
            console.log(this.AccountNameValue);

            if(this.oppYr > 1){
                const Nindex = this.oppYr;
                for(var i=2; i<=this.oppYr; i++){
                    const Nindex = i;
                    let newItem = {
                                        id: Nindex,
                                        Name : this.oppName,
                                        Name1 : 'Opportunity Year ' + Nindex,
                                        Specialty_Open_Date__c : null,
                                        CloseDate : null,
                                        StageName : '1 Solution Design',
                                        Pipeline_Category__c : null,
                                        Forecast_Probability__c : null,
                                        Legal_Resource_Required__c : null,
                                        Compelling_Event__c : null,
                                        Seismic_Restraint_Required__c : 'No',
                                        CAD_Drawings_Obtained_if_Carousel_XR2__c : 'No',
                                        Associated_Opportunity__c : this.recordId,
                                        Competitor__c : this.competitorValue,
                                        Opportunity__c : 'Specialty',
                                        CustomerType__c : this.CustomerTypeValue,
                                        How_many_contract_years__c : this.oppYr ,
                                        CurrencyIsoCode : this.CurrencyIsoCodeValue,
                                        AccountId  :   this.AccountNameValue,
                                        RecordTypeId : Opp_Speciality,
                                        Contract_Year__c : Nindex

                                    };
                    this.itemList.push(newItem);
                }

                
            }
        }
    }

    hideModalBox() {  
        this.modalflag = false;
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.recordId, fromPage: 'specialtyYrOpp'}});
        this.dispatchEvent(closeEvent);
    }
    
    saveHandler(){
        this.isLoading = true;
        var validationCheck = true;
        var validationMessage = '';
        for(var i=0; i< this.itemList.length; i++){
            if(this.itemList[i].Legal_Resource_Required__c == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Legal Resource Required?';
            }
            if(this.itemList[i].Compelling_Event__c == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Compelling Event';
            }
            if(this.itemList[i].Seismic_Restraint_Required__c == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Seismic Restraint Required';
            }
            if(this.itemList[i].CAD_Drawings_Obtained_if_Carousel_XR2__c == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in CAD Drawings Obtained (if Carousel/XR2)';
            }
            if(this.itemList[i].Pipeline_Category__c == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Forecast Category';
            }
            if(this.itemList[i].Forecast_Probability__c == ''){
                validationCheck = false;
                validationMessage = 'Please select a value in Forecast Probability';
            }
            if(this.itemList[i].Name == ''){
                validationCheck = false;
                validationMessage = 'Please enter a Opportunity Name';
            }
            if(this.itemList[i].CloseDate == ''){
                validationCheck = false;
                validationMessage = 'Please choose the Expected Close Date';
            }
            if(this.itemList[i].Specialty_Open_Date__c == ''){
                validationCheck = false;
                validationMessage = 'Please choose the Specialty Open Date';
            }
            
        }
        
        if(validationCheck){
            let isVal = true;
            this.splYrButton = true;
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                isVal = isVal &&   element.reportValidity();
            });
            if (isVal) {
                const allitem = this.template.querySelectorAll('lightning-record-edit-form');
                createOpp({ oppList : JSON.stringify(this.itemList) })
                .then((result)=>{
                    this.isLoading = false;
                    if (!result.success) {
                        this.splYrButton = false;
                        const showToast = new ShowToastEvent({
                            title:"Error",
                            message:result.errorMessage,
                            variant:"error"
                        });
                        this.dispatchEvent(showToast);
                    }else{
                        const showToast = new ShowToastEvent({
                            title:"Success",
                            message:"Record created successfully",
                            variant:"success"
                        });
                        this.dispatchEvent(showToast);
                        this.hideModalBox();
                    }                    
                })
                .catch((error)=>{
                    console.log('Error console');
                });
            }
            else{
                this.splYrButton = false;
                const showToast = new ShowToastEvent({
                    title:validationMessage,
                    message:validationMessage,
                    variant:"error"
                });
                this.dispatchEvent(showToast);
            } 
        }
    }

    handleNMChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Name = event.target.value;
    }

    handleSOpDChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Specialty_Open_Date__c = event.target.value;
    }

    handleCDChange(event) {
        const index = event.target.dataset.index;
        let yr = 2;
        this.itemList[index].CloseDate = event.target.value;
        this.template.querySelectorAll('[data-accid]').forEach(element => {
            element.value = this.AccountNameValue;
        });
        this.template.querySelectorAll('[data-cust]').forEach(element => {
            element.value = this.CustomerTypeValue;
        });
        this.template.querySelectorAll('[data-asp]').forEach(element => {
            element.value = this.recordId;
        });
        this.template.querySelectorAll('[data-com]').forEach(element => {
            element.value = this.competitorValue;
        });
        this.template.querySelectorAll('[data-oop]').forEach(element => {
            element.value = 'Specialty';
        });
        this.template.querySelectorAll('[data-curr]').forEach(element => {
            element.value = this.CurrencyIsoCodeValue;
        });
        this.template.querySelectorAll('[data-rec]').forEach(element => {
            element.value = Opp_Speciality;
        });
        this.template.querySelectorAll('[data-yr]').forEach(element => {
            element.value = this.oppYr;
        });
        
        this.template.querySelectorAll(`[data-contyr="${this.itemList[index].id}"]`).forEach(element => {
            element.value = String(this.itemList[index].id);
        });
        
    }

    handleStgChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].StageName = event.target.value;
    }

    handleFCChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Pipeline_Category__c = event.target.value;
    }

    handleFPChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Forecast_Probability__c = event.target.value;
    }

    handleLRChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Legal_Resource_Required__c = event.target.value;
    }

    handleCEChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Compelling_Event__c = event.target.value;
    }

    handleSRQChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Seismic_Restraint_Required__c = event.target.value;
    }

    handleCADChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].CAD_Drawings_Obtained_if_Carousel_XR2__c = event.target.value;
    }

}