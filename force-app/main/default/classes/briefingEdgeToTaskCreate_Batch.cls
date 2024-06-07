Global class briefingEdgeToTaskCreate_Batch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select id,briefingedge__End_Date__c,briefingedge__Start_Date__c From briefingedge__Briefing_Center_Visit__c Where CreatedDate = YESTERDAY';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<briefingedge__Briefing_Center_Visit__c> bcvList){
        List<Task> taskList = new List<Task>();
        Map<String,Id> va_user = new Map<String,Id>();
        String subject = '';
        for(briefingedge__Briefing_Center_Visit__c bcv : bcvList){
            List<briefingedge__Opportunity_Visit__c> opvlist = [Select id,briefingedge__Opportunity__c From briefingedge__Opportunity_Visit__c Where briefingedge__Briefing_Center_Visit__c = :bcv.id AND briefingedge__Opportunity__c != Null AND briefingedge__Opportunity__c  != ''];
            List<briefingedge__Visit_Attendee__c> valist = [Select id,briefingedge__Internal_Attendee__c,briefingedge__Email__c From briefingedge__Visit_Attendee__c Where briefingedge__Briefing_Center_Visit__c = :bcv.id AND recordtype.name = 'Internal Attendee' AND briefingedge__Email__c != Null AND briefingedge__Email__c != ''];
            Set<String> email_list = new Set<String>();
            if(valist.size()>0){
                for(briefingedge__Visit_Attendee__c va: valist){
                    email_list.add(va.briefingedge__Email__c);
                }
                List<User> userlist = [Select id,email From User Where email IN :email_list];
                for(User us: userlist){
                    if(email_list.contains(us.email)){
                        va_user.put(us.email,us.Id);
                    }
                }
            }
            subject = [Select briefingedge__Picklist_Value__c From briefingedge__Visit_Details__c Where briefingedge__Briefing_Center_Visit__c = :bcv.id limit 1].briefingedge__Picklist_Value__c;
            if(opvlist.size()>0 && valist.size()>0 && (!va_user.isEmpty())){
                for(briefingedge__Opportunity_Visit__c opv : opvlist){
                        for(briefingedge__Visit_Attendee__c va : valist){
                            Task tk = new Task();
                            tk.WhatId = opv.briefingedge__Opportunity__c;
                            tk.RecordTypeId =[Select Id,SobjectType,Name From RecordType Where Name ='Sales-NA' AND SobjectType ='Task'  limit 1].Id;
                            tk.ActivityDate = convDateTime(bcv.briefingedge__End_Date__c);
                            tk.Activity_Type__c = 'Opportunity';
                            tk.Completed_Date__c = bcv.briefingedge__End_Date__c; //Added By Abhrajit IBA-1723
                            if(Subject != '' && Subject != null){
                            	tk.Subject = subject;    
                            }
                            tk.Priority = 'Normal';
                            tk.Status = 'Completed';
                            if(va_user.containskey(va.briefingedge__Email__c)){
                                tk.OwnerId = va_user.get(va.briefingedge__Email__c);
                            }
                            else{
                                continue;
                            }
                            tk.Activity_SubType__c = selectSubType(subject);
                            tk.Briefing_Center_ID__c = bcv.id;
                            taskList.add(tk);
                        }
                }
            }
        }
        If(taskList.size()>0){
            try{
                
                TaskTriggerHandler.TriggerDisabled = true;
                insert taskList;
                System.debug('***'+taskList);
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: '+e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
    public static String selectSubType(String sbj){
        String subject;
        if(sbj == 'Executive Briefing (VIRTUAL)'){
            subject = '10S Virtual Corporate Site Visit to Vendor’s HQ';
        }
        else if(sbj == 'Executive Briefing (ON-PREMISE)'){
            subject = '10S Corporate Site visit to Vendor\'s HQ';
        }
        else if(sbj == 'Product Demo (VIRTUAL)'){
            subject = '10S Virtual Technology Demonstration to End Users and Stakeholders';
        }
        else if(sbj == 'Product Demo (ON-PREMISE)'){
            subject = '10S Technology Demonstrations to end users and stakeholders';
        }
        
        return subject;
        
    }
    public static Date convDateTime(DateTime dT){
        Date acdate = date.newinstance(dT.year(), dT.month(), dT.day());
        return acdate;
    }

}