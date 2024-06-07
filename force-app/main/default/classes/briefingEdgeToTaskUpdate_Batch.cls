Global class briefingEdgeToTaskUpdate_Batch implements Database.Batchable<sObject> {
		global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select id,briefingedge__End_Date__c,briefingedge__Start_Date__c,briefingedge__Visit_Staus__c From briefingedge__Briefing_Center_Visit__c Where LastModifiedDate = YESTERDAY';
            if(Test.isRunningTest()){ 
                query = 'Select id,briefingedge__End_Date__c,briefingedge__Start_Date__c,briefingedge__Visit_Staus__c From briefingedge__Briefing_Center_Visit__c Where LastModifiedDate = TODAY';
            }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<briefingedge__Briefing_Center_Visit__c> bcvList){
        List<Task> taskListmain = new List<Task>();
        for(briefingedge__Briefing_Center_Visit__c bcv : bcvList){
        	List<Task> tasklist = [Select id,Status,ActivityDate From Task Where Briefing_Center_ID__c = :bcv.id];
            if(tasklist.size()>0){
                for(Task tk : tasklist){
                    if(bcv.briefingedge__Visit_Staus__c == 'Cancelled'){
                        tk.Status = 'Cancelled';
                    }
                    else if(tk.ActivityDate != convDateTime(bcv.briefingedge__End_Date__c)){
                        tk.ActivityDate = convDateTime(bcv.briefingedge__End_Date__c);
                    }
                }
            	taskListmain.addAll(tasklist);
        	}
        }
            If(taskListmain.size()>0){
            try{                
                TaskTriggerHandler.TriggerDisabled = true;
                update taskListmain;
                System.debug('***'+taskListmain);
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: '+e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext bc){}
    public static Date convDateTime(DateTime dT){
        Date acdate = date.newinstance(dT.year(), dT.month(), dT.day());
        return acdate;
    }
}