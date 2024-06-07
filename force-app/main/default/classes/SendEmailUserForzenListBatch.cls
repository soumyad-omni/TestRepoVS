//Test Class: SendEmailUserForzenListBatchTest
global class SendEmailUserForzenListBatch implements Database.Batchable<sObject>, Database.Stateful , Schedulable
{
    private String frozenUsersList = '';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT id, isFrozen, userId,lastModifieddate FROM userlogin WHERE IsFrozen = TRUE';
        
        if(!test.isRunningTest())
        {
            query = query + ' AND LastModifiedDate = YESTERDAY';
        }
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<userlogin> usrLoginList) 
    {
        frozenUsersList = 'Below users are frozen on '+(date.today().adddays(-1).format())+'.<br/><br/>'
            +'<table border="1"><tr style="font-weight:bold;"><th>User</th><th>Manager</th><th>User Profile</th><th>Active</th><th>SF Status</th><th>Date Frozen</th><th>Days Frozen</th><th>Override</th><th>Ad Status</th><th>Term Date</th><th>Days from Term Date to Frozen Date</th></tr>';
        Boolean foundUser = false;
        try
        {
            Map<Id, userlogin> usrIdMap = new Map<Id, userlogin>();
            List<UserDetailsReportController.cls_wrapper> ret_cls = new List<UserDetailsReportController.cls_wrapper>();
            for(userlogin ul : usrLoginList)
            {
                usrIdMap.put(ul.UserId, ul);
            }
            
            ret_cls = UserDetailsReportController.getUserWrapperDetails(usrIdMap);
            
            for(UserDetailsReportController.cls_wrapper usr : ret_cls)
            {
                String termDate = '', termToFrozen = '';
                
                if(usr.termDate <> NULL)
                    termDate = usr.termDate;
                
                if(usr.termToFrozen <> NULL)
                    termToFrozen = String.valueOf(usr.termToFrozen);
                
                frozenUsersList = frozenUsersList + '<tr><td><a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+usr.UserId+'">' + usr.name + '</a></td><td>'+usr.ManagerName+'</td><td>'+usr.ProfileName+'</td><td>'+usr.isActive+'</td><td>'+usr.isFrozen+'</td><td>'+usr.dateFrozen+'</td><td>'+usr.daysFrozen+'</td><td>'+usr.doNotDeactivate+'</td><td>'+usr.adstatus+'</td><td>'+termDate+'</td><td>'+termToFrozen+'</td></tr>';
                foundUser = true;
            }
            
            if(!foundUser)
                frozenUsersList = '';
        }
        catch(Exception e)
        {
            frozenUsersList = '';
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('finish-->'+frozenUsersList);
        if(frozenUsersList <> '')
        {
            frozenUsersList = frozenUsersList + '</table>';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            List<String> sendTo = new List<String>(system.label.Email_Address_for_Frozen_Users_List.split(','));
            
            email.setSubject('Frozen Users List '+(date.today().adddays(-1).format()));
            email.setToAddresses(sendTo);
            email.setHtmlBody(frozenUsersList);
            system.debug('email-->'+email);
            if(!test.isRunningTest())
                Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        }
    }
    
    global void execute(SchedulableContext SC) {
        SendEmailUserForzenListBatch cls = new SendEmailUserForzenListBatch();
        database.executeBatch(cls);      
    }
}