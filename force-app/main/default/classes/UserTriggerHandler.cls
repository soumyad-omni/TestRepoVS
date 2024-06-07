public class UserTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public static boolean isFirstRun=True;
    public boolean isDisabled;
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('UserTriggerDisabled');
        if(tc != null) isDisabled = tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        //IBA-3781 start
        List<User> newUsers= newItems;
        id coveredRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Covered' limit 1].id; 
        id exeRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Executive' limit 1].id;
        id uscaRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='US_CA' limit 1].id;
        id bookId = [select id from Profile where name='Booking Team' limit 1].id;
        for(User u :newUsers){  
            if(u.UserRoleId == exeRole && u.IsCovered__c != True){
                u.adderror('Role cannot be Executive if IsCovered flag is not checked');
            }
            if(u.UserRoleId == uscaRole){
                u.adderror('Role cannot be US & CA');
            }
            if(bookId == u.ProfileId && u.IsCovered__c != True){
                u.adderror('Profile cannot be changed to Booking Team if IsCovered flag is not checked');
            }
            
        }
        //IBA-3781 end
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newItems){
        //IBA-3781 start
        List<User> newUsers= newItems.values();
        System.debug('Before Update:' +newUsers);
        List<User> oldUsers= oldmap.values();
        System.debug(oldUsers);
        id coveredRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Covered' limit 1].id; 
        id nonCoveredRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Non_Covered' limit 1].id; 
        id exeRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='Executive' limit 1].id;
        id uscaRole = [select id,Name, DeveloperName  from UserRole where DeveloperName='US_CA' limit 1].id;
        id bookId = [select id from Profile where name='Booking Team' limit 1].id;
        for(User u :newUsers){
            user usr = (user) oldMap.get(u.id);
            if(u.IsCovered__c != usr.IsCovered__c){
                if(u.IsCovered__c == true && usr.UserRoleId == nonCoveredRole){
                    u.UserRoleId = coveredRole;
                }else if(u.IsCovered__c == false && usr.UserRoleId == coveredRole){
                    u.UserRoleId = nonCoveredRole;
                }
            }else if(u.UserRoleId != usr.UserRoleId){
                
                if(u.UserRoleId == exeRole && u.IsCovered__c != True){
                    u.adderror('Role cannot be changed to Executive if IsCovered flag is not checked');
                }
                if(u.UserRoleId == coveredRole && u.IsCovered__c != True){
                    u.adderror('Role cannot be changed to Covered if IsCovered flag is not checked');
                }
                if(u.UserRoleId == uscaRole){
                    u.adderror('Role cannot be changed to US & CA');
                }
                if(u.UserRoleId == nonCoveredRole && u.IsCovered__c == True){//iba-4492
                    u.adderror('Role cannot be changed to Non Covered if IsCovered flag is checked');
                }
            }
            if(u.ProfileId  != usr.ProfileId && bookId == u.ProfileId && u.IsCovered__c != True){
                u.adderror('Profile cannot be changed to Booking Team if IsCovered flag is not checked');
            }
            if(u.Title != usr.Title){ //IBA--4410
                u.PreviousTitle__c = usr.Title;
            }
            
            
        }
        //IBA-3781 end
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        List<User> newUsers= newItems.values(); 
        Set<Id> communityUserIds = new Set<Id>();
        Boolean comUseractivationFlag = false;
        Set<Id> uid = new Set<Id>();//IBA-3262
        for(User u :newUsers){
            uid.add(u.id);
            if(u.Profile.Name != 'Omnicell B2B Storefront Profile'){
                comUseractivationFlag = True;
                communityUserIds.add(u.Id);
            }
        }
        if(comUseractivationFlag == True){
            createCommunityUsers(communityUserIds);
        }
        List <User_Field_History__c> uhistory = new List <User_Field_History__c>();
        for(User us:newUsers){
            User_Field_History__c usrHistory = new User_Field_History__c();
            usrHistory.User__c = us.id;
            usrHistory.Field__c = 'Created';
            usrHistory.Updated_by_User__c = UserInfo.getUserId();
            usrHistory.Date__c = DateTime.now();
            uhistory.add(usrHistory);
        }
        system.enqueueJob(new UserHistoryTrack1(uhistory));//IBA-3262 End
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        Boolean comUserdeactivationFlag = false;
        List<User> oldusers = oldItems.values();
        System.debug(oldusers);
        List<User> newUsers= newItems.values(); 
        System.debug(newUsers);
        Set<Id> deactivatedUserIds = new Set<Id>();//IBA-5931 Sourav
        Map<Id, User> olduserItems = new Map<Id, User>(oldusers);//IBA-3262 -- Start
        Set<Id> managerIds = new Set<Id>(); 
        Set<Id> userRoleIds = new Set<Id>(); 
        Set<Id> userLicenseIds = new Set<Id>(); 
        Set<Id> userProfileIds = new Set<Id>(); //IBA-3262 -- End
        
        Set<Id> communityUserIds = new Set<Id>();
        for(User u :newUsers){
            managerIds.add(u.ManagerId);//IBA-3262 -- Start
            managerIds.add(olduserItems.get(u.Id).ManagerId); 
            userRoleIds.add(u.UserRoleId); 
            userRoleIds.add(olduserItems.get(u.Id).UserRoleId); 
            userProfileIds.add(u.ProfileId); 
            userProfileIds.add(olduserItems.get(u.Id).ProfileId); //IBA-3262 -- End
            if(u.Profile.Name != 'Omnicell B2B Storefront Profile' && u.IsActive == False ){
                comUserdeactivationFlag = True;
                communityUserIds.add(u.Id);
            }
        }
        if(comUserdeactivationFlag == True && isFirstRun){ // Added isFirstRun as part of IBA-5967 SH
            //system.enqueueJob(new DeactivateCommunityContacts(communityUserIds));
            //system.enqueueJob(new DeactivateCommunityUsers(communityUserIds));
            deactivateCommunityUsers(communityUserIds);
            deactivateCommunityContacts(communityUserIds);
        }
        
        //IBA-3262 Start
        list<User_Field_Tracking__c> s = [select name from User_Field_Tracking__c];
        list<string> s1 = new list<string>();
        for(User_Field_Tracking__c i : s){
            s1.add(i.name);
        }
        set<string> st = new set<string>();
        st.addall(s1);
        Map<String, Schema.SObjectField> allUserFieldsMap = Schema.SObjectType.User.fields.getMap();
        Map<String, Schema.DescribeFieldResult> usrFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
        for (Schema.SObjectField usrField : allUserFieldsMap.values()) {
            Schema.DescribeFieldResult describeResult = usrField.getDescribe();
            
            if (describeResult.getName() != 'CreatedDate' &&
                describeResult.getName() != 'LastModifiedDate' &&
                describeResult.getName() != 'SystemModstamp' &&
                describeResult.isAccessible() &&
                !describeResult.isCalculated()
               )
            {
                if(st.contains(describeResult.getName().toUpperCase())){
                    usrFieldsToTrack.put(describeResult.getName(), describeResult);
                }
            }
            
        }
        System.debug(usrFieldsToTrack);
        //IBA-3262 Start
        List<User> allmanagers = [Select Id,Name From User Where Id =:managerIds];
        Map<String,String> allmanagerMap = new Map<String,String>();
        for(user muser:allmanagers){
            allmanagerMap.put(muser.Id, muser.Name);
        }
        System.debug('****'+allmanagerMap);
        List<UserRole> alluserRoles = [Select Id,Name From UserRole Where Id =:userRoleIds];
        Map<String,String> alluserRoleMap = new Map<String,String>();
        for(UserRole userR:alluserRoles){
            alluserRoleMap.put(userR.Id, userR.Name);
        }
        
        List<Profile> alluserProfiles = [Select Id,Name,UserLicenseId From Profile Where Id =:userProfileIds];
        Map<String,String> allprofileMap = new Map<String,String>();
        Map<String,String> allprofileRoleMap = new Map<String,String>();
        for(Profile prof:alluserProfiles){
            allprofileMap.put(prof.Id, prof.Name);
            allprofileRoleMap.put(prof.Id,prof.UserLicenseId);
            userLicenseIds.add(prof.UserLicenseId);
        }
        Map<String,UserLicense> alluserLicenseMap = new Map<String,UserLicense>([Select id,Name From UserLicense Where Id =:userLicenseIds]);
        
        Schema.DescribeFieldResult timezonePickList = User.TIMEZONESIDKEY.getDescribe();
        Map<String,String> timezonePickMap = getPickListMap(timezonePickList); 
        
        Schema.DescribeFieldResult countryClusterPickList = User.COUNTRY_CLUSTER__C.getDescribe();
        Map<String,String> countryClusterPickMap = getPickListMap(countryClusterPickList);
        
        Schema.DescribeFieldResult divisionPickList =User.DIVISION__C.getDescribe();
        Map<String,String> divisionPickMap = getPickListMap(divisionPickList);
        
        Schema.DescribeFieldResult regionUserPickList =User.REGION_USER__C.getDescribe();
        Map<String,String> regionUserPickMap = getPickListMap(regionUserPickList);
        
        Schema.DescribeFieldResult territoryPickList =User.TERRITORY__C.getDescribe();
        Map<String,String> territoryPickMap = getPickListMap(territoryPickList);
        
        Schema.DescribeFieldResult IntUserRegPickList =User.INTERNATIONAL_USER_REGION__C.getDescribe();
        Map<String,String> IntUserRegPickMap = getPickListMap(IntUserRegPickList);
        
        Schema.DescribeFieldResult localSideKeyPickList =User.LOCALESIDKEY.getDescribe();
        Map<String,String> localSideKeyPickMap = getPickListMap(localSideKeyPickList);
        
        Schema.DescribeFieldResult reportingDivisionManagerPickList =User.REPORTING_DIVISION_MANAGER__C.getDescribe();
        Map<String,String> reportingDivisionManagerPickMap = getPickListMap(reportingDivisionManagerPickList);
        
        Schema.DescribeFieldResult reportingManagerPickList =User.REPORTNG_MANAGER__C.getDescribe();
        Map<String,String> reportingManagerPickMap = getPickListMap(reportingManagerPickList);
        
        Schema.DescribeFieldResult reportingBusUnitMangaerpickList =User.REPORT_BUSINESS_UNIT_MANAGER__C.getDescribe();
        Map<String,String> reportingBusUnitMangaerPickMap = getPickListMap(reportingBusUnitMangaerpickList);
        
        Schema.DescribeFieldResult reportingRegionMangaerPickist =User.REPORTING_REGION_MANAGER__C.getDescribe();
        Map<String,String> reportingRegionMangaerPickMap = getPickListMap(reportingRegionMangaerPickist);
        
        //IBA-3262  End
        list<User_Field_History__c> usrhistoriesToInsert = new list<User_Field_History__c>();
        //IBA-3262 - Start
        for(User usr:newUsers){
            User oldusr = olduserItems.get(usr.Id);
            if (!usr.IsActive && oldusr.IsActive) { //IBA-5931 Sourav
                deactivatedUserIds.add(usr.Id);
            }
            for (Schema.DescribeFieldResult fieldDescribe : usrFieldsToTrack.values()) {
                User_Field_History__c usrHistory = new User_Field_History__c();
                string usrOld = '';
                string usrNew ='';
                string fieldName ='';
                if (oldusr.get(fieldDescribe.getName()) != usr.get(fieldDescribe.getName())){
                    fieldName = fieldDescribe.getLabel();
                    System.debug('****'+fieldDescribe.getName().toUpperCase());
                    if (fieldDescribe.getType() == Schema.DisplayType.Boolean){
                        usrOld='False';
                        usrNew='False';
                        if(usr.get(fieldDescribe.getName()) ==true){
                            usrNew = 'True';
                        }
                        if(oldusr.get(fieldDescribe.getName()) ==true){
                            usrOld = 'True';
                        }                        
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'MANAGERID'){
                        if(string.valueOf(oldusr.get(fieldDescribe.getName())) != null){
                            usrOld = allmanagerMap.get(string.valueOf(oldusr.get(fieldDescribe.getName())));
                        }
                        if(string.valueOf(usr.get(fieldDescribe.getName())) != null){
                            usrNew = allmanagerMap.get(string.valueOf(usr.get(fieldDescribe.getName())));
                        }
                        fieldName='Manager';
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'USERROLEID'){
                        if(string.valueOf((oldusr.get(fieldDescribe.getName()))) != null){
                            usrOld = alluserRoleMap.get((String)oldusr.get(fieldDescribe.getName()));
                        }
                        if(string.valueOf((usr.get(fieldDescribe.getName()))) != null){
                            usrNew = alluserRoleMap.get((String)usr.get(fieldDescribe.getName()));
                        }
                        fieldName='User Role';
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'PROFILEID'){
                        if(string.valueOf((oldusr.get(fieldDescribe.getName()))) != null){
                            usrOld = allprofileMap.get((String)oldusr.get(fieldDescribe.getName()));
                        }
                        if(string.valueOf((usr.get(fieldDescribe.getName()))) != null){
                            usrNew = allprofileMap.get((String)usr.get(fieldDescribe.getName()));
                        }
                        fieldName='Profile';
                        if(allprofileRoleMap.get((String)usr.get(fieldDescribe.getName())) != allprofileRoleMap.get((String)oldusr.get(fieldDescribe.getName()))){
                            System.debug(allprofileRoleMap.get((String)usr.get(fieldDescribe.getName())));
                            System.debug(allprofileRoleMap.get((String)oldusr.get(fieldDescribe.getName())));
                            String oldRoleId = allprofileRoleMap.get((String)oldusr.get(fieldDescribe.getName()));
                            String newRoleId = allprofileRoleMap.get((String)usr.get(fieldDescribe.getName()));
                            UserLicense oldRole = alluserLicenseMap.get(oldRoleId);
                            UserLicense newRole = alluserLicenseMap.get(newRoleId);
                            String newRoleName = newRole.Name;
                            String oldRoleName = oldRole.Name;
                            User_Field_History__c usrRoleHistory = new User_Field_History__c();
                            usrRoleHistory = createUpdateHistory2('User License', oldRoleName, newRoleName, usr);
                            usrhistoriesToInsert.add(usrRoleHistory);
                        }
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'COUNTRY_CLUSTER__C'){                        
                        usrOld = countryClusterPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = countryClusterPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'DIVISION__C'){
                        usrOld = divisionPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = divisionPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'REGION_USER__C'){
                        usrOld = regionUserPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = regionUserPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'TERRITORY__C'){
                        usrOld = territoryPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = territoryPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'INTERNATIONAL_USER_REGION__C'){
                        usrOld = IntUserRegPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = IntUserRegPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'LOCALESIDKEY'){
                        usrOld = localSideKeyPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = localSideKeyPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'REPORTING_DIVISION_MANAGER__C'){
                        usrOld = reportingDivisionManagerPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = reportingDivisionManagerPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'REPORTNG_MANAGER__C'){
                        usrOld = reportingManagerPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = reportingManagerPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'REPORT_BUSINESS_UNIT_MANAGER__C'){
                        usrOld = reportingBusUnitMangaerPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = reportingBusUnitMangaerPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'REPORTING_REGION_MANAGER__C'){
                        usrOld = reportingRegionMangaerPickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew = reportingRegionMangaerPickMap.get(string.valueOf((usr.get(fieldDescribe.getName()))));
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'TIMEZONESIDKEY'){
                        usrOld= timezonePickMap.get(string.valueOf((oldusr.get(fieldDescribe.getName()))));
                        usrNew= timezonePickMap.get(string.valueof((usr.get(fieldDescribe.getName()))));
                    }     
                    else{
                        usrOld = string.valueOf((oldusr.get(fieldDescribe.getName())));
                        usrNew = string.valueof((usr.get(fieldDescribe.getName())));
                    }
                    usrHistory = createUpdateHistory2(fieldName, usrOld, usrNew, usr);
                    usrhistoriesToInsert.add(usrHistory);
                }
            }            
        }
        if(usrhistoriesToInsert.size()>0){
            System.debug(usrhistoriesToInsert);
            system.enqueueJob(new UserHistoryTrack1(usrhistoriesToInsert));
        }        
        //IBA-3262 - End
        //IBA-5931 Sourav Start
        if (!deactivatedUserIds.isEmpty()) {
            // Query the UserLogin records for the deactivated users
            List<UserLogin> userLogins = [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE UserId IN :deactivatedUserIds AND IsFrozen = true];
            
            // Update the IsFrozen field to false (0)
            for (UserLogin userLogin : userLogins) {
                userLogin.IsFrozen = false;
            }
            
            // Update the UserLogin records
            if (!userLogins.isEmpty()) {
                update userLogins;
            }
        }
        //IBA-5931 Sourav End
    }
    
    @future
    public static void createCommunityUsers(Set<id> newUserIds){
        Profile profileId = [select Id,name from Profile where Profile.Name =:System.Label.OCB_RegisterUserProfile limit 1];
        List<User> newUsers= [Select Id,FirstName,LastName,Phone,Email,Profile.Name From User Where Id IN :newUserIds];  
        List<User> communityUsers = new List<User>();
        for (User u : newUsers) { 
            if(u.Profile.Name != 'Omnicell B2B Storefront Profile'){
                Contact con = new Contact();
                con.FirstName = u.FirstName;
                con.LastName = u.LastName;
                con.Phone = u.Phone;
                con.Email = u.Email;
                con.AccountId = [Select Id From Account Where SAP_Customer_Number__c = '13903' Limit 1].Id;
                System.debug('***'+con.AccountId);
                con.Is_Active__c ='Y';
                con.LeadSource = 'Direct';
                ContactTriggerHandler.TriggerDisabled = True;
                insert con;
                //Community User creation
                User portalAccountOwner1 = new User();
                portalAccountOwner1.Read_Only_User__c = True;
                portalAccountOwner1.ProfileId = profileId.id;
                portalAccountOwner1.Username = con.Email + System.now().millisecond();
                portalAccountOwner1.Alias = 'b2b'+System.now().millisecond();
                portalAccountOwner1.Email=con.Email;
                portalAccountOwner1.FederationIdentifier=con.Email;
                portalAccountOwner1.EmailEncodingKey='UTF-8';
                portalAccountOwner1.Firstname=con.FirstName;
                portalAccountOwner1.Lastname=con.LastName;
                portalAccountOwner1.LanguageLocaleKey='en_US';
                portalAccountOwner1.LocaleSidKey='en_US';
                portalAccountOwner1.TimeZoneSidKey='America/Chicago';
                portalAccountOwner1.ContactId=con.Id;
                portalAccountOwner1.Servicenow_Number__c= 'test';
                communityUsers.add(portalAccountOwner1);
            }
        }
        UserTriggerHandler.TriggerDisabled = True;
        if(communityUsers.size()>0){
            insert communityUsers;
        }
    }
    
    @future
    public static void deactivateCommunityUsers(Set<id> newUserIds){
        List<User> newUsers= [Select Id,FirstName,LastName,Phone,Email,Profile.Name,IsActive,ContactId From User Where Id IN :newUserIds];   
        Profile profileId = [select Id,name from Profile where Profile.Name =:System.Label.OCB_RegisterUserProfile limit 1];
        List<User> communityUsers = new List<User>();
        Set<String> communityUsersEmails = new Set<String>();
        for(User u :newUsers){
            communityUsersEmails.add(u.Email);
        }
        communityUsers = [Select Id,FirstName,LastName,Phone,Email,Profile.Name,IsActive,ContactId,FederationIdentifier 
                          From User Where Email IN :communityUsersEmails AND ProfileId = :profileId.id];
        for(User comu :communityUsers){
            comu.IsActive = False;
            comu.FederationIdentifier = '';
        }
        try{
            UserTriggerHandler.TriggerDisabled = True;
            if(communityUsers.size()>0){
                update communityUsers;
            }
            
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    @future
    public static void deactivateCommunityContacts(Set<id> newUserIds){
        List<User> newUsers= [Select Id,FirstName,LastName,Phone,Email,Profile.Name,IsActive,ContactId From User Where Id IN :newUserIds];   
        Profile profileId = [select Id,name from Profile where Profile.Name =:System.Label.OCB_RegisterUserProfile limit 1];
        List<Contact> conListDeactivate = new List<Contact>();
        List<User> communityUsers = new List<User>();
        Set<String> communityUsersEmails = new Set<String>();
        Set<Id> communityContactIds = new Set<Id>();
        for(User u :newUsers){
            communityUsersEmails.add(u.Email);
        }
        communityUsers = [Select Id,FirstName,LastName,Phone,Email,Profile.Name,IsActive,ContactId,FederationIdentifier 
                          From User Where Email IN :communityUsersEmails AND ProfileId = :profileId.id];
        for(User comu :communityUsers){
            communityContactIds.add(comu.ContactId);
        }
        conListDeactivate = [Select Id,Is_Active__c,Inactive_Reason__c From Contact Where id IN :communityContactIds];
        for(Contact con :conListDeactivate){
            con.Is_Active__c = 'N';
            con.Inactive_Reason__c = '06';
        }
        try{
            ContactTriggerHandler.TriggerDisabled = True;
            if(conListDeactivate.size()>0){
                update conListDeactivate;
            }
            
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    public static Map<String,String> getPickListMap(Schema.DescribeFieldResult pickList){
        Map<String,String> pickListMap = new Map<String,String>();
        List<Schema.PicklistEntry> pickListvalues = pickList.getPicklistValues();     
        for( Schema.PicklistEntry v : pickListvalues) {
            pickListMap.put(v.getValue(),v.getLabel());        
        }
        return pickListMap;
    }
    Public User_Field_History__c createUpdateHistory2(String field, string oldusr, string newusr, User usr) {//IBA-3262 Start
        User_Field_History__c usrHistory = new User_Field_History__c();
        usrHistory.User__c = usr.Id;
        usrHistory.Field__c = field;
        usrHistory.Updated_by_User__c = UserInfo.getUserId(); 
        usrHistory.Date__c = Datetime.now();
        if (oldusr != null) usrHistory.ORIGINAL_VALUE__c = oldusr;
        if (newusr != null) usrHistory.NEW_VALUE__c = newusr;
        return usrHistory;
    }//IBA-3262 End
    
    public class UserHistoryTrack1 implements Queueable{//IBA-3262 Start for insert and update user history records(To avoid the Mixed DML exception)
        List <User_Field_History__c> uh;
        public UserHistoryTrack1(List <User_Field_History__c> uh){
            this.uh=uh;
        }
        public void execute(QueueableContext context) {
            try {
                insert uh;
            }
            catch(Exception e) {
                system.debug(e);
            }
        }
    }//IBA-3262 End
}