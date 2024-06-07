global class UpdateParentAndChildHierarchy implements Database.Batchable<sObject>{
    global string tarAccId;
    global List<Target_Initiative__c> targetList;
   
    global UpdateParentAndChildHierarchy(string targetAccountId){
        this.tarAccId = targetAccountId;
    }
    global UpdateParentAndChildHierarchy(string targetAccountId,List<Target_Initiative__c> targetUpdatedList){
        this.tarAccId = targetAccountId;        
        this.targetList = targetUpdatedList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('this.targetList --------------> ' + this.targetList);
        List<Target_Initiative__c> tiList = [Select Id, Name from Target_Initiative__c where Use_for_segmentation__c = true ];
        Set<String> targetInitiativeAccSet = new Set<String>();
        for(Target_Initiative__c tI: tiList){
            targetInitiativeAccSet.add(tI.Id);
        }
       String query ='Select Id, Account__c, Account__r.Segment__c,Target_Initiative_Name__c'+ 
                     ' from Target_Initiative_Account__c  where Target_Initiative__r.id in :targetInitiativeAccSet' ;//IBA-4149
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Target_Initiative_Account__c> accountTarget){
        Set<Id> accountIds = new Set<Id>();
        for(Target_Initiative_Account__c tg : accountTarget){ 
           accountIds.add(tg.Account__c);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Name, Segment__c From Account where Id in :accountIds]);
       
        Set<Id> parentAccount_ti = new Set<Id>();
        Map<id,Account> updateParentAccount = new Map<id,Account>();
        Set<String> segementSet = new Set<String>();
        try{
            if(accountTarget != null && !accountTarget.isEmpty()){
                for(Target_Initiative_Account__c tg : accountTarget){ 
                    
                    Account acc = new Account(Id=tg.Account__c,Segment__c = tg.Account__r.Segment__c); 
                    if(accountMap.get(tg.Account__c)!= null)
                    { acc.Segment__c = accountMap.get(tg.Account__c).Segment__c; }                   
                    if(updateParentAccount.get(tg.Account__c) != null)
                    {
                         acc = updateParentAccount.get(tg.Account__c);
                    }                   
                    //IBA-1911 commented
                    /*if(tg.Target_Initiative_Name__c == 'Top Accounts')
                    {
                        acc.is_top_200__c = true;
                    }*/
                    if(acc.Segment__c == null){
                        acc.Segment__c = tg.Target_Initiative_Name__c;
                    }else{
                        segementSet = new Set<String>();
                        segementSet.addAll(acc.Segment__c.split(';'));
                        if(!segementSet.contains(tg.Target_Initiative_Name__c)){
                            acc.Segment__c +=';'+tg.Target_Initiative_Name__c;
                        }
                    }
                    updateParentAccount.put(acc.id,acc);
                }
            }
            
            if(updateParentAccount != null && !updateParentAccount.isEmpty()){
                AccountTriggerHandler.TriggerDisabled = true;
                update updateParentAccount.values();
            }            
        } catch (Exception ex){
            throw ex;
        } 
    }
    
    global void finish(Database.BatchableContext BC){
        if(targetList != null && !targetList.isEmpty()){
            BCH_UpdateTopFlagInAccount updateAccountBatchable = new BCH_UpdateTopFlagInAccount(); 
            updateAccountBatchable.targetInitiativeName = targetList[0].Name;
            updateAccountBatchable.targetList = targetList;
            Database.executeBatch(updateAccountBatchable, 30);  
        }
        /*else
        {
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()]; 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {a.CreatedBy.Email}; 
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Batch Job Status for updating the Accounts : ' + a.Status); 
            //mail.setPlainTextBody('The batch job for updating the IsTop200 flag as TRUE/FALSE on parent and child accounts are completed successfully.'); 
            mail.setPlainTextBody('The batch job for updating the target initiative accounts are completed successfully.');
            if(!Test.isRunningTest())
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        }*/
       
       
    }
}