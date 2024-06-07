global class verifyEmailBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.isRunningTest()){
            return Database.getQueryLocator([select id from user where IsActive =true and ContactId = '' limit 1]);
        }else{
            return Database.getQueryLocator([select id from user where IsActive =true and ContactId = '']);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<user> userIds) {
        for(User userId : userIds) { 
            if(!Test.isRunningTest())
            System.UserManagement.sendAsyncEmailConfirmation(userId.id, null, null, null);
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
}