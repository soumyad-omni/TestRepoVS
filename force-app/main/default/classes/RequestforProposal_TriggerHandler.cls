/*********************************************************************
Jira Number: IBA-4546
Name:      RequestforProposal_TriggerHandler
Test Class:   
Purpose:   This class contains the logic for processing the trigger events for 'Request for Approval' Object. It also contains the
           logic for custom field history tracking of this object.
=======================================================================
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Saptarsha Panthi        08/24/2023            Initial Creation
************************************************************************/

public class RequestforProposal_TriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public static boolean isFirstRun=True;
    public static boolean isUpdatefromOpps=False;
    public boolean isDisabled;
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('RequestforProposalTriggerDisable');
        if(tc != null) isDisabled = tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        List<Request_for_Proposal__c> newRequestforProposals = newItems;
        Set<Id> Oppids= new Set<Id>();
        Map<Id,Id> oppmap = new Map<Id, Id>();
        Map<Id,Id> oppmapPL = new Map<Id, Id>();
        Map<Id, String> oppmapstage = new Map<Id, String>();
        List<Product_Line__c> prdlinestoUpdate = new List<Product_Line__c>();
        For(Request_for_Proposal__c rfp: newRequestforProposals){
            Integer quarter = DateTime.now().month(); 
            if(quarter<=3 ){
                rfp.Quarter__c='1';
            }
            else if(quarter>3 && quarter<=6){
                rfp.Quarter__c='2';
            }
            else if(quarter>6 && quarter<=9){
                rfp.Quarter__c='3';
            }
            else {
                rfp.Quarter__c='4';
            }
            if(rfp.Deal_Value__c>0 || rfp.Deal_Value__c<0){
               rfp.addError('Deal Value is the sum of the Expected Bookings of the Opportunities that are associated with it. Users cannot change it manually'); 
            }
            if(rfp.Deal_Value__c==Null){
               rfp.Deal_Value__c=0; 
            }
        } 
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================    
    public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newItems){
        List<Request_for_Proposal__c> oldrfpslist = oldMap.values();
        System.debug(oldrfpslist);
        List<Request_for_Proposal__c> newrfpslist = newItems.values(); 
        System.debug(newrfpslist);
        Map<Id, Request_for_Proposal__c> oldrfpsmap = new Map<Id, Request_for_Proposal__c>(oldrfpslist);
        Map<Id, String> oppmapstage = new Map<Id, String>();
        Set<Id> Oppids= new Set<Id>();
        Set<Id> rfpids = new Set<Id>();
        Map<Id,Integer> countopportunitywon = new Map<Id,Integer>();
        Map<Id,Integer> countopportunitylost = new Map<Id,Integer>();
        Map<Id,Id> opprfpmap = new Map<Id,Id>();//IBA-4546
        for(Request_for_Proposal__c rfp: newrfpslist){
            if(rfp.Result__c!=oldrfpsmap.get(rfp.Id).Result__c){
            rfpids.add(rfp.Id);    
            }
            if(rfp.Deal_Value__c!=oldrfpsmap.get(rfp.Id).Deal_Value__c && isUpdatefromOpps==false){
                System.debug(isUpdatefromOpps);
                rfp.addError('Deal Value is the sum of the Expected Bookings of the Opportunities that are associated with it. Users cannot change it manually');
        }
        }
        if(rfpids.size()>0){
            List<Opportunity> opplist = [Select Id, StageName, Request_for_Proposal_Id__c From Opportunity Where Request_for_Proposal_Id__c =:rfpids];
            for(Opportunity opp: opplist){
                opprfpmap.put(opp.Id, opp.Request_for_Proposal_Id__c);
                if(opp.StageName=='6 Closed Won' && countopportunitywon.get(opp.Request_for_Proposal_Id__c)!=null){
                    countopportunitywon.put(opp.Request_for_Proposal_Id__c, countopportunitywon.get(opp.Request_for_Proposal_Id__c)+1);
                }
                else{
                    countopportunitywon.put(opp.Request_for_Proposal_Id__c, 1);  
                }
                if(opp.StageName=='7 Closed Lost' && countopportunitylost.get(opp.Request_for_Proposal_Id__c)!=null){
                    countopportunitylost.put(opp.Request_for_Proposal_Id__c, countopportunitylost.get(opp.Request_for_Proposal_Id__c)+1);
                }
                else{
                    countopportunitylost.put(opp.Request_for_Proposal_Id__c, 1);  
                } 
            }
        }
        for(Request_for_Proposal__c rfp1: newrfpslist){
            if(rfp1.Result__c!=oldrfpsmap.get(rfp1.Id).Result__c){
                if(countopportunitywon.get(rfp1.Id)>0 && oldrfpsmap.get(rfp1.Id).Result__c=='Won' && isUpdatefromOpps==false){
                   rfp1.addError('Cannot change the Result field value of this Request for Proposal as a Opportunity with Stage 6 Closed Won is associated with it.');
                    System.debug(isUpdatefromOpps);
                }
                if(countopportunitylost.get(rfp1.Id)>0 && oldrfpsmap.get(rfp1.Id).Result__c=='Lost' && isUpdatefromOpps==false){
                    if(rfp1.Result__c!='Won'){
                     rfp1.addError('Cannot change the Result field value of this Request for Proposal as a Opportunity with Stage 7 Closed Lost is associated with it.');   
                    }
                    else{
                       rfp1.addError('Cannot change the Result field value of this Request for Proposal as Opportunity with Stage 7 Closed Lost is associated with it but no Opportunity with Stage 6 Closed Won is associated.'); 
                    }
                    System.debug(isUpdatefromOpps);
                }
            }
        }
    }
        //=============================================================================
        // BEFORE DELETE
        //=============================================================================
        public void beforeDelete(Map<Id, SObject> oldItems){
            
        }

        //=============================================================================
        // AFTER DELETE
        //=============================================================================
        public void afterDelete(Map<Id, SObject> oldItems){
            
        }
        //=============================================================================
        // AFTER UNDELETE
        //=============================================================================
        public void afterUndelete(Map<Id, SObject> oldItems){
            
        }
        //=============================================================================
        // AFTER INSERT
        //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        Set<Id> rfpid = new Set<Id>();
        List<Request_for_Proposal__c> newrfps = newItems.values();
        List <Request_for_Proposal_field_history__c> rfphistory = new List <Request_for_Proposal_field_history__c>();
        for(Request_for_Proposal__c r:newrfps){
            Request_for_Proposal_field_history__c rhistory = new Request_for_Proposal_field_history__c();
            rhistory.Request_for_Proposal__c = r.id;
            rhistory.Field__c = 'Created';
            rhistory.User__c = UserInfo.getUserId();
            rhistory.Date__c = DateTime.now();
            rfphistory.add(rhistory);
        }
        insert rfphistory;
    }
        //=============================================================================
        // AFTER UPDATE
        //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Request_for_Proposal__c> oldrfpslist = oldItems.values();
        System.debug(oldrfpslist);
        List<Request_for_Proposal__c> newrfpslist = newItems.values(); 
        System.debug(newrfpslist);
        List<Request_for_Proposal_field_history__c> rfphistoriesToInsert = new List<Request_for_Proposal_field_history__c>();
        Set<Id> Oppids = new Set<Id>();
        Map<Id, Request_for_Proposal__c> oldrfpsmap = new Map<Id, Request_for_Proposal__c>(oldrfpslist);
        //Custom History Tracking for Request for Proposal Object Start
        List<Request_for_Proposal_fields_to_Track__c> r = [Select Name From Request_for_Proposal_fields_to_Track__c];
        List<string> r1 = new List<string>();
        for(Request_for_Proposal_fields_to_Track__c rhist : r){
            r1.add(rhist.name);
        }
        set<string> rfpset = new set<string>();
        rfpset.addall(r1);
        Map<String, Schema.SObjectField> allrfpFieldsMap = Schema.SObjectType.Request_for_Proposal__c.fields.getMap();
        Map<String, Schema.DescribeFieldResult> rfpFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
        for (Schema.SObjectField rfpField : allrfpFieldsMap.values()) {
            Schema.DescribeFieldResult describeResult = rfpField.getDescribe();
            
            if (describeResult.getName() != 'CreatedDate' &&
                describeResult.getName() != 'LastModifiedDate' &&
                describeResult.getName() != 'SystemModstamp' &&
                describeResult.isAccessible() &&
                !describeResult.isCalculated()
               )
            {
                if(rfpset.contains(describeResult.getName().toUpperCase())){
                    rfpFieldsToTrack.put(describeResult.getName(), describeResult);
                }
            }  
        }
        System.debug(rfpFieldsToTrack);
        
        Schema.DescribeFieldResult quarterpickval = Request_for_Proposal__c.Quarter__c.getDescribe();
        Map<String,String> quarterpickvalMap = getPickListMap(quarterpickval);
        
        Schema.DescribeFieldResult statuspickval = Request_for_Proposal__c.Status__c.getDescribe();
        Map<String,String> statuspickvalMap = getPickListMap(statuspickval);
        
        Schema.DescribeFieldResult responsetypepickval = Request_for_Proposal__c.Response_Type__c.getDescribe();
        Map<String,String> responsetypepickvalMap = getPickListMap(responsetypepickval);
        
        Schema.DescribeFieldResult deliverymethodpickval = Request_for_Proposal__c.Delivery_Method__c.getDescribe();
        Map<String,String> deliverymethodpickvalMap = getPickListMap(deliverymethodpickval);
        
        Schema.DescribeFieldResult resultpickval = Request_for_Proposal__c.Result__c.getDescribe();
        Map<String,String> resultpickvalMap = getPickListMap(resultpickval);
        
        for(Request_for_Proposal__c newrfp : newrfpslist){
            Request_for_Proposal__c oldrfp = oldrfpsmap.get(newrfp.Id);
            for (Schema.DescribeFieldResult fieldDescribe : rfpFieldsToTrack.values()) {
                Request_for_Proposal_field_history__c rfpHistory = new Request_for_Proposal_field_history__c();
                string rfpOld = '';
                string rfpNew ='';
                string fieldName ='';
                string rfpold_eb ='';
                string rfpnew_eb ='';
                if (oldrfp.get(fieldDescribe.getName()) != newrfp.get(fieldDescribe.getName())){
                    fieldName = fieldDescribe.getLabel();
                    System.debug('****'+fieldDescribe.getName().toUpperCase());                
                if(fieldDescribe.getName().toUpperCase() == 'STATUS__C'){                        
                    rfpOld = statuspickvalMap.get(string.valueOf((oldrfp.get(fieldDescribe.getName()))));
                    rfpNew = statuspickvalMap.get(string.valueOf((newrfp.get(fieldDescribe.getName()))));
                }
                
                else if(fieldDescribe.getName().toUpperCase() == 'QUARTER__C'){                        
                    rfpOld = quarterpickvalMap.get(string.valueOf((oldrfp.get(fieldDescribe.getName()))));
                    rfpNew = quarterpickvalMap.get(string.valueOf((newrfp.get(fieldDescribe.getName()))));
                }
                else if(fieldDescribe.getName().toUpperCase() == 'RESPONSE_TYPE__C'){                        
                    rfpOld = responsetypepickvalMap.get(string.valueOf((oldrfp.get(fieldDescribe.getName()))));
                    rfpNew = responsetypepickvalMap.get(string.valueOf((newrfp.get(fieldDescribe.getName()))));
                }
                else if(fieldDescribe.getName().toUpperCase() == 'RESULT__C'){                        
                    rfpOld = resultpickvalMap.get(string.valueOf((oldrfp.get(fieldDescribe.getName()))));
                    rfpNew = resultpickvalMap.get(string.valueOf((newrfp.get(fieldDescribe.getName()))));
                }
                else if(fieldDescribe.getName().toUpperCase() == 'DELIVERY_METHOD__C'){                        
                    rfpOld = deliverymethodpickvalMap.get(string.valueOf((oldrfp.get(fieldDescribe.getName()))));
                    rfpNew = deliverymethodpickvalMap.get(string.valueOf((newrfp.get(fieldDescribe.getName()))));
                }
                else{
                    rfpOld = string.valueOf((oldrfp.get(fieldDescribe.getName())));
                    rfpNew = string.valueof((newrfp.get(fieldDescribe.getName())));
                }
                rfpHistory = createUpdateHistory(fieldName, rfpOld, rfpNew, newrfp);
                rfphistoriesToInsert.add(rfpHistory);
            }
            }
        }
        system.debug('List check'+rfphistoriesToInsert);
        
        if (!rfphistoriesToInsert.isEmpty()) {
            List<Request_for_Proposal_field_history__c> historiesToInsertWithoutDuplicates = new List<Request_for_Proposal_field_history__c>();
            Set<Request_for_Proposal_field_history__c> rfphistoriesSet = new Set<Request_for_Proposal_field_history__c>();
            rfphistoriesSet.addAll(rfphistoriesToInsert);
            historiesToInsertWithoutDuplicates.addAll(rfphistoriesSet);
            system.debug('Request For Proposal histories To Insert '+historiesToInsertWithoutDuplicates);
            insert historiesToInsertWithoutDuplicates;
            }
        //Custom History Tracking for Request for Proposal Object End
        }
        public static Map<String,String> getPickListMap(Schema.DescribeFieldResult pickList){//Method to map the picklist values with picklist label
        Map<String,String> pickListMap = new Map<String,String>();
        List<Schema.PicklistEntry> pickListvalues = pickList.getPicklistValues();     
        for( Schema.PicklistEntry v : pickListvalues) {
            pickListMap.put(v.getValue(),v.getLabel());        
        }
        return pickListMap;
    }
    
    Public Request_for_Proposal_field_history__c createUpdateHistory(String field, string oldrfp, string newrfp, Request_for_Proposal__c rfp) {//Method to assign the field values for Request for Proposal field history Object.

        Request_for_Proposal_field_history__c rfpHistory = new Request_for_Proposal_field_history__c();
        rfpHistory.Request_for_Proposal__c = rfp.Id;
        rfpHistory.Field__c = field;
        rfpHistory.User__c = UserInfo.getUserId(); 
        rfpHistory.Date__c = Datetime.now();
        if (oldrfp != null) rfpHistory.ORIGINAL_VALUE__c = oldrfp;
        if (newrfp != null) rfpHistory.NEW_VALUE__c = newrfp;
        return rfpHistory;
    }
    
    }