import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import IMAGE_CORE from "@salesforce/resourceUrl/Opportunity_Forecasting_CORE";
import IMAGE_ADVS from "@salesforce/resourceUrl/Opportunity_Forecasting_ADVS";

const FIELDS = ["opportunity.Name","opportunity.RecordTypeId"];

export default class Opportunity_Forecasting extends LightningElement {

    forecasting_core_Image = IMAGE_CORE;
    forecasting_advs_Image = IMAGE_ADVS;
    
    @api recordId;
    
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    opportunity;

    recordType;
        
    get us_canada_non_specialty(){
        if(this.opportunity.data){
            if(this.opportunity.data.recordTypeInfo.name === 'US & Canada Advanced Services' || this.opportunity.data.recordTypeInfo.name === 'US & Canada CORE'){
                return true;
            }
            else{
                return false;
            }
        }
        return false;
    }

    get us_canada_advanced_services() {
        if(this.opportunity.data){
            if(this.opportunity.data.recordTypeInfo.name === 'US & Canada Advanced Services'){
                return true;
            }
            else{
                return false;
            }
        }
        return false;
    }

    get us_canada_CORE() {
        if(this.opportunity.data){
            if(this.opportunity.data.recordTypeInfo.name === 'US & Canada CORE'){
                return true;
            }
            else{
                return false;
            }
        }
        return false;
    }
}