public class BookingPackApprovalTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = [Select Name, isDisabled__c From Trigger_Configuration__c Where Name ='BookingPackTriggerDisabled'];
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        //IBA-3538 START AC
        List<Booking_Pack_Approval__c> newBPList = newItems;
        user u = [Select Id, Email, ManagerId, Manager.Email from user where Id=: userInfo.getUserId() LIMIT 1];
        String oppId = newBPList[0].Opportunity_Name__c;
        Opportunity opp = [Select Id, Opportunity.Owner.Email From Opportunity where Id =: oppId LIMIT 1];
        System.debug('User Details::::'+u);
        for(Booking_Pack_Approval__c bpa:  newBPList){
        	if(u != null || opp != null){
            	bpa.Reporting_Manager_Email__c = u.Manager.Email;
                bpa.Opportunity_Owner_Email__c = opp.Owner.Email;
            }
        }
        //IBA-3538 STOP AC
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        
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
        
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
       	List<Booking_Pack_Approval__c> oldBPList = oldItems.values();
        List<Booking_Pack_Approval__c> newBPList = newItems.values();
        Set<id> aapIds = new Set<id>(); //IBA-4178
        if(newBPList[0].Status__c == 'Paperwork Validated' && newBPList[0].Status__c != null){
            updateOpportunityAfterApproval(newBPList);
        }
       	//IBA-4178 Starts Abhrajitc
        if(newBPList != null && newBPList.size() > 0){
            for(Booking_Pack_Approval__c bpa: newBPList){
                aapIds.add(bpa.id);
            }
            if(newBPList[0].Status__c == 'Paperwork Validated' || newBPList[0].Status__c == 'Paperwork Rejected'){
                updateApprovalOrRejectionComment(aapIds);
            }
        }
        //IBA-4178 Ends 
    }
    public void updateOpportunityAfterApproval(List<Booking_Pack_Approval__c> newBPList) {
        Set<Id> opportunityId = new Set<Id>();
        string bpaComments = '';
        for (Booking_Pack_Approval__c bp: newBPList) {
            if (bp.Opportunity_Name__c != null) {
                opportunityId.add(bp.Opportunity_Name__c);
            }
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Paperwork_Submitted_Date__c, Paperwork_Validated_Date__c FROM Opportunity where Id in :opportunityId]);
        List<Opportunity> opp2Update = new List<Opportunity>();
        Boolean bpaFlag = false;
        for (Booking_Pack_Approval__c bpa: newBPList) {
            if(bpa.Status__c != null){
               if(bpa.Status__c == 'Paperwork Validated'){
                Opportunity oppUpdate = new Opportunity();
                oppUpdate = oppMap.get(bpa.Opportunity_Name__c);
                oppUpdate.Paperwork_Submitted_Date__c = bpa.Papwerwork_Submitted_Date__c;
                oppUpdate.Paperwork_Validated_Date__c = bpa.Paperwork_Validated_Date__c;
                opp2Update.add(oppUpdate);
            }
            }
        }
        OpportunityTriggerHandler.TriggerDisabled = true;
        if(opp2Update.size() > 0 ) {
            update opp2Update;
        }
    }
    //IBA-4178 Starts Abhrajitc
    @future
    public static void updateApprovalOrRejectionComment(Set<ID> ids) {
        System.debug('@Developer--> Copying the comment to add to the BPA approval object Approved/Reject Comments field.');
        List<ProcessInstance> pi = [SELECT Id, TargetObjectid, Status, (SELECT Id, StepStatus,Actor.Name, Comments FROM StepsAndWorkitems WHERE (StepStatus = 'Approved' OR StepStatus = 'Rejected')) FROM ProcessInstance WHERE TargetObjectId =: ids];
        System.debug(pi);
        List<Booking_Pack_Approval__c> aapList = [Select id,Approve_Reject_Comments__c from Booking_Pack_Approval__c where id =: ids];
        Map<Id, String> map1 = new Map<Id, String>();
        if(pi.size() > 0) {
            for(ProcessInstance p: pi) {
                if(p.StepsAndWorkitems.size() > 0) {
                map1.put(p.TargetObjectid,p.StepsAndWorkitems[0].Comments);
                }
            }
        }
        for(Booking_Pack_Approval__c aap: aapList) {
            String bpaComments = map1.get(aap.Id);
            if(bpaComments != null && bpaComments != '') {
                aap.Approve_Reject_Comments__c = bpaComments;
            }
        }
        BookingPackApprovalTriggerHandler.TriggerDisabled = True;
        try {
            update aapList;
        }catch(Exception e) {
            System.debug('Exception:' +e);
        }
    }
    //IBA-4178 Ends Abhrajitc
}