public class TiAccountAddQueue implements Queueable {
    Set<Id> tarAcctIds;
    
    public TiAccountAddQueue(Set<Id> tarAcctIds){
        this.tarAcctIds = tarAcctIds;
    }
    
    public void execute(QueueableContext context){
        List<Target_Initiative_Account__c> targetIniAccList = [Select Id, Account__c, Target_Initiative__c,Target_Initiative_Name__c 
                                                               FROM Target_Initiative_Account__c  WHERE Id IN :tarAcctIds] ;
        
        if(targetIniAccList!=null && targetIniAccList.size()>0){
            Target_Initiative_Account__c tia=targetIniAccList[0];
            Id acctId = tia.Account__c;
            Id tiId   = tia.Target_Initiative__c; 
            
            if(tiId!=null){
                List<Target_Initiative__c> ti = [Select Id, Name,Type_of_account_propagation__c FROM Target_Initiative__c 
                                                 WHERE Id =:tiId AND Use_for_segmentation__c = true];
                if(ti.size()>0){
                    Target_Initiative__c tgIni=ti.get(0);
                    String propagationType = tgIni.Type_of_account_propagation__c; 	
                    String targetInitiaveName = tgIni.Name;
                    
                    if(propagationType =='Apply to entire hierarchy' || propagationType =='Apply to Parent and immediate Children' 
                       || propagationType =='Apply to individual account') {
                           List<Account> topAccChildsExt;
                           if(propagationType=='Apply to entire hierarchy') 
                               topAccChildsExt=[SELECT Id,External_Data__c From Account where Top_Level_CaseSafeID__c =:acctId];
                           else if(propagationType=='Apply to Parent and immediate Children'){
                               Account selfAc =[SELECT Id,External_Data__c From Account where Id  = :acctId];
                               topAccChildsExt=[SELECT Id,External_Data__c From Account where ParentId = :acctId];
                               topAccChildsExt.add(selfAc);
                           }
                           else if(propagationType=='Apply to individual account'){
                               topAccChildsExt =[SELECT Id,External_Data__c From Account where Id =:acctId];
                           }
                           
                           Set<Id> accKeys=new Set<Id>();
                           //get all childs of TI and create External Data object if not exist
                           for(Account ac:topAccChildsExt){
                               accKeys.add(ac.Id);
                           }
                           
                           TiAccountAddBatch tiAcctAddBatch = new TiAccountAddBatch(accKeys,targetInitiaveName,acctId);
                           Database.executeBatch(tiAcctAddBatch, 50);
                       }
                }
            }
        }
    }
}