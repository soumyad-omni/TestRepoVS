public class recall_qap {
    @AuraEnabled
	public static void updateCheck(){
         
        //list<recall_permission__c> per = [select name, id__c from recall_permission__c];
        list<recall_permission__c> per = recall_permission__c.getall().values();
        permisn(per[0].id__c);
              
    }
    
    @future
    public static void permisn(string per){        
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        for (User u : [Select Id, Name FROM User Where Id=: UserInfo.getUserId()]){ 
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = per, AssigneeId = u.Id);
            permissionSetList.add(psa);
        }
        insert permissionSetList;
              
    }
    
    @AuraEnabled
    public static void update1(string key, String cmnt){
        list<Quote_Approval__c> qap_list = new list<Quote_Approval__c>();
        qap_list = [select id,Status__c,Comment__c,Quote__c from Quote_Approval__c WHERE Id=:key];
        Quote_Approval__c qap =new Quote_Approval__c();
        qap.id=qap_list[0].id;
        qap.Comment__c=qap_list[0].Comment__c; //Pabitra: IBA-1812
        System.debug('************2' +cmnt);
        //Approval.unLock(qap.id);
        Approval.UnlockResult unlockedRersult = Approval.unLock(qap_list[0].Quote__c);
        
        if (unlockedRersult.isSuccess()) {
            
            System.debug('Successfully unlocked qap with ID: ' + unlockedRersult.getId());
        }
        qap.Status__c='Recall';
        
        //Pabitra: IBA-1812
        if(cmnt!=null){
       	 if(qap.Comment__c!=null){
        	qap.Comment__c=qap.Comment__c+' >> '+cmnt;
         }
         else{
            qap.Comment__c=cmnt;    
         }
      }//IBA-1812
       
        qap.Assigned_To__c = '';
        update qap;
        ProcessInstance pi = [SELECT Id,TargetObjectid, Status,
                                        (select id,actor.name,originalActor.name from Workitems)
                                        FROM ProcessInstance 
                                    WHERE TargetObjectId =:key and Status = 'pending'];
        system.debug('---'+pi);
        ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem where ProcessInstanceId=:pi.Id limit 1];
        Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
        req.setWorkItemId(workItem.Id);
        
        req.setAction('Removed');
        Approval.ProcessResult result = Approval.process(req);
        
    }
    @AuraEnabled
    public static void update2(){
        //list<recall_permission__c> per = [select name, id__c from recall_permission__c];
        list<recall_permission__c> per = recall_permission__c.getall().values();
        delete [SELECT Id from PermissionSetAssignment WHERE PermissionSetId =: per[0].id__c AND AssigneeId =: UserInfo.getUserId()];
    }
    
    @AuraEnabled
   public static boolean isrendered(string key){
       boolean val = false;
       list<Quote_Approval__c> qap_list = new list<Quote_Approval__c>();
       //system.debug('--1'+key);
       qap_list = [select id,Status__c,Quote__c,Quote__r.AccountId,OwnerId from Quote_Approval__c WHERE Id=:key];
       //system.debug('acccc  roll111111111'+qap_list[0].Quote__r.AccountId);
       String accountId = qap_list[0].Quote__r.AccountId;
       Set<Id> territoryIds = new  Set<Id>() ;
       for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id from ObjectTerritory2Association
                                            where objectId = :accountId]){
                                                territoryIds.add(ota.Territory2Id);
                                            }
       List<UserTerritory2Association> userTerrAssList = [select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                                                          from UserTerritory2Association 
                                                          where Territory2Id in:territoryIds and User.IsActive =: true ];
      //system.debug('acccc  roll111111111'+actm);
       Id profileId= userinfo.getProfileId();
       String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       
       List<recall_acc_roll__c> mcs = recall_acc_roll__c.getall().values();
       Set<string> acc_r = new Set<string>();		
		for (recall_acc_roll__c i:mcs){    		
    		acc_r.add(i.Name);
		}
       //system.debug('acccc  roll'+acc_r);
       if (profileName == 'System Administrator' || profileName == 'Business Administrator' || UserInfo.getUserId() == qap_list[0].OwnerId ){
               val = true;
              system.debug('acccccccccccccccccccccccccccccccccc1'+val);
           }
       for(UserTerritory2Association uta : userTerrAssList){
           system.debug('uta.UserId'+uta.UserId);
           system.debug('loggedInUserId'+UserInfo.getUserId());
           if (uta.UserId == UserInfo.getUserId()){
               if (acc_r.contains(uta.RoleInTerritory2)){ val = true; }
           }
       }
       
       if (qap_list[0].Status__c == 'Approved' || qap_list[0].Status__c == 'Rejected' || qap_list[0].Status__c == 'Recall' ){
               val = false;
       }
        system.debug('acccccccccccccccccccccccccccccccccc1'+val);
        return val;
       
   }


}