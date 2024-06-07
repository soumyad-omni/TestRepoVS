global class deleteCases implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id  FROM task where RecordType.name = \'Pandora\'';
        //String query = 'select id,name,parentId from attachment where parentId IN (select id from case)';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> caseList)
    {
        /*
        for(Case cs : caseList)
        {
            cs.Migration_from_Pandora_Completed__c = FALSE;
        }
        
        update caseList;*/
        delete caseList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}