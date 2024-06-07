global class BCH_UpdateTopFlagInAccount implements Database.Batchable<sObject>{        
    
    global List<Target_Initiative__c> targetList;
    global String targetInitiativeName;
    public String query;
    public Set<String> targetInitiativeAccSet = new Set<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String includeList = '(\'';
        includeList += (targetInitiativeName + '\',\'');
        includeList = includeList.removeEnd('\',\'');
        includeList += '\')';       
        query = 'Select Id, Name, Segment__c, Parent.Segment__c from Account where Parent.Segment__c includes ' +
                 includeList + ' and Segment__c excludes '+includeList;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        for(Target_Initiative__c tI: targetList){
            targetInitiativeAccSet.add(tI.Name);
        }
        Map<Id,Account> childAccounts = new Map<Id,Account>();
        Set<String> segementSet = new Set<String>();
        try{
            for(Account acc: accountList){
                for(String segmentValue : String.valueOf(acc.parent.Segment__c).split(';'))
                {
                    system.debug('segmentValue'+segmentValue);
                    if(targetInitiativeAccSet.contains(segmentValue))     
                    {
                        system.debug('segmentValue1'+segmentValue);
                        //IBA-1911 commented
                        /*if(segmentValue == 'Top Accounts')
                        {
                            acc.is_top_200__c = true;
                        }*/
                        if(acc.Segment__c == null)
                        {
                            acc.Segment__c = segmentValue;
                        }
                        
                        segementSet = new Set<String>();
                        
                        if(acc.Segment__c == null){
                            acc.Segment__c = segmentValue;
                        }else{
                            segementSet.addAll(acc.Segment__c.split(';'));
                            if(!segementSet.contains(segmentValue)){
                                acc.Segment__c +=';'+segmentValue;
                            }
                        }
                       // acc.Delete_Segments__c = null;     IBA-4149
                        childAccounts.put(acc.Id,acc);                        
                    }
                }
            }
            
            if(!childAccounts.isEmpty()){
                system.debug('segmentValue4');
                AccountTriggerHandler.TriggerDisabled = true;
               // Database.update(childAccounts, false);
               update childAccounts.values();
            }
        } catch (Exception ex){
            throw ex;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()]; 
           
        List<Account> parentAccList = new List<Account>();
        String includeList = '(\'';
        includeList += (targetInitiativeName + '\',\'');
        includeList = includeList.removeEnd('\',\'');
        includeList += '\')';
        
        query = 'Select Id from Account where Parent.Segment__c includes ' + includeList + ' and Segment__c excludes ' + includeList ;
       
        if(a.Status != 'Failed' && query != null){
           parentAccList = Database.query(query);
        }
        if(parentAccList!=null && parentAccList.size() > 0)
        {
            BCH_UpdateTopFlagInAccount updateAccountBatchable = new BCH_UpdateTopFlagInAccount();
            updateAccountBatchable.targetList = targetList;
            updateAccountBatchable.targetInitiativeName = targetInitiativeName;
            Database.executeBatch(updateAccountBatchable, 20);            
        }
        else {
                List<Target_Initiative__c> targetInitiativeList = new List<Target_Initiative__c>();
                for(Target_Initiative__c ti : targetList)
                {
                    if(ti.Name != targetInitiativeName)
                    {
                       targetInitiativeList.add(ti) ;
                    }
                }
                if(targetInitiativeList.size() > 0)
                {
                    BCH_UpdateTopFlagInAccount updateAccountBatchable = new BCH_UpdateTopFlagInAccount();
                    updateAccountBatchable.targetList = targetInitiativeList;
                    updateAccountBatchable.targetInitiativeName = targetInitiativeList[0].Name;
                    Database.executeBatch(updateAccountBatchable, 20);                     
                }
              /*  else
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    String[] toAddresses = new String[] {a.CreatedBy.Email}; 
                        mail.setToAddresses(toAddresses); 
                    mail.setSubject('Batch Job Status for updating the Accounts : ' + a.Status); 
                    //mail.setPlainTextBody('The batch job for updating the IsTop200 flag as TRUE/FALSE on parent and child accounts are completed successfully.'); 
                    mail.setPlainTextBody('The batch job for updating segments on parent and child accounts are completed successfully.'); 
                    if(!Test.isRunningTest())
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });              
                }*/
                
                
            
        }
       
    }
}