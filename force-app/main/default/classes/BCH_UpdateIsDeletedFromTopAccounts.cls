public class BCH_UpdateIsDeletedFromTopAccounts implements Database.Batchable<sObject>{
    
    public string tarAccId;
    public List<Target_Initiative__c> targetList;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Name, Segment__c from Account where ' +         //IBA-4149
            ' Segment__c != null';      //IBA-4149
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accountList){
        List<Account> childAccounts = new List<Account>();        
        try{
            if(accountList != null && !accountList.isEmpty()){
                for(Account acc : accountList){                   
                   //IBA-4149   acc.Is_Deleted_From_Top_Accounts__c = false;
                   // acc.is_top_200__c = false;
                    //     acc.Delete_Segments__c = null;      IBA-4149    
                    acc.Segment__c = null;                    
                }
                AccountTriggerHandler.TriggerDisabled = true;
                Database.update(accountList, false);                
            }
        } catch (Exception e){
            
        }
    }
    
    public void finish(Database.BatchableContext BC){
        UpdateParentAndChildHierarchy schedule2 = new UpdateParentAndChildHierarchy(tarAccId,targetList);
        database.executeBatch(schedule2, 30);           
    }
}