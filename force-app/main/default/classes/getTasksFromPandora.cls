public class getTasksFromPandora 
{
    @future(callout=true)
    public static void getTasks()
    {
        Map<String,String> resMap = getContactsFromPandoraBatch.calloutPandoraAuth();  
        String fields = 'Id,WhoId,WhatId,Subject,Status,Priority,IsHighPriority,Description,Type,AccountId,CallDurationInSeconds,CallType,CallDisposition,CallObject,ReminderDateTime,IsReminderSet,RecurrenceActivityId,IsRecurrence,RecurrenceStartDateOnly,RecurrenceEndDateOnly,RecurrenceTimeZoneSidKey,RecurrenceType,RecurrenceInterval,RecurrenceDayOfWeekMask,RecurrenceDayOfMonth,RecurrenceInstance,RecurrenceMonthOfYear,RecurrenceRegeneratedType,TaskSubtype,CompletedDateTime';
        String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+'+fields+'+from+Task+where+whatId+not+in+(select+id+from+opportunity)';
        
        String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
        system.debug('Tasks jsonResponse-->'+jsonResponse);
        taskWrapper wrapperList = (taskWrapper) JSON.deserialize(jsonResponse,taskWrapper.Class);
        system.debug('Tasks wrapperList->'+wrapperList.records.size());
        
        List<Task> insertTaskList = New List<Task>();
        Id taskPandoraRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pandora').getRecordTypeId();
        for(Task taskObj : wrapperList.records)
        {
            system.debug('taskObj.Id-->'+taskObj.Id);
            
            String tempWhoId = taskObj.whoId;
            String tempWhatId = taskObj.whatId;
            
            taskObj.whoId = null;
            taskObj.whatId = null;
            taskObj.recordtypeId = taskPandoraRecTypeId;
            taskObj.Legacy_Pandora_Id__c = taskObj.Id;
            taskObj.Id = null;
            
            insertTaskList.add(taskObj);
        }
        
        system.debug('insertTaskList-->'+insertTaskList.size()+':::'+insertTaskList);
        if(!insertTaskList.isEmpty())
        {
            insert insertTaskList;
        }
    }
    
    public class taskWrapper
    {
        public List<Task> records;
    }
    
}