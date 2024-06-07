global class marginDeleteQLAverageBatch implements Database.Batchable<SObject>{
    global Database.queryLocator start(Database.BatchableContext bc){
        Date dt = Date.newInstance(2999, 12, 31);
        return Database.getQueryLocator('Select id, Name from Quote_line_average__c where valid_to__c = :dt');

    }
    global void execute (Database.BatchableContext BC, List<Quote_line_average__c> qlAvgList){
        List<Quote_line_average__c> avgLinesToUpdate = new List<Quote_line_average__c>();
        Date yesterdayDate = Date.today()-1;
        for(Quote_line_average__c average:qlAvgList){
            Quote_line_average__c avg = new Quote_line_average__c(id=average.id);
            avg.Valid_To__c = yesterdayDate;
            avgLinesToUpdate.add(avg);
        }
        if(!avgLinesToUpdate.isEmpty()){
            update avgLinesToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC){
            database.executebatch(new marginQLAverage(),50);
    }
}