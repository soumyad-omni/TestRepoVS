global class MarginQLReportsScheduleJob implements Database.Batchable<SObject>, schedulable{
    global Database.queryLocator start(Database.BatchableContext bc){
        Date dt = Date.newInstance(2999, 12, 31);
            return Database.getQueryLocator('Select id, Name,Valid_To__c from Current_Quote_Line_Result__c where valid_to__c = :dt');

    }
    global void execute (Database.BatchableContext BC, List<Current_Quote_Line_Result__c> oppBacklogResult){
        //Delete Average QL Object Data also here.
        Date yesterdayDate = Date.today()-1;
        List<Current_Quote_Line_Result__c> resultsToUpdate = new List<Current_Quote_Line_Result__c>();
        for(Current_Quote_Line_Result__c line:oppBacklogResult){
            Current_Quote_Line_Result__c updateLine = new Current_Quote_Line_Result__c(id=line.id);
            updateLine.Valid_To__c = yesterdayDate;
            resultsToUpdate.add(updateLine);
        }
        if(!resultsToUpdate.isEmpty()){
            update resultsToUpdate;
        }
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new MarginQLReportsScheduleJob());
    }
    
    global void finish(Database.BatchableContext BC){
            //database.executebatch(new marginQLDevelopmentSchedulableBatch(),200);
            database.executebatch(new marginCurrentQLBatch(),5000);
    }
}