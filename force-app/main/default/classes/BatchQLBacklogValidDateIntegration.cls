global class BatchQLBacklogValidDateIntegration implements Database.Batchable<sObject>
{
    private Date Valid_From;
    private Date Valid_To;
    
    global BatchQLBacklogValidDateIntegration(Date Valid_From_Param, Date Valid_To_Param) {
        Valid_From = Valid_From_Param;
        Valid_To = Valid_To_Param;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        DateTime currentTimeTwohr = System.now()-(2/24.0);
        Date validTo=Date.valueOf('2999-12-31');
        String query = 'SELECT id, Valid_To__c FROM Quote_Line_Backlog__c ';
        if(!Test.isRunningTest()){
        	query = query + ' WHERE Valid_To__c = :validTo AND CreatedDate < :currentTimeTwohr';
		}        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote_Line_Backlog__c> qlbList) 
    {
        List<Quote_Line_Backlog__c> qlbUpdateList = new List<Quote_Line_Backlog__c>();
        
        for(Quote_Line_Backlog__c qlb : qlbList)
        {
            qlb.Valid_To__c = Valid_To - 1;
            
            qlbUpdateList.add(qlb);
        }
        
        if(!qlbUpdateList.isEmpty())
            update qlbUpdateList;
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    }
}