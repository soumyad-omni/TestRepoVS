/**********************************************************************
Name:  CampaignMemberTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains methods for CampaignMemberTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          ?                          ?          INITIAL DEVELOPMENT
***********************************************************************/
public class CampaignMemberTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static boolean fromtaskassigncontroller = false;//Added by sravan for SF-BUG-778
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('CampaignMemberTriggerDisabled');
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
        
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        CampaignMember cm1= new CampaignMember();
        for(CampaignMember cm: [SELECT Id, Campaign.status,status FROM CampaignMember where Id IN:oldItems.keyset()]){
             if(cm.Campaign.status=='Completed')
             {
                cm1= (CampaignMember)oldItems.get(cm.id);
                //cm1.addError('Campaign Memebers cant be removed if Campaign status is closed/Completed');
                cm1.addError(system.Label.ErrorOnCampaignMemberRemove);
             }   
             
            if(cm.Campaign.status!='Completed'&& cm.status!='Remove')
            
            {
             
               cm1= (CampaignMember)oldItems.get(cm.id);
             
                //cm1.addError('Campaign Memebers cant be removed if Campaign status is closed/Completed');
                cm1.addError(system.Label.ErrorOnCampaignMemberRemoveStatusNotCompleted);

            
            }
        }
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
        List<CampaignMember> cmpList=oldItems.values();
        deleteFieldTrackedRecord(cmpList); // Method to delete field tracked record from CampaignMemberAudit
        createRecord(cmpList);  //Method to create campaign member history record
        manageDeleteCampaignMember(oldItems.values());//added by SAM
        //sendMail(cmpList);        //Method to send Email Notification
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
        managePrimaryCampaignMemeber(newItems.values(), new Map<Id, CampaignMember>());//added by Sam
    } 
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================    
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        if(!fromtaskassigncontroller){//Added by sravan for SF-BUG-778
        List<CampaignMember> cmNewList=newItems.values();
        List<CampaignMember> cmOldList=oldItems.values();
        //trackFieldChanges(cmNewList,cmOldList);  //Method to track any field changes on campaign member record
        managePrimaryCampaignMemeber(newItems.values(), (Map<Id, CampaignMember>)oldItems);
        }//Added by sravan for SF-BUG-778
    }    
    // This method is to create Campaign Member History record after deletion of Campaign Member
    /*
        Author              : Venu Kukkapalli       Last Modified By    :
        Created Date        : 06/11/2018            Last Modified Date  :
        Description         : Creation of Campaign Member History record on deletion of Campaign Member
    */
    public void createRecord(List<CampaignMember> cmlist){
        List<Campaign_Member_History__c> cmHistoryList=new List<Campaign_Member_History__c>();
        for(CampaignMember cm:cmlist){
            Campaign_Member_History__c cmh=new Campaign_Member_History__c();
            cmh.Campaign__c=cm.CampaignId;
            cmh.Campaign_Member_Id__c=cm.Id;
            if(cm.FirstName!=Null)
                cmh.Name=cm.FirstName+cm.LastName;
            else
                cmh.Name=cm.LastName;
                
            cmh.Deleted_By__c=cm.LastModifiedById;
            
            if(cm.ContactId==null)
                cmh.Type__c='Lead';
            else
                cmh.Type__c='Contact';
            cmh.Status__c=cm.Status;
            cmh.First_Name__c=cm.FirstName;
            cmh.Last_Name__c=cm.LastName;
            //system.debug('1---'+cmh.campaign__c+'2---'+cmh.Campaign_Member_Id__c+'3---'+cmh.Name+'4---'+cmh.Deleted_By__c+'5---'+cmh.Deleted_Date__c+'6---'+cmh.Type__c+'7---'+cmh.Status__c+'8---'+cmh.First_Name__c+'9---'+cmh.last_Name__c);
            cmHistoryList.add(cmh);
        }
        insert cmHistoryList;
    } 
    
    // This method is to track any changes made to any fields on campaign member,update accordingly in CampaignMemberAudit record.
    /*public void trackFieldChanges(List<CampaignMember> cmNewList,List<CampaignMember> cmOldList){
       
       set<Id> campaignid = new set<Id>();
       if(cmOldList.size()>0)
       {
        for(CampaignMember oldcm: cmOldList)
        {
           campaignid.add(oldcm.CampaignId);
           
        }
      } 
       List<Campaign_Member_History__c> cmHistoryList=new List<Campaign_Member_History__c>();
       cmHistoryList=[select id,Campaign__c,Status__c,Cancel_Date__c,Tour_Date__c,Inquiry_Date__c,Campaign_Member_Id__c,Register_Date__c,Product_Opportunity__c,Description__c from Campaign_Member_History__c where Campaign__c IN:campaignid];
       Map<String,Campaign_Member_History__c> cmhMap = new Map<String,Campaign_Member_History__c>();
        for(Campaign_Member_History__c cmh : cmHistoryList){
            if(cmh.Campaign__c != null && cmh.Campaign_Member_Id__c!=null){
                cmhMap.put(cmh.Campaign_Member_Id__c,cmh);
            }
        }
        System.debug('chmMap : '+cmhMap);
       
       
       List<Campaign_Member_History__c> cmHistoryListUpdates=new List<Campaign_Member_History__c>(); 
        if(cmNewList.size()>0)
        {
         for(CampaignMember cm:cmNewList){
         
            for(CampaignMember oldcm: cmOldList)
            {
            
               if(cm.Status != oldcm.Status|| cm.Cancel_Date__c != oldcm.Cancel_Date__c || cm.Tour_Date__c != oldcm.Tour_Date__c || cm.Inquiry_Date__c != oldcm.Inquiry_Date__c || cm.Register_Date__c != oldcm.Register_Date__c || cm.Product_Opportunity__c != oldcm.Product_Opportunity__c || cm.Description != oldcm.Description)
               {
                 
                   //for(Campaign_Member_History__c cmhistory : cmHistoryList)
                  //{
                    //if(cmhistory.Campaign__c!=null && cmhistory.Campaign_Member_Id__c==cm.id)
                    //{
                     if(cmhMap.size()>0){
                     Campaign_Member_History__c cmhistory = cmhMap.get(cm.id);
                     system.debug('Inside if'+cmhistory);
						
                       if(cmhistory != null){ 
                      cmhistory.Status__c = cm.Status;
                      cmhistory.Cancel_Date__c = cm.Cancel_Date__c;
                      cmhistory.Tour_Date__c = cm.Tour_Date__c;
                      cmhistory.Inquiry_Date__c = cm.Inquiry_Date__c;
                      cmhistory.Register_Date__c = cm.Register_Date__c;
                      cmhistory.Product_Opportunity__c = cm.Product_Opportunity__c;
                      cmhistory.Description__c = cm.Description;
                      cmHistoryListUpdates.add(cmhistory);
                    }
                  }
               }   
            }   
            
         }
         try{
            
            system.debug('### cmHistoryListUpdates' +cmHistoryListUpdates);
            update cmHistoryListUpdates;
         }
          catch(Exception e){
             System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
             ErrorLogging.Log(e, 'trackFieldChanges','App');
            } 
       } 
        
    
    }
     */ 
     // Method to delete field tracked record from CampaignMemberAudit
      
     public void deleteFieldTrackedRecord(List<CampaignMember> cmpList){
     
     set<Id> campaignid = new set<Id>();
       if(cmpList.size()>0)
       {
        for(CampaignMember oldcm: cmpList)
        {
           campaignid.add(oldcm.CampaignId);
           
        }
      } 
       List<Campaign_Member_History__c> cmHistoryList=new List<Campaign_Member_History__c>();
       cmHistoryList=[select id,Campaign__c,Status__c,Cancel_Date__c,Tour_Date__c,Inquiry_Date__c,Register_Date__c,Product_Opportunity__c,Description__c from Campaign_Member_History__c where Campaign__c IN:campaignid and Campaign_Member_Deleted_Date__c=null and Deleted_By__c=''];
       system.debug('history...'+cmHistoryList);
       
       List<Campaign_Member_History__c> deleteFieldTrackedList = new List<Campaign_Member_History__c>();
       
     for(Campaign_Member_History__c  cma: cmHistoryList)
      {
          
        deleteFieldTrackedList.add(cma);
      }
    
     try{
     delete deleteFieldTrackedList;
     system.debug('deleted...'+deleteFieldTrackedList);
     }
     catch(Exception e){
             System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
             ErrorLogging.Log(e, 'deleteFieldTrackedRecord','App');
            } 
     }
     
     
     private void managePrimaryCampaignMemeber(List<CampaignMember> lstCampaignMemberNew, Map<Id, CampaignMember> mapCampaignMemberOld){
        Map<Id, CampaignMember> mapCampaignMemberNew = new Map<Id, CampaignMember>(lstCampaignMemberNew);
        Map<Id, CampaignMember> mapCampaignMember = new Map<Id, CampaignMember>([SELECT Id, LeadId, Campaign.IsActive FROM CampaignMember WHERE Id IN: mapCampaignMemberNew.keySet()]);
        Map<Id, Lead> mapLead = new Map<Id, Lead>();
        Map<Id, Id> mapLeadIdToCampaignMemberId = new Map<Id, Id>();
        for(CampaignMember objCM : lstCampaignMemberNew){
            if(String.isBlank(objCM.LeadId) || String.isEmpty(objCM.LeadId)) continue;
            if((Trigger.isInsert && objCM.Primary_Campaign__c) || (Trigger.isUpdate && objCM.Primary_Campaign__c && objCM.Primary_Campaign__c != mapCampaignMemberOld.get(objCM.Id).Primary_Campaign__c)){
                if(!mapCampaignMember.get(objCM.Id).Campaign.IsActive){
                    objCM.addError('Campaign is not an active Campaign.');
                    continue;
                }
            }
            if((Trigger.isInsert && objCM.Primary_Campaign__c) || (Trigger.isUpdate && objCM.Primary_Campaign__c && objCM.Primary_Campaign__c != mapCampaignMemberOld.get(objCM.Id).Primary_Campaign__c)){
                mapLeadIdToCampaignMemberId.put(objCM.LeadId, objCM.Id);
                mapLead.put(objCM.LeadId,  new Lead(Id = objCM.LeadId, Source_Campaign__c = objCM.CampaignId));
            }else if(Trigger.isUpdate && !objCM.Primary_Campaign__c && objCM.Primary_Campaign__c != mapCampaignMemberOld.get(objCM.Id).Primary_Campaign__c && !mapLead.containsKey(objCM.LeadId)){
                mapLead.put(objCM.LeadId, new Lead(Id = objCM.LeadId, Source_Campaign__c = null));
            }
        }
        for(CampaignMember objCM : [SELECT Id, LeadId, CampaignId, Campaign.Name FROM CampaignMember WHERE LeadId IN: mapLeadIdToCampaignMemberId.keySet() AND Id NOT IN: mapLeadIdToCampaignMemberId.values() AND Primary_Campaign__c = true]){
            mapLead.remove(objCM.LeadId);
            mapCampaignMemberNew.get(mapLeadIdToCampaignMemberId.get(objCM.LeadId)).addError('There is already a primary CampaignMember for this lead with Campaign Name: '+objCM.Campaign.Name);
        }
        update mapLead.values();
    }
    
    private void manageDeleteCampaignMember(List<CampaignMember> lstCampaignMemberOld){
        Map<Id, Lead> mapLead = new Map<Id, Lead>();
        for(CampaignMember objCM : lstCampaignMemberOld){
            if(objCM.Primary_Campaign__c && objCM.LeadId != null){
                mapLead.put(objCM.LeadId, new Lead(Id = objCM.LeadId, Source_Campaign__c = null));
            }
        }
        update mapLead.values();
    }
}