global class UpdatePLBatchScheduler {
   
    @AuraEnabled
    global static Boolean startPLcalc(){
        Run_Product_line_Update__c rpl = [select id,Run_Product_line_Update__c from Run_Product_line_Update__c where name = 'Run Product line Update'];
        if(rpl.Run_Product_line_Update__c == true){
            UpdatePLBatch s = new UpdatePLBatch();
        	DataBase.executeBatch(s,10);
        }
        return true;
    }
}