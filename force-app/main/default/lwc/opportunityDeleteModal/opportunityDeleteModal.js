import { LightningElement, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityDeleteModal extends LightningElement {
    @api oppId;

    deleteOpportunity(){
        console.log(this.oppId);
        deleteRecord(this.oppId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity deleted successfully.',
                        variant: 'success'
                    })
                );
                this.cancelOpportunityDelete();
                // Optionally perform additional actions after deletion
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    cancelOpportunityDelete(){   
        console.log('opportunity Edit')            
        this.modalflag = false;
        this.buttonType = 'Close';
        const closeEvent = new CustomEvent('closemodalform', { detail : { close: this.modalflag, fromPage: 'oppDel', btntype: this.buttonType}});
        this.dispatchEvent(closeEvent);
    }
    
}