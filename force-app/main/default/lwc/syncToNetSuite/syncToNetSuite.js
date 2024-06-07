import { LightningElement, api, track, wire } from 'lwc';
import getButtonVisibility from '@salesforce/apex/SyncToNetSuiteController.getButtonVisibility'
import sendNetSuite from '@salesforce/apex/SyncToNetSuiteController.sendToNetSuite';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Opp_Speciality from "@salesforce/label/c.netSuite_Sync_Button";

export default class SyncToNetSuite extends LightningElement {
    @api recordId;
    @track isNSButtonShow = false;
    buttonLabel = Opp_Speciality;
    @wire(getButtonVisibility, { quoteId: '$recordId' })
    wiredButtonVisibility({ error, data }) {
        if (data) {
            this.isNSButtonShow = data;
            console.log(data);
        } else if (error) {
            // Handle error if needed
        }
    }

    sendToNetSuite(){
        sendNetSuite({ quoteId: this.recordId})
                .then(result => {
                    console.log(result);
                    if(result.success){
                        this.showToast('Success', result.message , 'success');                        
                    }
                    else{
                        this.showToast('Error', result.message, 'error');
                    } 
                    // Handle success
                })
                .catch(error => {
                    console.error('Error creating records:', error);
                    this.showToast('Error', error.body.message, 'error');
                    // Handle error
                });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: "sticky"
        });
        this.dispatchEvent(event);
    }
}