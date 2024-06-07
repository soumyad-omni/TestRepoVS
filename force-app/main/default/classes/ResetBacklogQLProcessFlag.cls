global class ResetBacklogQLProcessFlag implements Database.Batchable<SObject>{
    global Database.queryLocator start(Database.BatchableContext bc)
    {
            return Database.getQueryLocator('Select id, Is_Processed__c from Quote_Line_Backlog__c where Is_Processed__c=true');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote_Line_Backlog__c> qlbList)
    {
        for(Quote_Line_Backlog__c qlb : qlbList){
            qlb.Is_Processed__c = false;
        }
        
        update qlbList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        database.executebatch(new ResetForecastDimensionProcessedFlagJob(),200);
    }
}