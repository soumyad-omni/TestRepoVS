public class updateContactQueueableclass implements Queueable{ //Added by Sourav IBA-1129
				List<Account> AccountsToUpdate= new List<Account>();
                public updateContactQueueableclass (List<Account> TriggeredAccList )
                {
                    AccountsToUpdate = TriggeredAccList ;
                }
                public void execute(QueueableContext context)
                {
                    List<Contact> clist = updateContactETM(AccountsToUpdate);
                    try{
                        update clist;
                    }
                    catch(DmlException e){
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                }
    
    
    public static List<Contact> updateContactETM(List<Account> accList){
             	
             	Set<Id> accountIds = new Set<Id>();
                Map<String, String> map2 = new Map<String, String>();
                Map<String, String> map3 = new Map<String, String>();
            	List<Contact> contactList = new List<Contact>();
                for(Account acc : accList)
         		{  
                    accountIds.add(acc.Id); 
                }
            	contactList = [Select id,Health_Systems_Executive__c,Client_Success_Executive__c,AccountId,Validation_Status__c From Contact Where AccountId IN :accountIds];
                Map<Id,UserTerritory2Association> utMap = new Map<Id,UserTerritory2Association>();
                Set<Id> territorySet = new Set<Id>();
                Map<Id,Set<Id>> accountTerritoryMap = new Map<Id,Set<Id>>();
                Map<Id,Territory2Model> modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model where State = 'Active']);
                if(Test.isRunningTest())
        		{
                    modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model Where DeveloperName='Test_Model' LIMIT 1]);
                }
                 Set<Id> territoryIds;
                 for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority from ObjectTerritory2Association
                                                      where objectId IN :accList and Territory2.Territory2ModelId = :modelMap.keySet()])
                 {
                    	territoryIds = accountTerritoryMap.get(ota.ObjectId);
                        if(!territorySet.contains(ota.Territory2Id))
                        {
                            territorySet.add(ota.Territory2Id);
                        }
                        if(territoryIds!= null && territoryIds.size() > 0){
                            territoryIds.add(ota.Territory2Id);
                        }
                        else 
                        {
                            territoryIds = new  Set<Id>();
                            territoryIds.add(ota.Territory2Id);                
                        }            
                        accountTerritoryMap.put(ota.ObjectId, territoryIds);
                 }
                  if(territorySet.size() == 0 )
                  {
                      return null;
                  }
                  territoryIds= new Set<Id>();
                  List<UserTerritory2Association> userTerrAssList2 = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                                                                         from UserTerritory2Association 
                                                                         where Territory2Id in:territorySet and User.IsActive =: true];
        // and RoleInTerritory2 IN('Client Success Executive','Health Systems Executive','Health System Executive - Govt'
                                                                          
                  Map<String, String> cse1 = new Map<String, String>();
                  Map<String, String> cse2 = new Map<String, String>();
                  Map<String, String> hse1 = new Map<String, String>();
                  Map<String, String> hse2 = new Map<String, String>();
                  Set<Id> territoryIds2= new Set<Id>();
            	  
                      	   for(UserTerritory2Association uta:userTerrAssList2)
                          {
                                Integer i = 0;
                                 for (Account acct: accList)
                                 {
                                       if(acct.IsDeleted__c)
                                       {
                                           continue;
                                       }
                                       territoryIds2 = accountTerritoryMap.get(acct.Id);
                                       if(territoryIds2!= null && territoryIds2.size() > 0 && territoryIds2.contains(uta.Territory2Id))
                                       {
                                             if(uta.RoleInTerritory2 == 'Client Success Executive')
                                             {
                                                 cse1.put(acct.id,uta.userId);
                                                 cse2.put(acct.id,uta.RoleInTerritory2);
                                             }
                                             if(uta.RoleInTerritory2 == 'Health System Executive - Govt' || uta.RoleInTerritory2 == 'Health Systems Executive')
                                             {
                                                 hse1.put(acct.id,uta.userId);
                                                 hse2.put(acct.id,uta.RoleInTerritory2);
                                             }
                                       }
                                 }
                           }
                           for(Contact c: contactList) 
                           {        
                                if(cse2.containsKey(c.AccountId)) 
                                {
                                    String usrId = cse1.get(c.AccountId);
                                    c.Client_Success_Executive__c = usrId;
                                }
                               else
                               {
                                   c.Client_Success_Executive__c = null;
                               }
                                if(hse1.containsKey(c.AccountId)) 
                                {
                                    String usrId = hse1.get(c.AccountId);
                                    c.Health_Systems_Executive__c = usrId;
                                }
                               else
                               {
                                   c.Health_Systems_Executive__c = null;
                               }
                           }          
                    return contactList;
                  
         }
}