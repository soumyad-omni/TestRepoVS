import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/fileUploadController.uploadFile';
import getFiles from '@salesforce/apex/fileUploadController.getFiles';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class FileUploadScreenFlowComp extends LightningElement {
    @track isShowModal = false;

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.fileData = '';
    }

    @track tagType = 'none';

    @api recordId;
    fileData;
    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            //console.log(this.fileData)
        }
        reader.readAsDataURL(file)
        this.isShowModal = true;
    }

    handleTagChange(event){
        this.tagType = event.target.value;
    }
    
    @api filenames = [];
    handleClick(){
        const {base64, filename, recordId} = this.fileData;
        const tagT = String(this.tagType);
        
        if(tagT == 'none'){
            this.toastFail('Please select a Tag for the file.')
        }else{
            console.log(tagT);
            uploadFile({ tagType:tagT, base64:base64, filename:filename, recordId:recordId }).then(result=>{
                this.fileData = null
                this.tagType = 'none';
                this.isShowModal = false
                this.filenames.push(filename);
            })
        }
    }

    toastFail(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"error"
        })
        this.dispatchEvent(toastEvent)
    }
}