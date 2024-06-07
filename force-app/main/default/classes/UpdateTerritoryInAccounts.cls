public class UpdateTerritoryInAccounts implements Queueable {
    public List<Account> accountList = new List<Account>();
	public List<id> accountIds =new List<id>();
    public void execute(QueueableContext context) {
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        if(accountList != null && !accountList.isEmpty()){
                AccountTriggerHandler.TriggerDisabled = true;
                AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
				for(Account acct: accountList)
				{
				  accountIds.add(acct.Id);
				  Account oldAccount = new Account();
				  oldAccount.id = acct.id;
				  if(acct.Country_Cluster__c!= null) oldAccount.Country_Cluster__c = acct.Country_Cluster__c;
                  if(acct.Division_Account__c!= null) oldAccount.Division_Account__c = acct.Division_Account__c;
                  if(acct.Region__c!= null) oldAccount.Region__c = acct.Region__c;
                  if(acct.Account_Territory__c!= null) oldAccount.Account_Territory__c = acct.Account_Territory__c;
                  if(acct.Territory_Name__c!= null) oldAccount.Territory_Name__c = acct.Territory_Name__c;
                  if(acct.ownerId!= null) oldAccount.ownerId = acct.ownerId;
				  oldAccountMap.put(acct.Id,oldAccount);
				}
                BCH_UpdateTerritoryInAccounts.updateAccountTerritoryName(accountList,oldAccountMap);
                Database.update(accountList,false);
				setAccountOwnerInSAP(accountList,oldAccountMap,accountIds);
         }          
    }
	
	public static void setAccountOwnerInSAP(List<Account> accList,Map<Id, Account> oldMap,List<id> accIds){
	 
	    Map<Id, Relationship__c> relationshipMap = new Map<Id, Relationship__c>();
	    List <Relationship__c> relationShipList = [Select id, Primary_Account__c, Primary_Account_Sales_Org__c, Secondary_Account__c, 
	                               SAP_Division__c, Relationship__c, PARZA__c,Default_Partner_Flag__c from Relationship__c //IBA-4266
								   Where Primary_Account__c in: accIds];
		if(relationShipList.size() > 0)
		{
		  for (Relationship__c relationAccountRecord : relationShipList) {
		      relationshipMap.put(relationAccountRecord.Primary_Account__c,relationAccountRecord);
		  }
		}
        Account oldAccount;
        string rr11 = '';
		id rr12 = null;
        for (Account newAccount : accList) { 
		    oldAccount = oldMap.get(newAccount.Id);
			if(oldAccount.ownerId != newAccount.ownerId || Test.isRunningTest())
			{
			    if(relationshipMap.get(newAccount.Id) != null){
				    Relationship__c rr = relationshipMap.get(newAccount.Id);
                    String defaultFlag = '';//IBA-4266-Start
                    if(rr.Default_Partner_Flag__c == true){
                        defaultFlag = 'X';
                    }							//IBA-4266-End
					RelationshipCreateController.UpdateAccountRelationship(rr.Id,newAccount.id, rr.Primary_Account_Sales_Org__c, 
                                                                           rr.Secondary_Account__c,rr.SAP_Division__c,rr.Relationship__c, 
                                                                           rr.PARZA__c, oldAccount.OwnerId, rr.Primary_Account_Sales_Org__c, 
                                                                           rr.Secondary_Account__c,rr.SAP_Division__c,rr.PARZA__c,
                                                                           rr.Relationship__c,defaultFlag,defaultFlag);//IBA-4266
				}
				else{ 
                    RelationshipCreateController.UpdateAccountRelationship(rr12,newAccount.id, rr12, rr12,rr11,rr11, rr11, oldAccount.OwnerId, 
                                                                           rr12, rr12,rr11,rr11,rr11,rr11,rr11);//IBA-4266
				}
			}
             
		}
		  
	}
}