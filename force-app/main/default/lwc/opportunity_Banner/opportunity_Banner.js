// recordDetailBanner.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ["opportunity.Name","opportunity.RecordTypeId"];

export default class opportunity_Banner extends LightningElement {
    @api recordId;
    showBanner = true;
    recordTypeName = '';

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    opportunity;
/*
    get HavingrecordType(){
        if(this.opportunity.data){
            this.recordTypeName = this.opportunity.data.recordTypeInfo.name;
            return true;
        }
        else{
            return false;
        }
    }*/

    get coreOpportunity(){
        if(this.opportunity.data){
            if(this.opportunity.data.recordTypeInfo.name == 'US & Canada CORE'){
                return true;
            }
            else {
                return false;
            }            
        }
        else{
            return false;
        }
    }
    get advsOpportunity(){
        if(this.opportunity.data){
            if(this.opportunity.data.recordTypeInfo.name == 'US & Canada Advanced Services'){
                return true;
            }
            else {
                return false;
            }            
        }
        else{
            return false;
        }
    }
    get specialtyOpportunity(){
        if(this.opportunity.data){
            if(this.opportunity.data.recordTypeInfo.name == 'US & Canada Specialty'){
                return true;
            }
            else {
                return false;
            }            
        }
        else{
            return false;
        }
    }
}