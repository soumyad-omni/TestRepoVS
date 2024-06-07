public class OmnicellCommunityLoginHistoryBatch implements Database.Batchable<sObject>  {
    public Database.QueryLocator start(Database.BatchableContext BC){   
        if(test.isrunningTest())
            return Database.getQueryLocator([SELECT UserId FROM LoginHistory where LoginType = 'SAML Chatter Communities External User SSO' LIMIT 1]);
        else
            return Database.getQueryLocator([SELECT UserId FROM LoginHistory where LoginType = 'SAML Chatter Communities External User SSO']);
    }
    
    public void execute(Database.BatchableContext BC, List<LoginHistory> scope) {
        List<Id> usersToAdd = new List<Id>();
        List<Contact> contactList = new List<Contact>();
        for(LoginHistory lh : scope) {
            usersToAdd.add(lh.userId);
            
        }
        
        for(User u : [SELECT contactId from user where id IN: usersToAdd])
        {
            Contact c = new Contact();
            c.id = u.contactId;
            c.Exists_In_Okta__c = True;
            contactList.add(c);
        }
        
        update contactList;                    
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}