global class ResetCurrentQLProcessFlag implements Database.Batchable<SObject>{
    global Database.queryLocator start(Database.BatchableContext bc)
    {
            return Database.getQueryLocator('Select id, Is_Processed__c from Current_Quote_Line_Result__c where Is_Processed__c=true');
    }
    
    global void execute (Database.BatchableContext BC, List<Current_Quote_Line_Result__c> cqlrList)
    {
        for(Current_Quote_Line_Result__c cqlr : cqlrList){
            cqlr.Is_Processed__c = false;
        }
        
        update cqlrList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}