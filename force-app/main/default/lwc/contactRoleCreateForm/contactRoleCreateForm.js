import { LightningElement, api, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/OppContactRoleCreateController.getContacts';
import createContactRoles from '@salesforce/apex/OppContactRoleCreateController.createRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OpportunityContactShipError from "@salesforce/label/c.OpportunityContactShipError";

export default class ContactRoleCreateForm extends LightningElement {
    @api getOppId;    
    contacts;
    @track currOppAccId;
    @track recordSelected = false;
    filteredContacts;
    searchKey = '';
    @track searchString;
    @track initialRecords;
    selectedContacts;
    @track buttonCount = 'Show Selected(0)';
    @track showRes = true;
    @track backtoRes = false;
    @track oppContactRoleForm = false;
    @track contactForm = true;
    @track proceedToQuote = false;
    @track onlySave = false;
    @track defaultRole = 'S-Shipping Contact';
    unSelectedContacts;
    filteredContacts;
    contactOptions = [];
    keyIndex = 0;
    @track oppConRoleList = [];
    @track primaryContactId = null;
    columns = [
        { label: 'Name', fieldName: 'contactName', type: 'url', typeAttributes: { label: { fieldName: 'contactName' }, target: '/lightning/r/0033l00002LgN0bAAF/view'}},
        { label: 'Account Name', fieldName: 'accountName', type: 'text' },
        { label: 'Phone', fieldName: 'contactPhone', type: 'phone' },
        { label: 'Email', fieldName: 'contactEmail', type: 'email' }
    ];
    @track conRoleButton = false;

    @wire(getContacts, { oppId: '$getOppId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.initialRecords = data;
            this.filteredContacts = [...this.contacts];
            //this.filterContacts();
        } else if (error) {
            // Handle error
        }
    }

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            this.data = this.initialRecords;
 
            if (this.data) {
                let searchRecords = [];
 
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                this.filteredContacts = searchRecords;
            }
        } else {
            this.filteredContacts = this.initialRecords;
        }
    }

    handleRowAction(event){
        this.selectedContacts = event.detail.selectedRows;
        this.buttonCount = 'Show Selected('+this.selectedContacts.length+')';
        if(this.selectedContacts.length > 0){            
            this.recordSelected = true;
        }
        else{
            this.recordSelected = false;
        }
    }

    showSelectedContacts(event){
        this.filteredContacts = this.contacts.filter(contact => this.selectedContacts.includes(contact));
        this.unSelectedContacts = this.contacts.filter(contact => !this.selectedContacts.includes(contact));
        this.showRes = false;
        this.backtoRes = true;
    }

    backToResults(event){
        this.filteredContacts = [...this.unSelectedContacts];
        this.selectedContacts.forEach(contact => {
            // If a selected contact is not present in the filtered list, add it
            if (!this.filteredContacts.find(filteredContact => filteredContact.Id === contact.Id)) {
                this.filteredContacts.push(contact);
            }
        });
        this.showRes = true;
        this.backtoRes = false;
    }

    goNext(){
        this.selectedContacts.forEach((contact, index) => {
            this.oppConRoleList.push({oppcontact : contact, role: this.defaultRole, index: index, IsPrimary : false});
        });
        this.contactOptions = this.selectedContacts.map(contact => ({
            label: contact.contactName,
            value: contact.contactId,
            icon: 'standard:contact'
        }));
        this.contactForm = false;
        this.oppContactRoleForm = true;
    }

    goBack(){
        this.contactForm = true;
        this.oppContactRoleForm = false;
        this.recordSelected = false;
        this.filteredContacts = this.initialRecords;
        this.selectedContacts = [];
        this.oppConRoleList = [];
        this.buttonCount = 'Show Selected('+this.selectedContacts.length+')';
    }

    handleRoleChange(event){
        const index = event.target.dataset.index;
        this.oppConRoleList[index].role = event.target.value;
    }
    saveContactRole(){
        this.onlySave = true;
        this.createContactRole();
    }

    createContactRole(){
        this.conRoleButton = true;
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if(isVal){
            let shippingContactCount = 0;
            this.oppConRoleList.forEach(oppCon =>{
                if(oppCon.role == 'S-Shipping Contact'){
                    shippingContactCount++;
                }                
            });
            console.log(shippingContactCount);
            if(shippingContactCount > 1){
                this.showToast('Error', OpportunityContactShipError, 'error');
                this.conRoleButton = false;
            }
            else{
                createContactRoles({ recordsToCreate: JSON.stringify(this.oppConRoleList), primaryContactId: this.primaryContactId, oppId: this.getOppId})
                .then(result => {
                    if(result.success){
                        this.showToast('Success', result.message , 'success');
                        this.proceedToQuote = result.proceedToQuote;
                        if(this.onlySave){
                            this.closeModal();
                        }
                        else{
                            this.proceedNext();
                        }
                    }
                    else{
                        this.showToast('Error', result.message, 'error');
                        this.conRoleButton = false;
                    } 
                    // Handle success
                })
                .catch(error => {
                    this.conRoleButton = false;
                    console.error('Error creating records:', error);
                    this.showToast('Error', error.body.message, 'error');
                    // Handle error
                });
            }           
        }
        else{
            this.conRoleButton = false;
        }
    }

    primaryContactSelect(event){
        this.primaryContactId = event.target.value;
    }
   
    closeModal(){
        this.modalflag = false;
        this.buttonType = 'Close';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'contactRole', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    proceedNext(){
        this.modalflag = false;
        this.buttonType = 'Next';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, fromPage: 'contactRole', btntype: this.buttonType, proceedToQuote: this.proceedToQuote}});
        this.dispatchEvent(closeEvent);
    }

    proceedSkip(){
        this.modalflag = false;
        this.buttonType = 'Skip';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'contactRole', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}