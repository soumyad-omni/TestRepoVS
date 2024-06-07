import { LightningElement, api, track } from 'lwc';
import createProductLines from '@salesforce/apex/productLineCreateController.createProductLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class productLineCreateForm extends LightningElement {
    @api getOppId;
    @api getOppName;
    keyIndex = 0;
    @track prdButton = false;
    @track prdSkipButton = false;
    @track itemList = [
        {
            id: 0,
            Portfolio_Segment__c : '',
            Amount__c : null
        }
    ];

    handlePSChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Portfolio_Segment__c = event.target.value;
    }

    handleAmtChange(event) {
        const index = event.target.dataset.index;
        this.itemList[index].Amount__c = event.target.value;
    }
    
    addRow() {
        const newId = this.itemList.length;
        let newItem = {id: newId, Portfolio_Segment__c : '',Amount__c : null};
        this.itemList.push(newItem);
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            const index = event.target.dataset.index;
            this.itemList.splice(index, 1);
        }
    }

    handleSubmit() {
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if(isVal){
            this.prdButton = true;   
            this.showToast('Processing', 'Product Lines are being created', 'processing');     
            this.createProductLines();
        }
    }

    createProductLines(){
        createProductLines({ recordsToCreate: JSON.stringify(this.itemList), oppId: this.getOppId})
            .then(result => {
                console.log(result);                
                if(result.success){
                    console.log('Success');
                    this.showToast('Success', result.message , 'success');
                    this.proceedNext();
                }
                else{
                    console.log('Success Else');
                    this.showToast('Error', result.message, 'error');
                    this.prdButton = false;
                }             
            })
            .catch(error => {
                console.log('Exception');
                console.log(error);
                this.prdButton = false;
                console.error('Error creating records:', error);
                this.showToast('Error', error.body.message, 'error');
                // Handle error
            });
    }
    
    closeModal(){   
        console.log('Product Line Close')            
        this.modalflag = false;
        this.buttonType = 'Close';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'prodLine', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    proceedNext(){
        console.log('Product Line Next')           
        this.modalflag = false;
        this.buttonType = 'Next';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, fromPage: 'prodLine', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }

    proceedSkip(){
        this.prdSkipButton = true;
        console.log('Product Line Next')           
        this.modalflag = false;
        this.buttonType = 'Skip';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, oppId: this.getOppId, fromPage: 'prodLine', btntype: this.buttonType}});
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