public class CreateTaskHistory {
    
    public static void createTaskHistoryOnTaskUpdate(Map<id,Task> oldMap,Map<Id,Task> newMap)
    {
        List<TaskHistory__c> insertTaskHistory = new List<TaskHistory__c>();
        
        for(Task tsk : newMap.values())
        {
            
            if(tsk.Account_Name__c <> oldMap.get(tsk.id).Account_Name__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Account_Name__c'),tsk.Account_Name__c ,oldMap.get(tsk.id).Account_Name__c));
            }
            if(tsk.Activity_SubType__c <> oldMap.get(tsk.id).Activity_SubType__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Activity_SubType__c') ,tsk.Activity_SubType__c, oldMap.get(tsk.id).Activity_SubType__c));
            }
            if(tsk.Activity_Type__c <> oldMap.get(tsk.id).Activity_Type__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Activity_Type__c'), tsk.Activity_Type__c, oldMap.get(tsk.id).Activity_Type__c));
            }
            if(tsk.Approved__c <> oldMap.get(tsk.id).Approved__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Approved__c'), booleanToString(tsk.Approved__c), booleanToString(oldMap.get(tsk.id).Approved__c)));
            }
            if(tsk.Approved_Date__c <> oldMap.get(tsk.id).Approved_Date__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Approved_Date__c'), convertDateTime(tsk.Approved_Date__c), convertDateTime(oldMap.get(tsk.id).Approved_Date__c)));
            }
            if(tsk.Campaign_Name_Formula__c <> oldMap.get(tsk.id).Campaign_Name_Formula__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Campaign_Name_Formula__c'), tsk.Campaign_Name_Formula__c, oldMap.get(tsk.id).Campaign_Name_Formula__c));
            }
        /*    if(tsk.Campaign_Task_Type__c <> oldMap.get(tsk.id).Campaign_Task_Type__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Campaign_Task_Type__c'), tsk.Campaign_Task_Type__c, oldMap.get(tsk.id).Campaign_Task_Type__c));
            }    IBA-4524*/
            if(tsk.Cancelled_Date2__c <> oldMap.get(tsk.id).Cancelled_Date2__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Cancelled_Date2__c'), convertDate(tsk.Cancelled_Date2__c), convertDate(oldMap.get(tsk.id).Cancelled_Date2__c)));
            }
            if(tsk.Completed_Date__c <> oldMap.get(tsk.id).Completed_Date__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Completed_Date__c'), convertDateTime(tsk.Completed_Date__c), convertDateTime(oldMap.get(tsk.id).Completed_Date__c)));
            }
            if(tsk.ActivityDate <> oldMap.get(tsk.id).ActivityDate)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('ActivityDate'), convertDate(tsk.ActivityDate), convertDate(oldMap.get(tsk.id).ActivityDate)));
            }
            if(tsk.ActivityDate__c <> oldMap.get(tsk.id).ActivityDate__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('ActivityDate__c'), convertDateTime(tsk.ActivityDate__c), convertDateTime(oldMap.get(tsk.id).ActivityDate__c)));
            }
        /*    if(tsk.EndDateTime__c <> oldMap.get(tsk.id).EndDateTime__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('EndDateTime__c'), convertDateTime(tsk.EndDateTime__c), convertDateTime(oldMap.get(tsk.id).EndDateTime__c)));
            }      IBA-4524*/
            if(tsk.End_Date_Time__c <> oldMap.get(tsk.id).End_Date_Time__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('End_Date_Time__c'), convertDateTime(tsk.End_Date_Time__c), convertDateTime(oldMap.get(tsk.id).End_Date_Time__c)));
            }
            if(tsk.Follow_up_Result__c <> oldMap.get(tsk.id).Follow_up_Result__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Follow_up_Result__c'), tsk.Follow_up_Result__c, oldMap.get(tsk.id).Follow_up_Result__c));
            }
            if(tsk.Follow_up_Tasks_Notes__c <> oldMap.get(tsk.id).Follow_up_Tasks_Notes__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Follow_up_Tasks_Notes__c'), tsk.Follow_up_Tasks_Notes__c, oldMap.get(tsk.id).Follow_up_Tasks_Notes__c));
            }
            if(tsk.Omnicell_Involvement__c <> oldMap.get(tsk.id).Omnicell_Involvement__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Omnicell_Involvement__c'), tsk.Omnicell_Involvement__c, oldMap.get(tsk.id).Omnicell_Involvement__c));
            }
            if(tsk.Original_Due_Date__c <> oldMap.get(tsk.id).Original_Due_Date__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Original_Due_Date__c'), convertDate(tsk.Original_Due_Date__c), convertDate(oldMap.get(tsk.id).Original_Due_Date__c)));
            }
            if(tsk.Campaign_Name__c <> oldMap.get(tsk.id).Campaign_Name__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Campaign_Name__c'), tsk.Campaign_Name__c, oldMap.get(tsk.id).Campaign_Name__c));
            }
          /*  if(tsk.Reference_Site_Name__c <> oldMap.get(tsk.id).Reference_Site_Name__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Reference_Site_Name__c'), tsk.Reference_Site_Name__c, oldMap.get(tsk.id).Reference_Site_Name__c));
            }   IBA-4524*/
            if(tsk.Interested_Products__c <> oldMap.get(tsk.id).Interested_Products__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Interested_Products__c'), tsk.Interested_Products__c, oldMap.get(tsk.id).Interested_Products__c));
            }
         /*   if(tsk.Reminder_Date_Time__c <> oldMap.get(tsk.id).Reminder_Date_Time__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Reminder_Date_Time__c'), convertDateTime(tsk.Reminder_Date_Time__c), convertDateTime(oldMap.get(tsk.id).Reminder_Date_Time__c)));
            }
            if(tsk.IsReminderSet__c <> oldMap.get(tsk.id).IsReminderSet__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('IsReminderSet__c'), booleanToString(tsk.IsReminderSet__c), booleanToString(oldMap.get(tsk.id).IsReminderSet__c)));
            }    IBA-4524*/
            
           /*      if(tsk.StartDateTime__c <> oldMap.get(tsk.id).StartDateTime__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('StartDateTime__c'), convertDateTime(tsk.StartDateTime__c), convertDateTime(oldMap.get(tsk.id).StartDateTime__c)));
            }      IBA-4524*/
            if(tsk.Start_Date_Time__c <> oldMap.get(tsk.id).Start_Date_Time__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Start_Date_Time__c'), convertDateTime(tsk.Start_Date_Time__c), convertDateTime(oldMap.get(tsk.id).Start_Date_Time__c)));
            }
           /*   if(tsk.Was_the_desired_Outcome_Achieved__c <> oldMap.get(tsk.id).Was_the_desired_Outcome_Achieved__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Was_the_desired_Outcome_Achieved__c'), tsk.Was_the_desired_Outcome_Achieved__c, oldMap.get(tsk.id).Was_the_desired_Outcome_Achieved__c));
            }       IBA-4524*/
            if(tsk.Assigned_To_Full_Name__c <> oldMap.get(tsk.id).Assigned_To_Full_Name__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Assigned_To_Full_Name__c'), tsk.Assigned_To_Full_Name__c, oldMap.get(tsk.id).Assigned_To_Full_Name__c));
            }
            if(tsk.Description <> oldMap.get(tsk.id).Description)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Description'), tsk.Description, oldMap.get(tsk.id).Description));
            }
            if(tsk.CompletedDateTime <> oldMap.get(tsk.id).CompletedDateTime)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('CompletedDateTime'), convertDateTime(tsk.CompletedDateTime), convertDateTime(oldMap.get(tsk.id).CompletedDateTime)));
            }
            if(tsk.ActivityDate <> oldMap.get(tsk.id).ActivityDate)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('ActivityDate'), convertDate(tsk.ActivityDate), convertDate(oldMap.get(tsk.id).ActivityDate)));
            }
            if(tsk.WhoId <> oldMap.get(tsk.id).WhoId)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('WhoId'), tsk.WhoId, oldMap.get(tsk.id).WhoId));
            }
            if(tsk.Priority <> oldMap.get(tsk.id).Priority)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Priority'), tsk.Priority, oldMap.get(tsk.id).Priority));
            }
            if(tsk.WhatId <> oldMap.get(tsk.id).WhatId)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('WhatId'), tsk.WhatId, oldMap.get(tsk.id).WhatId));
            }
            if(tsk.Status <> oldMap.get(tsk.id).Status)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Status'), tsk.Status, oldMap.get(tsk.id).Status));
            }
             if(tsk.Subject <> oldMap.get(tsk.id).Subject)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Subject'), tsk.Subject, oldMap.get(tsk.id).Subject));
            }
             if(tsk.RecordTypeId <> oldMap.get(tsk.id).RecordTypeId)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('RecordTypeId'), tsk.RecordTypeId, oldMap.get(tsk.id).RecordTypeId));
            }
            if(tsk.TaskSubtype <> oldMap.get(tsk.id).TaskSubtype)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('TaskSubtype'), tsk.TaskSubtype, oldMap.get(tsk.id).TaskSubtype));
            }
       /*     if(tsk.Activity_System_ID__c <> oldMap.get(tsk.id).Activity_System_ID__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Activity_System_ID__c'), tsk.Activity_System_ID__c, oldMap.get(tsk.id).Activity_System_ID__c));
            }    IBA-4524*/
            if(tsk.Cancel_Date__c <> oldMap.get(tsk.id).Cancel_Date__c)
            {
                insertTaskHistory.add(createTaskHistoryInstanceObject(tsk.id,getFieldName('Cancel_Date__c'), convertDate(tsk.Cancel_Date__c), convertDate(oldMap.get(tsk.id).Cancel_Date__c)));
            }
        }
        
        if(insertTaskHistory.size() > 0)
            insert insertTaskHistory;
    }
    
    public static String booleanToString(Boolean var)
    {
        if(var)
            return 'true';
        else
            return 'false';
    }
    
    public static TaskHistory__c createTaskHistoryInstanceObject(Id tskId, String fieldName, String newValue, String oldValue)
    {
        TaskHistory__c th = new TaskHistory__c();
        th.ParentId__c = tskId;
        th.User__c = userinfo.getUserId();
        th.Edit_Date_Time__c = datetime.now();
        th.New_Value__c = newValue;
        th.Old_Value__c = oldValue;
        th.Field_Name__c = fieldName;
        system.debug('th-->'+th);
        return th;
    }
    
    @AuraEnabled 
    public static List<TaskHistory__c> getTaskHistory(String taskId)
    {
        List<TaskHistory__c> thList = new List<TaskHistory__c>();
        
        thList = [SELECT id, Edit_Date_Time__c, User__c, User__r.Name, New_Value__c, Old_Value__c, Field_Name__c 
                  FROM TaskHistory__c 
                  WHERE ParentId__c = :taskId
                 ORDER BY createddate DESC];

        return thList;
    }
    
    public static String getFieldName(String fieldAPIName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Task');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
    
        return fieldMap.get(fieldAPIName).getDescribe().getLabel();
    }
    
    public static String convertDateTime(DateTime dt)
    {
        system.debug('dt->'+dt);
        if(dt == null)
            return null;
        else
            return dt.format('MM/dd/yyyy hh:mm a', 'PST') + ' PST';
    }
    
    public static String convertDate(Date d)
    {
        system.debug('d->'+d);
        if(d == null)
            return null;
        else
            return d.format();
    }
}