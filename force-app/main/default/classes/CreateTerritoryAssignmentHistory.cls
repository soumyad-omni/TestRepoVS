public class CreateTerritoryAssignmentHistory implements Queueable{
    public List<UserTerritory2Association> lstToDelete = new  List<UserTerritory2Association>();
    public void execute(QueueableContext context)
    {
          List<Territory_Assignment_History__c> lstToInsrt = new List<Territory_Assignment_History__c>();  
          Set<String> territoryIds = new Set<String>();
          for(UserTerritory2Association deletedUserTerrAssociation : lstToDelete)
          {
              if(!territoryIds.contains(deletedUserTerrAssociation.Territory2Id))
               { territoryIds.add(deletedUserTerrAssociation.Territory2Id); }
          }
          Map<id,Territory2> terrRecords = new Map<id,Territory2>([Select Id, DeveloperName, Territory2Model.Name,  Name from Territory2 where id in: territoryIds]);
          
          if(terrRecords.size()>0)
          {
               for(UserTerritory2Association userTerrAssociation : lstToDelete)
               {
                  Territory2 terr =  terrRecords.get(userTerrAssociation.Territory2Id);
                  Territory_Assignment_History__c terrAssHistory = new Territory_Assignment_History__c();
                  terrAssHistory.Territory_Name__c = terr.Name ; 
                  terrAssHistory.Territory_Model_Name__c = terr.Territory2Model.Name ;
                  terrAssHistory.User__c = userTerrAssociation.UserId ;
                  terrAssHistory.End_Date__c = Date.today();
                  if(userTerrAssociation.RoleInTerritory2 != null)
                    terrAssHistory.Role_In_Territory__c = userTerrAssociation.RoleInTerritory2;
                  terrAssHistory.Start_Date__c = Date.newinstance(userTerrAssociation.LastModifiedDate.year(), userTerrAssociation.LastModifiedDate.month(),
                                                                  userTerrAssociation.LastModifiedDate.day());
                  lstToInsrt.add(terrAssHistory);
               }
              if(lstToInsrt.size() > 0)
              {
                 insert lstToInsrt;
              }       
          }
    }

}