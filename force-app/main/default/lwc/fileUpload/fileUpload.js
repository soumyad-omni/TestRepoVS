import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/fileUploadController.uploadFile';
import getFiles from '@salesforce/apex/fileUploadController.getFiles';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {NavigationMixin} from 'lightning/navigation'

export default class FileUpload extends NavigationMixin(LightningElement) {
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
    }

    handleTagChange(event){
        this.tagType = event.target.value;
    }
    
    handleClick(){
        const {base64, filename, recordId} = this.fileData;
        const tagT = String(this.tagType);
        
        if(tagT == 'none'){
            this.toastFail('Please select a Tag for the file.')
        }else{
            console.log(tagT);
            uploadFile({ tagType:tagT, base64:base64, filename:filename, recordId:recordId }).then(result=>{
                this.fileData = null
                let title = `${filename} uploaded successfully!!`
                this.toastSuccess(title)
                this.isShowModal = false
                location.reload();
            })
        }
    }

    toastSuccess(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    toastFail(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"error"
        })
        this.dispatchEvent(toastEvent)
    }

    files;
    filesFieldList = [];
    error;

    @wire(getFiles, { recordId: '$recordId' })
    wiredFiles({ error, data }) {
        if (data) {
            this.files = data;
            this.error = undefined;
            let lstSize = 0;          
            this.files.forEach(fl => {  
                console.log(fl.fname);
                if (lstSize < 3) {  
                    if(fl.size == 'Attachment') {
                        this.filesFieldList.push({
                            Name: fl.fname,
                            Id:fl.fid,
                            Tag:fl.tag,
                            size:fl.size,
                            cdate:fl.cdate,
                            ctype:fl.ctype,
                            url:`/servlet/servlet.FileDownload?file=${fl.fid}`,
                            hasUrl:true
                        });
                    }else{
                        this.filesFieldList.push({
                            Name: fl.fname,
                            Id:fl.fid,
                            Tag:fl.tag,
                            size:fl.size,
                            cdate:fl.cdate,
                            ctype:fl.ctype,
                            url:`/servlet/servlet.FileDownload?file=${fl.fid}`,
                            hasUrl:false
                        });
                    }         
                
                }
                lstSize++;
            });
        } else if (error) {
            this.error = error;
            this.files = undefined;
        }
    }

    get card_title(){
        var count = 0;
        if(this.files != null){
            count = this.files.length;
        }
        if(count < 4)
            return "Files ("+count+")";
        else{
            return "Files (3+)";
        }
    }

    get viewAllRender(){
        if(this.files != null && this.files.length > 0 ){
            return true;
        }
        else{
            return false;
        }
    }

    @api objectApiName;


    get viewAll(){
        if(this.recordId != null ){
            if(this.objectApiName != 'Quote_Approval__c' ){
                return '/lightning/r/'+this.objectApiName+'/'+this.recordId+'/related/AttachedContentDocuments/view';
            }else{
                return '/lightning/r/'+this.objectApiName+'/'+this.recordId+'/related/CombinedAttachments/view';
            }
            
        }
    }

    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}