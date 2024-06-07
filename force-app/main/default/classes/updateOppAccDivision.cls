Global class updateOppAccDivision implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, AccountDivision__c, Account.Division_Account__c FROM Opportunity where Account.isdeleted != true'; 
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList)
    { 
        List<Opportunity> opp2update = new List<Opportunity>();
        
        for(Opportunity opp:oppList){
            if(opp.AccountDivision__c != opp.Account.Division_Account__c){
                opp.AccountDivision__c = opp.Account.Division_Account__c;
                opp2update.add(opp);
            }
        }
        
        if(opp2update.size() > 0){
            opportunitytriggerhandler.triggerdisabled = true;
            List<Database.SaveResult> results = Database.update(opp2update, false);
        }
        
    }  
    global void finish(Database.BatchableContext BC)
    {
        
    }
}