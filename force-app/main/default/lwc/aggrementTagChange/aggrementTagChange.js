import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fileTagCheckFromQAP from '@salesforce/apex/fileUploadController.fileTagCheckFromQAP';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Agg_OBJECT from '@salesforce/schema/Agreement_Tag__c';
import TagC from '@salesforce/schema/Agreement_Tag__c.Tag__c';
import tagInsert from '@salesforce/apex/fileUploadController.tagInsert';

export default class AggrementTagChange extends LightningElement {

    @track isShowModal = false;
    @track recordList = [];
    @api recordId;

    connectedCallback() {
        console.log(this.recordId);
        fileTagCheckFromQAP({recordId:this.recordId}).then(data=>{
            const dataList = [];
            data.forEach(record => {
            const dataRow = {};
            dataRow.Id = record.Id;
            dataRow.Name = record.Name;
            dataRow.ParentId = record.ParentId;
            dataList.push(dataRow);
            });
            if(dataList.length>0){
                this.isShowModal = true
                this.recordList = dataList;
                console.log(dataList.length);
            }
            
        })
        this.isShowModal = false;
    }

    hideModalBox() {  
        var validationMessage = 'Please select tag for all the files!';
        const showToast = new ShowToastEvent({
            title:'Error',
            message:validationMessage,
            variant:"error"
        });
        this.dispatchEvent(showToast);
        //this.isShowModal = false;
        //this.fileData = '';
    }

    @wire(getObjectInfo, { objectApiName: Agg_OBJECT })
    aggInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$aggInfo.data.defaultRecordTypeId',
            fieldApiName: TagC
        }
    )
    tagValues;

    recordsToInsert = [];
    handleTagChange(event){
        console.log('rec id - '+event.target.dataset.recordId);
        const dataRow = {};
        dataRow.Parent_Id__c = event.target.dataset.recordId;
        dataRow.Tag__c = event.target.value;
        this.recordsToInsert.push(dataRow);
    }

    handleSaveClick(){
        console.log('this.recordsToInsert.length '+this.recordsToInsert.length);
        if(this.recordsToInsert.length>0){
            const revRecordsToInsert = [];
            this.recordsToInsert.slice().reverse().forEach(x => revRecordsToInsert.push(x));
            const uniqueArray = revRecordsToInsert.filter((value, index) => {
                const _value = JSON.stringify(value.Parent_Id__c);
                return (
                    index ===
                    revRecordsToInsert.findIndex((obj) => {
                        return JSON.stringify(obj.Parent_Id__c) === _value;
                    })
                );
            });

            if(this.recordList.length !== uniqueArray.length){
                var validationMessage = 'Please select tag for all the files!';
                const showToast = new ShowToastEvent({
                    title:'Error',
                    message:validationMessage,
                    variant:"error"
                });
                this.dispatchEvent(showToast);
            }else{
                tagInsert({atgList:uniqueArray}).then(data=>{
                    this.isShowModal = false;
                })
            }
            
        }
    }

}