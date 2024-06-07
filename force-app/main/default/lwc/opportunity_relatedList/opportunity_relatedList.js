import { LightningElement, api, track, wire } from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityRelatedListController.getOpportunities';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import { getRecord } from 'lightning/uiRecordApi';

export default class OpportunityRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api getOppId;
    @api newOpp;
    opportunities;
    updatedopportunities = [];
    @track createSpecialtyOpp = false;
    @track createCOREOpp = false;
    @track createAdvsOpp = false;
    @track recordTypeId;
    @track recordTypeName;
    @track currencyIsoCode;
    @track openProductLineFlag = false;
    @track openContactRoleFlag = false;
    @track openSpecialtyYearlyFlag = false;
    @track openAdvsFlag = false;
    splRecordType;
    advsRecordType;
    coreRecordType;
    @track opportunityDeleteFlag = false;
    @track nonSoldToOrDeleted = true;
    accountData;
    accountfields = [ 'Account_Role__c', 'IsDeleted__c'];

    @wire(getOpportunities, { accountId: '$recordId' })
    wiredOpportunities({ error, data }) {
        if (data) {
            this.opportunities = data;  
            let indx = 0;          
            this.opportunities.forEach(opp => {   
                if (indx < 3) {             
                this.updatedopportunities.push({Name: opp.Name,Id:opp.Id,Amount:opp.Amount,
                    Opportunity_Number__c:opp.Opportunity_Number__c,StageName:opp.StageName,
                    CurrencyIsoCode:opp.CurrencyIsoCode,Exp_Amount:this.formatNumberWithCommas(opp.Expected_Bookings__c)});
                }
                indx++;
            });
        } else if (error) {
            // Handle error
        }
    }
    
    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            // If data is available, retrieve the record types
            const rtInfos = data.recordTypeInfos;
            for (const rtId in rtInfos) {
                if (rtInfos.hasOwnProperty(rtId)) {
                    const rtInfo = rtInfos[rtId];
                    if (rtInfo.available) {
                        if(rtInfo.name == 'US & Canada CORE'){
                            this.coreRecordType = rtInfo.recordTypeId;
                        }
                        else if(rtInfo.name == 'US & Canada Specialty'){
                            this.splRecordType = rtInfo.recordTypeId;
                        }
                        else if(rtInfo.name == 'US & Canada Advanced Services'){
                            this.advsRecordType = rtInfo.recordTypeId;
                        }
                    }
                }
            }            
        } else if (error) {
            // Handle error if any
            console.error('Error fetching object info:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId' , fields: ['Account.IsDeleted__c','Account.Account_Role__c']})
    wiredAccount({error,data}){
        if (data) {
            if(data.fields.IsDeleted__c.value || data.fields.Account_Role__c.value != 'ZCSN'){
                this.nonSoldToOrDeleted = false;
            }
            console.log(data);
            console.log(data.fields.IsDeleted__c.value);
            console.log(data.fields.Account_Role__c.value);
        }
        else if(error){

        }
    }

    formatNumberWithCommas(number) {
        if (typeof number === 'undefined') {
            return "0.00";
        }
    
        // Otherwise, convert the input to a floating-point number and format it with two decimal places
        return parseFloat(number).toLocaleString(undefined, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    get card_title(){
        var count = 0;
        if(this.opportunities != null){
            count = this.opportunities.length;
        }
        if(count < 4)
            return "Opportunities("+count+")";
        else{
            count--;
            return "Opportunities("+count+"+)";
        }
    }

    get viewAllRender(){
        if(this.opportunities != null && this.opportunities.length > 0 ){
            return true;
        }
        else{
            return false;
        }
    }

    get viewAll(){
        if(this.recordId != null ){
            return '/lightning/r/Account/'+this.recordId+'/related/Opportunities/view';
        }
    }

    newSpecialtyOpps(){
        this.recordTypeName = 'US & Canada Specialty';
        this.recordTypeId = this.splRecordType;
        this.createSpecialtyOpp = true;        
    }

    newCOREOpps(){
        this.recordTypeName = 'US & Canada CORE';
        this.recordTypeId = this.coreRecordType;
        this.createCOREOpp = true; 
    }

    newAdvsOpps(){
        this.recordTypeName = 'US & Canada Advanced Services';
        this.recordTypeId = this.advsRecordType;
        this.createAdvsOpp = true;
    }

    handlemodalform(event){   
        if(event.detail.btntype == 'OppNext'){
            this.getOppId = event.detail.oppId;
            this.newOpp = event.detail.newOpp;
        }
        if(event.detail.fromPage == 'coreOpp'){
            if(this.createCOREOpp){
                this.createCOREOpp = event.detail.close;
                if(event.detail.btntype == 'OppNext'){
                    this.openProductLineFlag = true;
                }
            } 
        }
        if(event.detail.fromPage == 'specialtyOpp'){
            if(this.createSpecialtyOpp){
                this.createSpecialtyOpp = event.detail.close;
                if(this.getOppId){
                    this.navigateToOppURL();
                }
                /*if(event.detail.btntype == 'OppNext'){
                    this.openSpecialtyYearlyFlag = true;
                }*/
            } 
        }
        if(event.detail.fromPage == 'advsOpp'){
            if(this.createAdvsOpp){
                this.createAdvsOpp = event.detail.close;
                if(event.detail.btntype == 'OppNext'){
                    this.openProductLineFlag = true;
                }
            } 
        }
        if(event.detail.fromPage == 'prodLine'){
            if(this.openProductLineFlag){
                this.openProductLineFlag = event.detail.close;
                if(event.detail.btntype != 'Close'){
                    this.openContactRoleFlag = true;
                }
                else{
                    this.navigateToOppURL();
                }
            }
        }
        if(event.detail.fromPage == 'contactRole'){
            if(this.openContactRoleFlag){
                this.openContactRoleFlag = event.detail.close;
                if(event.detail.btntype != 'Close'){
                    if(event.detail.proceedToQuote){
                        this.navigateToQuoteURL();
                    }
                    else{
                        this.navigateToOppURL();
                    }                    
                }
                else{
                    this.navigateToOppURL();
                }
            }
        }
        if(event.detail.fromPage == 'specialtyYrOpp'){
            if(this.openSpecialtyYearlyFlag){
                this.openSpecialtyYearlyFlag = event.detail.close;
                this.navigateToOppURL();
            } 
        }
        if(event.detail.fromPage == 'oppDel'){
            if(this.opportunityDeleteFlag){
                this.opportunityDeleteFlag = false;
            }
        }
    }

    navigateToQuoteURL() {
        // Define the URL you want to navigate to
        const url = '/apex/NewQuoteCreateLayout?oppid='+this.getOppId+'&accid='+this.recordId;
        // Navigate to the URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

    navigateToOppURL() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.getOppId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    getOpportunityUrl(oppId) {
        return '/lightning/r/'+oppId+'/view';
    }    

    navigateToOppURL2(event) {
        const recordId = event.currentTarget.dataset.id;
        console.log(recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    editOpportunity(event){
        // Define the URL you want to navigate to
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                actionName: 'edit'
            }
        });
    }

    deleteOpportunity(event){
        this.selectedOpportunityId = event.target.value;
        this.opportunityDeleteFlag = true;
    }
}