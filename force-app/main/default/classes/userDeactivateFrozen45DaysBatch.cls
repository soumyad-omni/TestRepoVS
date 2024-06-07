//Test Class: userDeactivateFrozen45DaysBatchTest
global class userDeactivateFrozen45DaysBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private String failedUsers = '\n';
    private Integer userCount = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime fortyFiveDaysOldDate = datetime.now();
        if(!test.isRunningTest())
            fortyFiveDaysOldDate = fortyFiveDaysOldDate.addDays(-45);
        
        String query = 'SELECT id, isActive, userName, firstName, lastName FROM user';
        query = query + ' WHERE id IN (SELECT UserId FROM userlogin WHERE isfrozen = true AND LastModifiedDate <= : fortyFiveDaysOldDate)';
        query = query + ' AND Do_not_deactivate__c = FALSE';
        query = query + ' AND isActive = TRUE';
        query = query + ' AND profile.name <> \'Omnicell B2B Storefront Profile\'';
        
        if(test.isRunningTest())
            query = query + ' LIMIT 1';
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> usrList) 
    {
        try
        {
            for(User usr : usrList)
            {
                system.debug('usr-->'+usr);
                usr.isActive = false;
            }
            
            System.enqueueJob(new userDeactivateFrozen45DaysQueueable(usrList));  
            
            //update usrList;
        }
        catch(Exception ex)
        {
            userCount = userCount + 1;
            system.debug('ex-->'+ex);
            system.debug('ex.getMessage()-->'+ex.getMessage());
            failedUsers = failedUsers + userCount + '.' + usrList + '\t ***Error: ' + ex.getMessage() +'\n';
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('userCount-->'+userCount);
        system.debug('finish-->'+failedUsers);
        if(userCount > 0 || test.isRunningTest())
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            //Add all System Admin
            List<String> sendTo = new List<String>(system.label.Email_Address_for_Deactivate_Issue.split(','));
            
            email.setSubject('Unable to deactivate users');
            email.setToAddresses(sendTo);
            email.setPlainTextBody('Below users were not deactivated.\n'+failedUsers);
            if(!test.isRunningTest())
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        }
    }
    
    global void execute(SchedulableContext sc)
    {
        database.executeBatch(new userDeactivateFrozen45DaysBatch(),1);
    }
}