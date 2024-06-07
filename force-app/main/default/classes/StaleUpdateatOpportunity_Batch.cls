/**********************************************************************
Name:  StaleUpdateatOpportunity_Batch
Copyright Â© 2021
======================================================
======================================================
Purpose: This batch will run to update the Stale field at opportunity for the US
and Canada Record Type ----                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1     Abhrajit Chatterjee         09-23-2021            ?          	INITIAL DEVELOPMENT
***********************************************************************/
Global class StaleUpdateatOpportunity_Batch implements Database.Batchable<sObject> {
    global StaleUpdateatOpportunity_Batch () {

    }
        global String query;

        global Id recordTypeIdForUS =  [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select id,Number_of_Days_since_Last_Interaction__c,Pipeline_Category__c,CloseDate,RecordType.Name, Category__c, LastModifiedDate, LastModifiedById, Last_Interaction_Date__c From Opportunity Where RecordTypeID = :recordTypeIdForUS AND Number_of_Days_since_Last_Interaction__c != null]);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> oppList){
        List<Opportunity> opportunityUpdatedList = new List<Opportunity>();
      /*  for(Opportunity o : oppList) {
           if(system.today()+730 >= o.CloseDate) {
                if(o.Pipeline_Category__c == 'Development' && (o.Number_of_Days_since_Last_Interaction__c >= 30 && o.Number_of_Days_since_Last_Interaction__c <= 90)) {
                    o.Stale__c = 'No';
                }
                else if(o.Pipeline_Category__c == 'Development' && (o.Number_of_Days_since_Last_Interaction__c >= 91 && o.Number_of_Days_since_Last_Interaction__c <= 730)) {
                    o.Stale__c = 'Yes';
                }
                else if(o.Pipeline_Category__c == 'Upside' && (o.Number_of_Days_since_Last_Interaction__c >= 30 && o.Number_of_Days_since_Last_Interaction__c <= 60)) {
                    o.Stale__c = 'No';
                }
                else if(o.Pipeline_Category__c == 'Upside' && (o.Number_of_Days_since_Last_Interaction__c > 60 && o.Number_of_Days_since_Last_Interaction__c <= 730)) {
                    o.Stale__c = 'Yes';
                }
                else if(o.Pipeline_Category__c == 'Committed' && (o.Number_of_Days_since_Last_Interaction__c >= 30 && o.Number_of_Days_since_Last_Interaction__c <= 730)) {
                    o.Stale__c = 'Yes';
                }
                else if((o.Pipeline_Category__c == 'Booked' || o.Pipeline_Category__c == 'Lost') && (o.Number_of_Days_since_Last_Interaction__c >= 30 && o.Number_of_Days_since_Last_Interaction__c <= 730)) {
                    o.Stale__c = 'No';
                }
                else {
                    o.Stale__c = 'No';
                }
            }
            else if(system.today()+730 < o.CloseDate) {
                if(o.Category__c == 'Greenfield' || o.Category__c == 'New Cust - Comp Conv' || o.Category__c == 'Exist Cust - Comp Conv') {
                    if(o.Pipeline_Category__c == 'Development' && (o.Number_of_Days_since_Last_Interaction__c >= 30 && o.Number_of_Days_since_Last_Interaction__c <= 90)) {
                        o.Stale__c = 'No';
                    }
                    else if(o.Pipeline_Category__c == 'Development' && (o.Number_of_Days_since_Last_Interaction__c >= 91)) {
                        o.Stale__c = 'Yes';
                    }
                    else if(o.Pipeline_Category__c == 'Upside' && (o.Number_of_Days_since_Last_Interaction__c >= 30 && o.Number_of_Days_since_Last_Interaction__c <= 60)) {
                        o.Stale__c = 'No';
                    }
                    else if(o.Pipeline_Category__c == 'Upside' && (o.Number_of_Days_since_Last_Interaction__c > 60)) {
                        o.Stale__c = 'Yes';
                    }
                    else if(o.Pipeline_Category__c == 'Committed' && (o.Number_of_Days_since_Last_Interaction__c >= 30)) {
                        o.Stale__c = 'Yes';
                    }
                    else if((o.Pipeline_Category__c == 'Booked' || o.Pipeline_Category__c == 'Lost') && (o.Number_of_Days_since_Last_Interaction__c >= 30)) {
                        o.Stale__c = 'No';
                    }
                }
                else if(o.Category__c != 'Greenfield' || o.Category__c != 'New Cust - Comp Conv' || o.Category__c != 'Exist Cust - Comp Conv') {
                    if(system.today()+365 >= o.Last_Interaction_Date__c) {
                        o.Stale__c = 'No';
                }
                    else if(system.today()+365 <= o.Last_Interaction_Date__c){
                        o.Stale__c = 'Yes';
                    }
                }
            }
            else{
                o.Stale__c = 'No';
            }
            opportunityUpdatedList.add(o);
        }  */
        OpportunityTriggerHandler.TriggerDisabled = true;
        if(opportunityUpdatedList != null && opportunityUpdatedList.size()>0){
            Try{
                update opportunityUpdatedList;
            }catch(Exception e){
                 system.debug('##The following exception has occurred: '+ e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext bc){

    }
}