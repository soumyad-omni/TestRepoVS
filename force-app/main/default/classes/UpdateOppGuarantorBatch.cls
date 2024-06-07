global class UpdateOppGuarantorBatch implements Database.Batchable<sObject> {
    List<String> oppIds;
    
    public UpdateOppGuarantorBatch(List<String> oppIdList)
    {
        this.oppIds = oppIdList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query ='SELECT id, accountId, account.Credit_Approved_For__c, account.Own_Guarantor__c FROM Opportunity WHERE Lock_Guarantor__c = FALSE AND Id IN :oppIds';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) 
    {
        List<opportunity> updateOpp = new List<Opportunity>();
        
        for(Opportunity opp : oppList)
        {
            opp.Credit_Approved_For__c = opp.account.Own_Guarantor__c ? opp.accountId : opp.account.Credit_Approved_For__c;
            
            updateOpp.add(opp);
        }
     
        if(!updateOpp.isEmpty())
        {
            update updateOpp;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}