global class UpdateOnAccount_IsTop200Batch3_New implements Database.batchable<sObject>, Database.Stateful {
    global Database.queryLocator start (Database.BatchableContext BC) {
        String name = 'Top Accounts';
        return Database.getQueryLocator([SELECT Id, Account__c FROM Target_Initiative_Account__c WHERE Target_Initiative__r.Name =:name]);
    }
    
    global void execute (Database.BatchableContext BC, List<Target_Initiative_Account__c> tiaList) {
        
        Set<Id> accIdsInTop200= new Set<Id>();
        
        List<Account> accForUpdate = new List<Account> ();
        
        if(tiaList.size()>0){
            for (Target_Initiative_Account__c tg : tiaList) {
                accIdsInTop200.add(tg.Account__c);
            }
            if (accIdsInTop200 != NULL && !accIdsInTop200.isEmpty()) {
              /*  for (Account acc : [SELECT Id, Is_Top_200__c FROM Account WHERE Id IN: accIdsInTop200]) {
                    Account ac = new Account(Id = acc.Id);
                    if(acc.Is_Top_200__c == TRUE){
                        acc.Is_Top_200__c = TRUE;
                        if(!accForUpdate.contains(ac))
                            accForUpdate.add(acc);
                    }
                }    IBA-4149*/
            }
            try {
                if (accForUpdate != NULL && !accForUpdate.isEmpty()) {
                    Database.update(accForUpdate,false);
                }
            } catch (Exception e) {
                System.debug(e);
            }
        }
    }
    
    global void finish (Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Is Top 200: Child Account Update ' + a.Status);
        mail.setPlainTextBody
            ('The batch job processed ' + a.TotalJobItems +
             ' and updated the Child accounts accordingly.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}