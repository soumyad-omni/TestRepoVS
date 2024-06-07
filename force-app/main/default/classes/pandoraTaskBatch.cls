global class pandoraTaskBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        String query = 'SELECT id, Legacy_Pandora_Id__c FROM Task WHERE Legacy_Pandora_Id__c <> NULL';
        //String query = 'SELECT id, Legacy_Pandora_Id__c FROM Task WHERE Legacy_Pandora_Id__c = \'00T30000004eSSKEA2\'';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> tskList)
    {
        String pandoraIds = '(';
        Map<Id, Id> pandoraIdMap = New Map<Id, Id>();
        for(Task tsk : tskList)
        {
            pandoraIdMap.put(tsk.Legacy_Pandora_Id__c, tsk.Id);
            pandoraIds = pandoraIds + '\'' + tsk.Legacy_Pandora_Id__c + '\',';
        }
        system.debug('pandoraIdMap-->'+pandoraIdMap);
        
        pandoraIds = pandoraIds.removeEnd(',');
        pandoraIds += ')';
        system.debug('pandoraIds-->'+pandoraIds);
        
        Map<String,String> resMap = getContactsFromPandoraBatch.calloutPandoraAuth();  
        String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+Id,WhoId,WhatId+from+Task+where+Id+in+'+pandoraIds;
        
        String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
        system.debug('Tasks jsonResponse-->'+jsonResponse);
        taskWrapper wrapperList = (taskWrapper) JSON.deserialize(jsonResponse,taskWrapper.Class);
        system.debug('Tasks wrapperList->'+wrapperList.records.size());
        Map<Id, Id> existingCaseId = New Map<Id, Id>();
        Map<String, Id> omnicellAccountMap = New Map<String, Id>();
        String contactIds = '(', accountIds = '(';
        List<String> caseIds = New List<String>();
        Map<Id, String> csnList = New Map<Id, String>();
        
        Map<String, String> contNameMap = New Map<String, String>();
        Map<String, String> contEmailMap = New Map<String, String>();
        Map<String, String> contPhoneMap = New Map<String, String>();
        Map<String, String> omnicellContNameMap = New Map<String, String>();
        Map<String, String> omnicellContEmailMap = New Map<String, String>();
        Map<String, String> omnicellContPhoneMap = New Map<String, String>();        
        
        for(Task taskObj : wrapperList.records)
        {
            system.debug('taskObj.Id-->'+taskObj.Id);
            if(taskObj.whoId <> NULL)
            {
                contactIds = contactIds + '\'' + taskObj.whoId + '\',';
            }
            
            if(taskObj.accountId <> NULL)
            {
                accountIds = accountIds + '\'' + taskObj.accountId + '\',';
            }
            
            if(taskObj.whatId <> NULL && String.ValueOf(taskObj.whatId).startswith('001'))
            {
                accountIds = accountIds + '\'' + taskObj.whatId + '\',';
            }
            
            if(taskObj.whatId <> NULL && String.ValueOf(taskObj.whatId).startswith('500'))
            {
                caseIds.add(taskObj.whatId);
            }
        }
        system.debug('caseIds-->'+caseIds);
        
        contactIds = contactIds.removeEnd(',');
        contactIds += ')';
        system.debug('contactIds-->'+contactIds);
        
        accountIds = accountIds.removeEnd(',');
        accountIds += ')';
        system.debug('accountIds-->'+accountIds);
        
        for(Case cs : [SELECT id, Legacy_Pandora_Id__c FROM Case
                       WHERE Legacy_Pandora_Id__c IN :caseIds])
        {
            existingCaseId.put(cs.Legacy_Pandora_Id__c, cs.Id);
        }
        
        if(accountIds <> '()')
        {
            endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+id,CSN__C+from+Account+where+Id+in+'+accountIds;
            
            String accJSONResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
            system.debug('Account accJSONResponse-->'+accJSONResponse);
            accJSONResponse = accJSONResponse.replace('CSN__c','SAP_Customer_Number__c');
            
            accountWrapper accWrapperList = (accountWrapper) JSON.deserialize(accJSONResponse,accountWrapper.Class);
            system.debug('Account accWrapperList->'+accWrapperList.records.size());
            
            for(Account acc : accWrapperList.records)
            {
                system.debug('acc.Id-->'+acc.Id+':::'+acc);
                if(acc.SAP_Customer_Number__c <> NULL && acc.SAP_Customer_Number__c <> '')
                {
                    csnList.put(acc.Id, String.valueOf((Integer.valueOf(acc.SAP_Customer_Number__c))));
                }
            }
            system.debug('csnList-->'+csnList);
            for(Account acc : [SELECT id, SAP_Customer_Number__c FROM Account
                               WHERE SAP_Customer_Number__c IN :csnList.values()])
            {
                omnicellAccountMap.put(acc.SAP_Customer_Number__c, acc.Id);
            }
        }
        
        if(contactIds <> '()')
        {
            endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+id,name,firstname,lastname,phone,email+from+contact+where+Id+IN+'+contactIds;
            
            String contJSONResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
            system.debug('Contact contJSONResponse-->'+contJSONResponse);
            
            contactWrapper contWrapperList = (contactWrapper) JSON.deserialize(contJSONResponse,contactWrapper.Class);
            system.debug('Contact contWrapperList->'+contWrapperList.records.size());
            
            for(Contact con : contWrapperList.records)
            {
                if(con.Name <> NULL && con.Name <>'')
                    contNameMap.put(con.Id, con.Name);
                if(con.Email <> NULL && con.Email <>'')
                    contEmailMap.put(con.Id, con.Email);
                if(con.Phone <> NULL && con.Phone <>'')
                    contPhoneMap.put(con.Id, con.Phone);
            }
            
            List<Contact> omnicellContacts = [SELECT id, Name, Email, Phone
                                              FROM contact 
                                              WHERE Name IN :contNameMap.values()
                                              OR Email IN :contEmailMap.values()
                                              OR Phone IN :contPhoneMap.values()];
            
            for(Contact con : omnicellContacts)
            {
                if(con.Name <> NULL && con.Name <>'')
                    omnicellContNameMap.put(con.Name, con.Id);
                if(con.Email <> NULL && con.Email <>'')
                    omnicellContEmailMap.put(con.Email, con.Id);
                if(con.Phone <> NULL && con.Phone <>'')
                    omnicellContPhoneMap.put(con.Phone, con.Id);
            }
        }
        List<Task> updateTaskList = New List<Task>();
        Id taskPandoraRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pandora').getRecordTypeId();
        for(Task taskObj : wrapperList.records)
        {
            system.debug('taskObj.Id-->'+taskObj.Id);
            
            String tempWhoId = taskObj.whoId;
            String tempWhatId = taskObj.whatId;
            
            taskObj.whoId = null;
            taskObj.whatId = null;
            taskObj.Id = pandoraIdMap.get(taskObj.Id);

            if(tempWhoId <> NULL)
            {
                if(contNameMap.containsKey(tempWhoId) && omnicellContNameMap.containsKey(contNameMap.get(tempWhoId)))
                {
                    taskObj.whoId = omnicellContNameMap.get(contNameMap.get(tempWhoId));
                }
                else if(contEmailMap.containsKey(tempWhoId) && omnicellContEmailMap.containsKey(contEmailMap.get(tempWhoId)))
                {
                    taskObj.whoId = omnicellContEmailMap.get(contEmailMap.get(tempWhoId));
                }
                else if(contPhoneMap.containsKey(tempWhoId) && omnicellContPhoneMap.containsKey(contPhoneMap.get(tempWhoId)))
                {
                    taskObj.whoId = omnicellContPhoneMap.get(contPhoneMap.get(tempWhoId));
                }
            }
            
            if(tempWhatId <> NULL)
            {
                if(csnList.containsKey(tempWhatId) && omnicellAccountMap.containsKey(csnList.get(tempWhatId)))
                {
                   taskObj.whatId = omnicellAccountMap.get(csnList.get(tempWhatId));
                }
                else if(existingCaseId.containsKey(tempWhatId))
                {
                    taskObj.whatId = existingCaseId.get(tempWhatId);
                }
            }
            
            updateTaskList.add(taskObj);
        }
        
        system.debug('updateTaskList-->'+updateTaskList.size()+':::'+updateTaskList);
        if(!updateTaskList.isEmpty())
        {
            update updateTaskList;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
    
    public class taskWrapper
    {
        public List<Task> records;
    }
    
    public class accountWrapper
    {
        public List<Account> records;
    }

    public class contactWrapper
    {
        public List<Contact> records;
    }
}