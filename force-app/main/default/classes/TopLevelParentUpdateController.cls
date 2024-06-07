public class TopLevelParentUpdateController {
    @AuraEnabled
    Public static String updateTopLevelParent(Id accountId){
        Account acc=[SELECT Id FROM Account WHERE Id =: accountId Limit 1];
        Boolean topLevelParent = false;
        Id id=accountId;
        while ( !topLevelParent ) {
            if(id!=null){
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
            update acc;
            return 'Success';
        }
        else
            return 'Parent Not Present';
    }
}