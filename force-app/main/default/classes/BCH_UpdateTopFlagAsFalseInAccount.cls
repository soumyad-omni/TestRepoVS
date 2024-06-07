global class BCH_UpdateTopFlagAsFalseInAccount implements Database.Batchable<sObject>, Database.Stateful{
    
    global string tarAccId;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Name from Account';    //IBA-4149
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        List<Account> childAccounts = new List<Account>();
        
        try{
            if(accountList != null && !accountList.isEmpty()){
                for(Account acc : accountList){                   
                   //IBA-4149 acc.is_top_200__c = false;
                //IBA-4149    acc.Is_Deleted_From_Top_Accounts__c = false;
                    childAccounts.add(acc);                    
                }
            }
			
			if(!childAccounts.isEmpty()){
                Database.update(childAccounts, false);
            }
        } catch (Exception e){
            
        } 
    }
    
    global void finish(Database.BatchableContext BC){
        UpdateParentAndChildHierarchy schedule2 = new UpdateParentAndChildHierarchy(tarAccId);
        database.executeBatch(schedule2, 1); 
    }
}