import { LightningElement, track } from 'lwc';
import rm_button_label from "@salesforce/label/c.Reporting_Manager_Job_Button";
import startRMBatchJob from '@salesforce/apex/ReportingManagerJobButtonController.startRMBatchJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReportingManagerJobButton extends LightningElement {
    buttonLabel = rm_button_label;

    executeRMJob(){
        startRMBatchJob()
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Reporting Manager Update Job started successfully',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
}