/**********************************************************************
Name:  TaskTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for TaskTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Supriya  Ambre           11/06/2018       INITIAL DEVELOPMENT
***********************************************************************/

public with sharing class TaskTriggerHandler implements ITriggerHandler {
    
    
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('TaskTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    //public void beforeInsert(Task[] newList) {
    public void beforeInsert(List<SObject> newItems) {
        // checkIfCampaignExists(newList);
        //assignTasktoCampaignMember(newList);//commented by sravan for SF-BUG-778 on 23 JAN
        List<Task> newlist = newItems;//IBA-5055
        String profileNama = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1].Name; //IBA-2344 Start
        if(profileNama != 'System Administrator' && profileNama != 'Business Administrator'){
            validationCheckDeletedAccountOrNotSoldTo(newList);
        }
        checkParentSalesActivity(newList);
        taskCompleted(newList);
        setOriginalDueDate(newList);
        updateFields(newList); //Added for SF-BUG-990
        //IBA-5055 Start Saptarsha Panthi
        for(Task tk: newList){
            if(tk.Approved__c==false){
                tk.Approved_Date__c=null;
            } 
        }
        //IBA-5055 End Saptarsha Panthi
    }
    public static void checkParentSalesActivity(List<Task> taskList){
        Sales_Activity__c sa = new Sales_Activity__c();
        insert sa;
        for(Task t: taskList){
            if(t.Create_New_Parent_Sales_Activity_Linked__c == true){
                t.Parent_Sales_Activity__c = sa.id;
            }
        }
    }
    
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems) {
        List<Task> newList = newItems.values();
        checkParentSalesActivity(newList);
        taskCompleted(newList);
        updateFields(newList); //Added for SF-BUG-990

        //SF-BUG-989
        List<Profile> assignedProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        for (Task objTask : newList) {
            Task oldValueTask = (Task)oldItems.get(objTask.Id);
            //IBA-5055 Start Saptarsha Panthi
            if((objTask.Approved__c!=oldValueTask.Approved__c)&&(objTask.Approved__c==false)){
                objTask.Approved_Date__c=null;
            }
            //IBA-5055 End Saptarsha Panthi
            if(objTask.Original_Due_Date__c != oldValueTask.Original_Due_Date__c
               && assignedProfile[0].Name != 'System Administrator'
               && assignedProfile[0].Name != 'Business Administrator')
            {
                objTask.addError('Only Business Admins and System Administrators can update Original Due Date');              
            }
        }

        for (Task objTask : newList) {
            Task oldValueTask = (Task)oldItems.get(objTask.Id);
            if(objTask.WhatId != null && string.valueof(objTask.WhatId).startsWith('006'))
            {
                updateFieldofOpportunity(newList);
            }
        }        
    }
    
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems) {
        LeanData.LeanDataAPI.triggerRouting();
        List<Task> newTaskList = newItems.values();
        
        List<TaskHistory__c> insertTaskHistoryList = new List<TaskHistory__c>();
        
        for(Task t : newTaskList)
        {
            TaskHistory__c th = new TaskHistory__c();
            th.ParentId__c = t.id;
            th.User__c = userinfo.getUserId();
            th.Edit_Date_Time__c = datetime.now();
            th.Field_Name__c = 'Task Created';
            
            insertTaskHistoryList.add(th);
        }
        
        if(!insertTaskHistoryList.isEmpty())
            insert insertTaskHistoryList;
    }
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems) {
        List<Task> oldTaskList = oldItems.values();
        //SF-BUG-1004
        List<Profile> assignedProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = assignedProfile[0].Name;
        for (Task objTask : oldTaskList) {
            if(objTask.Activity_SubType__c == 'Follow-up on Marketing Campaign Contact/Lead'
               && profileName != 'System Administrator'
               && profileName != 'Business Administrator'
               && !profileName.startsWith('Marketing'))
            {
                objTask.addError('Only marketing users and admins can delete marketing followup tasks');              
            }
        }
    }
    
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems) {
        CreateTaskHistory.createTaskHistoryOnTaskUpdate((Map<Id, Task>)oldItems, (Map<Id, Task>)newItems);
        LeanData.LeanDataAPI.triggerRouting();
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems) {
        
    }
    
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems) {
        
    }
    
    // Method which updates checkbox on CampaignMember as true when task is assigned  to Lead/Contact Owner
    /*commented below method for SF-BUG-778 apex cpu limit exception by SRAVAN on 23 JAN
public void assignTasktoCampaignMember(List<Task> newTasks)
{          
// List<id> campaignids= new List<id>();

//List<id> WhoIds= new List<id>();
//System.Debug('newTasks : '+newTasks);
//System.Debug('size : '+newTasks.size());
Set<Id> campaignMemIdSet = new Set<Id>();
//Map <id, id> CampaignLeadmap = new Map<id, id>();
//Map<id,id> campmemmap = new Map<id,id>();
List<CampaignMember> updatecampaignmem= new List<CampaignMember>();

Id contactId;

Id leadId;
List<Id> memids = new List<Id>();
for(Task nt: newTasks){
//memids.add(nt.whoId);
//CampaignLeadmap.put(nt.Campaign__c,nt.whoId);//Haripriya : commented this line of code, to fix the issue that campaignmember of Type Lead, Task Assigned checkbox is not been checked
System.Debug('nt.CampaignMember_Id__c : '+nt.CampaignMember_Id__c);
campaignMemIdSet.add(nt.CampaignMember_Id__c);
//campmemmap.put(nt.WhoId,nt.WhoId);
//System.Debug('CampaignLeadmap : '+CampaignLeadmap);
//System.Debug('campmemmap : '+campmemmap);
System.debug('Campaign is' +nt.Campaign__c);
System.debug('Whoid is' +nt.whoId);
}
List<CampaignMember> campaignMemberlist=[SELECT Id, CampaignId, LeadId, ContactId, Status, Name, FirstName, LeadOrContactId, LeadOrContactOwnerId, Task_Assigned__c FROM CampaignMember where Id IN: campaignMemIdSet];
if (campaignMemberlist.size()>0)
{
for(CampaignMember cm: campaignMemberlist){
cm.Task_Assigned__c= true;
updatecampaignmem.add(cm);
}
}
update updatecampaignmem;
}*/
    //Added for SF-BUG-758
    public void taskCompleted(List <Task> t) {
        for(Task tsk : t) {
            if(tsk.status == 'Completed') {
                if(tsk.Completed_Date__c == null) {
                    tsk.Completed_Date__c = system.now();
                }else {
                    System.debug('do nothing...');
                }
                
            }else {
                tsk.Completed_Date__c = null;
            }
        }
        
    } 
    
    //Added for SF-BUG-989
    public void setOriginalDueDate(List <Task> taskList) {
        for(Task objTask : taskList) {
            if(objTask.ActivityDate != null)
                objTask.Original_Due_Date__c = objTask.ActivityDate;
        }
        
    } 
    //Added for SF-BUG-990
    //Updated for IBA-2404
    public void updateFields(List <Task> t) {
        List<ID> contactId = new List<ID>();
        List<ID> accId = new List<ID>();
        for(Task tsk : t) {
            if(tsk.WhoId != null) {
                String objType = getSobjectNameById(tsk.WhoId);
                System.debug('objType...' +objType);
                if(objType == 'Contact') {
                   contactId.add(tsk.WhoId);
                }
            }
        }
        if(contactId.size()>0) {
            List<Contact> con = [Select id,AccountId,toLabel(Omnicell_Job_Code__c),Classification__c from Contact where id IN : contactId];
            System.debug('testing...1' +con);
            for(Contact c : con) {
                if(c.AccountId != null){
                    accId.add(c.AccountId);
                }
            }
            List<Account> acc = [Select id,Facility_Type__c,Name from Account where id IN : accId];
            Map<ID,Account> mp = new Map<ID,Account>();
            Map<ID,Contact> mp1 = new Map<ID,Contact>();
            for(Contact c: con) {
                mp1.put(c.id,c);
                for(Account a : acc) {
                    if(c.AccountId == a.id) {
                        mp.put(c.Id,a);
                    }
                }
            }
            System.debug('testing...' +acc);
            for(Task tsk : t) {
                Account value;
                Contact value1;
                if(mp.containsKey(tsk.WhoId)){
                    value = mp.get(tsk.WhoId);
                }
                if(mp1.containsKey(tsk.WhoId)){
                    value1 = mp1.get(tsk.WhoId);
                }
                if(value != null){
                    tsk.Account_Name__c = value.Name;
                    if(value.Facility_Type__c != null){
                        tsk.Facility_Type__c = value.Facility_Type__c;
                    }
                }
                if(value1 != null){
                    if( value1.Classification__c != null){
                        tsk.Classification__c = value1.Classification__c;
                    }
                    if(value1.Omnicell_Job_Code__c != null){
                        tsk.Omnicell_Job_Title__c = value1.Omnicell_Job_Code__c;
                    }
                }
            }
        }
    }
    //IBA-1919 Start Abhrajit
    public void updateFieldofOpportunity(List <Task> t) {
        OpportunityTriggerHandler.TriggerDisabled = true;
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Opportunity> mapOpptnty = new Map<Id,Opportunity>();
        List<Profile> assignedProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        for (Task tsk : t) {
            if (tsk.WhatId != null && string.valueof(tsk.WhatId).startsWith('006') ) {
                oppIds.add(tsk.WhatId);
            }
        }
        if(!oppIds.isEmpty()){
            for(Opportunity opp:[SELECT Id,Activity_Last_Completed_Date__c FROM Opportunity WHERE Id IN : oppIds]){
                mapOpptnty.put(opp.Id,opp);
            }
        }
        for (Task tsk : t) {
            if (tsk.WhatId != null && tsk.Completed_Date__c != null && (assignedProfile[0].Name != 'System Administrator' && assignedProfile[0].Name != 'Business Administrator')) {
                Opportunity opp = mapOpptnty.get(tsk.WhatId);
                opp.Activity_Last_Completed_Date__c = tsk.Completed_Date__c.date();
                mapOpptnty.put(opp.Id,opp);
            }
        }
        System.debug('test' +mapOpptnty);
        if(mapOpptnty.values().size() > 0){
        update mapOpptnty.values();
        } 
    } //IBA-1919 End Abhrajit
    //Added for SF-BUG-990
    public static String getSobjectNameById(Id inputId)
    {
        Schema.SObjectType sobjectType = inputId.getSObjectType();
        return sobjectType.getDescribe().getName();
    }
    public static void validationCheckDeletedAccountOrNotSoldTo(List<Task> newList){ // Added for IBA-2344
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales-NA').getRecordTypeId();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Set<Id> accIds = new Set<Id>();
        for(Task tsk :newList){
            if(tsk.WhatId != Null){
            String objType = getSobjectNameById(tsk.WhatId); 
            if(objType == 'Account'){
                accIds.add(tsk.WhatId);
            }
            }
        }
        Map<ID,Account> accList = new Map<ID,Account>([Select Id,IsDeleted__c,Account_Role__c From Account Where Id IN :accIds]);
        for(Task tsk :newList){
            if(tsk.WhatId != Null){
            if(tsk.RecordTypeId == taskRecordTypeId){
                String objType = getSobjectNameById(tsk.WhatId); 
                if(objType == 'Account'){
                    Account ac = accList.get(tsk.WhatId);
                    
                        if(ac.IsDeleted__c == True){
                            tsk.addError('A task cannot be created on an inactive account. Please find an account where IsDeleted is not checked.');
                        }
                        else if(ac.Account_Role__c != 'ZCSN'){
                            tsk.addError('A task cannot be created on a non Sold To account. ');
                        }
                }
            }
            }
        }
    }
}