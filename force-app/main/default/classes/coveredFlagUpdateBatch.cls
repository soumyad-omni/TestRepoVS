global class coveredFlagUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global list<id> usrId = new list<id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        list<string> s1 = new  list<string>();
        s1.add('e');
        s1.add('e1');
        s1.add('e3');
        s1.add('e5');
        s1.add('e6');
        s1.add('e');
        s1.add('e1');
        s1.add('e3');
        s1.add('e5');
        s1.add('e6');
         s1.add('e');
        s1.add('e1');
        s1.add('e3');
        s1.add('e5');
        s1.add('e6');
        
        String query='';
        query = 'Select Id, Omnicell_Employee_Number__c,Status__c from Covered_Person__c where  Omnicell_Employee_Number__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Covered_Person__c> cv){
        list<string> empidL = new list<string>();
        map<string,boolean> empStatus = new map<string,boolean>();
        for(Covered_Person__c c:cv){
            String s = String.valueOf(c.Omnicell_Employee_Number__c);//IBA-4492
            String ss = s.substringBefore('.');
            empidL.add(ss);
            empStatus.put(ss,c.Status__c);
        }
        list<user> usr = new list<user>();
        map<id,UserRole> intRole = new Map<ID, UserRole>([SELECT DeveloperName,Id,PortalRole,PortalType FROM UserRole where PortalType ='None' and DeveloperName!='Covered' and DeveloperName!='Non_Covered' ]);//IBA-4544
        set<id> rId = intRole.keyset();//IBA-4544
        usr = [select id,Omnicell_Employee_Number__c,IsCovered__c,UserRoleId,UserRole.Name from user where Omnicell_Employee_Number__c=:empidL];//IBA-4544
        id coveredRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Covered' limit 1].id; 
        id exeRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Executive' limit 1].id;//IBA-4544
        list<user> usrUpdate = new list<user>();
        list<User_Field_History__c> histList = new list<User_Field_History__c>();//iba-4492
        for(user u:usr){
            usrId.add(u.id);
            if(empStatus.containskey(u.Omnicell_Employee_Number__c)){
                if(u.IsCovered__c != empStatus.get(u.Omnicell_Employee_Number__c)){
                    boolean oldval = u.IsCovered__c;//IBA-4492
                    u.IsCovered__c = empStatus.get(u.Omnicell_Employee_Number__c);
                    string oldval1 = u.UserRole.Name;//IBA-4544
                    if(u.IsCovered__c == true && !intRole.containskey(u.UserRoleId)){
                        if(u.UserRoleId != exeRole){
                            u.UserRoleId = coveredRole;
                        
                            User_Field_History__c hist1 = createUpdateHistory('User Role',string.valueof(oldval1),'Covered',u);//IBA-4544
                            histList.add(hist1);//IBA-4544
                        }
                        
                    }
                    User_Field_History__c hist = createUpdateHistory('IsCovered',string.valueof(oldval),string.valueof(u.IsCovered__c),u);//IBA-4492
                    histList.add(hist);//IBA-4492
                    usrUpdate.add(u);
                }
                
            }
        }
        usertriggerhandler.triggerdisabled = true;
        if(usrUpdate.size() > 0){
            update usrUpdate;
        }
        if(histList.size() > 0){//IBA-4492
            system.enqueueJob(new UserHistoryTrack(histList));
        }

        
    }   
    
    global void finish(Database.BatchableContext BC) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        list<user> usrUpdate = new list<user>();
        id coveredRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Covered' limit 1].id;
        id nonCoveredRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Non_Covered' limit 1].id;
        id readOnly = [select id,Name from profile where name ='Read Only (Omnicell)' limit 1].id;
        string name = [select name from CoveredPersonBookingTeamMail__c limit 1].name;//IBA-4521
        usertriggerhandler.triggerdisabled = true;
        list<user> usr = new list<user>();
        list<User_Field_History__c> histList = new list<User_Field_History__c>();//iba-4492
        if(usrId.size() > 0){
            system.debug('usrId '+usrId);
            map<id,UserRole> intRole = new Map<ID, UserRole>([SELECT DeveloperName,Id,PortalRole,PortalType FROM UserRole where PortalType ='None' and 
                                                         DeveloperName !='Executive' and DeveloperName!='Covered' and DeveloperName!='Non_Covered' ]);//IBA-4544
            set<id> rId = intRole.keyset();//IBA-4544
            usr = [select id,Omnicell_Employee_Number__c,IsCovered__c,UserRoleId,Profile.Name,Email,Manager.Email,ManagerId,Manager.name,name,UserRole.Name from user where IsCovered__c =True and id NOT IN: usrId]; //iba-4544
            
            for(user u:usr){
                string oldval1 = u.UserRole.Name;//IBA-4544
                if(!intRole.containskey(u.UserRoleId)){//IBA-4544
                    u.UserRoleId = nonCoveredRole;
                    User_Field_History__c hist1 = createUpdateHistory('User Role',string.valueof(oldval1),'Non Covered',u);//IBA-4544
                    histList.add(hist1);
                }
                boolean oldval = u.IsCovered__c;//IBA-4492
                
                u.IsCovered__c = false;
                if(u.Profile.Name == 'Booking Team'){
                    u.ProfileId = readOnly;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    mail.setSaveAsActivity(false);
                    
                    list<string> toAdd = new list<string>();
                    toAdd.add(u.Email);
                    
                    mail.setSubject('Booking Team profile change notification');
                    String meetingInviteBody = 'Hello,<br>'; 
                    meetingInviteBody += 'As of yesterday '+u.Name+' had the Salesforce profile of "Booking Team" and was listed as a Covered Person for Omnicell in Logic Manager.  Today, you were identified as a non-Covered Person in Logic Manager.  As a result, you have been moved to a Read Only profile in Salesforce which will restrict you from viewing opportunities or quotes in Salesforce.  If this is a mistake, please follow the below process:<br><br>';        
                    meetingInviteBody += 'Have your manager '+ u.Manager.name + ' email '+name+' to have '+u.Name+' added as a Covered Person again.<br><br>';//IBA-4521
                    meetingInviteBody += 'Once that occurs, please submit an IT Helpdesk ticket to have your Salesforce profile updated to "Booking Team".<br><br>';
                    meetingInviteBody += 'Once the IT ticket is completed, your access will be restored.<br><br>';
                    meetingInviteBody += 'Thank You!<br>';
                    mail.setHtmlBody(meetingInviteBody);
                    if(u.ManagerId != null)
                    toAdd.add(u.Manager.Email);
                    
                    mail.setToAddresses(toAdd); 
                    emails.add(mail);
                }
                User_Field_History__c hist = createUpdateHistory('IsCovered',string.valueof(oldval),string.valueof(u.IsCovered__c),u);//IBA-4492
                histList.add(hist);//IBA-4492
                
                usrUpdate.add(u);
            }        
            
            

            if(usrUpdate.size() > 0){
                
                update usrUpdate;
            }
            if(histList.size() > 0){//IBA-4492
                system.enqueueJob(new UserHistoryTrack(histList));
            }
            if(emails.size() > 0 && !Test.isRunningTest()){
                Messaging.sendEmail(emails);
            }
        }
        list<string> usrPer = new list<string>();
        list<PermissionSetAssignment> perA = new list<PermissionSetAssignment>();
        perA = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Professional_Services_Intake'];
        map<string,PermissionSetAssignment> pMap = new map<string,PermissionSetAssignment>();
        for(PermissionSetAssignment p:perA){
            usrPer.add(p.AssigneeId);
            pMap.put(p.AssigneeId, p);
        }
        list<user> asgnUsr = new list<user>();
        asgnUsr = [select id,Omnicell_Employee_Number__c,IsCovered__c from user where  id =: usrPer];
        list<PermissionSetAssignment> unAsgnUser = new list<PermissionSetAssignment>();
        for(user u:asgnUsr){
            if(u.IsCovered__c == false){
                unAsgnUser.add(pMap.get(u.id));
            }
        }
        
        if(unAsgnUser.size() > 0){
            delete unAsgnUser;
        }
        
    }
    
    Public User_Field_History__c createUpdateHistory(String field, string oldrec, string newrec, User usr) {//IBA-4492
        User_Field_History__c usrHistory = new User_Field_History__c();
        usrHistory.User__c = usr.Id;
        usrHistory.Field__c = field;
        usrHistory.Updated_by_User__c = UserInfo.getUserId(); 
        usrHistory.Date__c = Datetime.now();
        if (oldrec != null) usrHistory.ORIGINAL_VALUE__c = oldrec;
        if (newrec != null) usrHistory.NEW_VALUE__c = newrec;
        return usrHistory;
    }
    
    
}