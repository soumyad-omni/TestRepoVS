Global class BatchTopLevelParentUpdate implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, Name, ParentId,BillingCountry FROM Account where ParentId != null'; 
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Account> scope)
    { 
        List<Account> accList=new List<Account>();
        System.debug(scope);
        for(Account acc:scope){
            Boolean topLevelParent = false;
            Id id=acc.ParentId;
            while ( !topLevelParent ) {
                if(id!=null && acc.BillingCountry!=NULL) 
                {
                    Account a = [ Select Id, ParentId From Account where Id =: id ];
                    if ( a.ParentID != null ) {
                        id = a.ParentID;
                    }
                    else {
                        id=a.id;
                        topLevelParent = true;
                    }
                }
                else{
                    topLevelParent = true;
                }
                
            }
            if(id!=acc.Id){
                //iba-4074 acc.Top_Level_Parent__c = id;
                accList.add(acc);
            }
        }
        update accList;
    }  
    global void finish(Database.BatchableContext BC)
    {
        
    }
}