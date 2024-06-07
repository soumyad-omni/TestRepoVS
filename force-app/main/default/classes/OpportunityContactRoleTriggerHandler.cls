public class OpportunityContactRoleTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('OpportunityContactRoleTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        List<OpportunityContactRole> ocrList = newItems;
        // IBA-3824 - Abhrajitc Starts
        Set<id> oppIds = new Set<id>();
        List<OpportunityContactRole> oppConShipList = new List<OpportunityContactRole>();
        for(OpportunityContactRole ocr : ocrList) {
            oppIds.add(ocr.OpportunityId);
        }
        oppConShipList = [SELECT Id, ContactId, Role FROM OpportunityContactRole WHERE OpportunityId IN:oppIds AND Role = 'S-Shipping Contact' ];
        System.debug('@Developer--> Shipping Contact Role:::'+oppConShipList);
        for(OpportunityContactRole ocr: ocrList){
            if(oppConShipList != null && oppConShipList.size() > 0){
                ocr.addError('This Opportunity already contains a Contact Role with S-Shipping Contact. Please delete the existing Contact Role to create a new One.');
            }
        }
        Set<Id> contactIds = new Set<Id>();
        for (OpportunityContactRole ocr : ocrList) {
            if (ocr.Role == 'S-Shipping Contact') {
                contactIds.add(ocr.ContactId);
            }
        }
        Set<Id> oppIdToUpdate = new Set<Id>();
        Map<String,String> oppContactRoleMap = new Map<String,String>();//IBA-4948 Sourav
        for (OpportunityContactRole ocr : ocrList) {
            if (ocr.Role == 'S-Shipping Contact') {
                oppIdToUpdate.add(ocr.OpportunityId);
                oppContactRoleMap.put(ocr.OpportunityId,ocr.ContactId);//IBA-4948 Sourav
            }
        }
        //IBA-4948 Sourav - Start
        List<Quote> allQuotes = [SELECT Id, OpportunityId, Shipping_Contact__c, Is_Shipping_Contact_Update__c, Primary_Quote__c, Status 
                                 FROM Quote WHERE OpportunityId IN: oppIdToUpdate AND Primary_Quote__c = True 
                                 AND Status IN ('E0001','E0018','E0004','E0007','E0009','E0003') 
                                 // AND Opportunity.RecordType.Name ='U.S & Canada Opportunity'];
        						 AND Opportunity.RecordType.DeveloperName IN ('NAA_Opportunity','US_Canada_Advanced_Services','US_Canada_Specialty')]; //IBA-5992
        
        for (Quote q: allQuotes){
            q.Shipping_Contact__c = oppContactRoleMap.get(q.OpportunityId);
            q.Is_Shipping_Contact_Update__c = True;
        }
        update allQuotes;
        //IBA-4948 Sourav - End
    }
    // IBA-3824 - Abhrajitc Ends
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        //IBA-3824 Starts
        List<OpportunityContactRole> ocrNewlList = newItems.Values();
        List<OpportunityContactRole> ocrOldlList = oldItems.Values();
        if (ocrNewlList[0].Role == 'S-Shipping Contact' && ocrNewlList[0].ContactId != ocrOldlList[0].ContactId) {
            ocrNewlList[0].addError('You cannot change the shipping contact for this opportunity.');
        }
    }//IBA-3824 Ends
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        //IBA-3824
        List<OpportunityContactRole> ocrDelList = oldItems.Values();
        Set<Id> oppIdsToUpdate = new Set<Id>();
        for (OpportunityContactRole ocr : ocrDelList) {
            if (ocr.Role == 'S-Shipping Contact') {
                oppIdsToUpdate.add(ocr.OpportunityId);
            }
        }
        if (!oppIdsToUpdate.isEmpty()) {
            List<Quote> quotesToUpdate = [SELECT Id, Is_Shipping_Contact_Update__c, Status FROM Quote WHERE OpportunityId IN :oppIdsToUpdate];
            for (Quote q : quotesToUpdate) {
                if (q.Is_Shipping_Contact_Update__c == true && (q.Status == 'E0001' || q.Status == 'E0018' || q.Status == 'E0004' || q.Status == 'E0007' || q.Status == 'E0009' || q.Status == 'E0003')) {
                    q.Is_Shipping_Contact_Update__c = false;
                }
            }
            if (quotesToUpdate != null && quotesToUpdate.size()> 0){
                QuoteTriggerHandler.TriggerDisabled = true;
                update quotesToUpdate;
            }
        }
    }//IBA-3824
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        System.debug('inside after insert....');
        List<OpportunityContactRole> ocrList = newItems.values();
        Set<id> conIds = new Set<id>(); 
        List<Contact> conList = new List<Contact>();
        for(OpportunityContactRole ocr : ocrList) {
            conIds.add(ocr.ContactId);           
        }
        conList = [Select id,Sales_Qualified_Lead_Date__c from Contact where id IN:conIds];
        System.debug('conids:' +conIds);
        if(conList != null && conList.size() > 0){
            setSalesQualifiedLeadDateOnContact(conList);
        }
    }
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        
    }
    
    public static void setSalesQualifiedLeadDateOnContact(List<Contact> conList) {
        List<Contact> conList1 = new List<Contact>();
        for(Contact con : conList) {
            if(con.Sales_Qualified_Lead_Date__c == Null) {
                con.Sales_Qualified_Lead_Date__c =  DateTime.now();
                conList1.add(con);
            }
        }
        if(conList1 != Null && conList.size()>0) {
            update conList1; 
        } 
    }
}