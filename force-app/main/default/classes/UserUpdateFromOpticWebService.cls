/*
End Point: https://omnicell--fulldev.sandbox.my.salesforce.com/services/apexrest/updateUserFromOptic
Method: POST
Test Class: UserUpdateFromOpticWebServiceTest
*/
@RestResource(urlMapping='/updateUserFromOptic/*')
global with sharing class UserUpdateFromOpticWebService {
    @HttpPost
    global Static void post()
    {
        RestRequest request= RestContext.request;
        RestResponse response= RestContext.response;
        
        String requestBody= request.requestBody.toString().trim();
        System.debug('requestBody-->'+requestBody);
       
        try
        {
            if(requestBody == NULL || requestBody == '')
            {
                response.statusCode = 400;
                response.responseBody=blob.valueOf('Invalid Request Body');
            }
            else
            {
                List<cls_wrapper> clsList = (List<cls_wrapper>)JSON.deserialize(requestBody, List<cls_wrapper>.class);
                system.debug('clsList-->'+clsList);
                
                if(clsList == NULL || clsList.size() == 0)
                {
                    response.statusCode = 400;
                    response.responseBody=blob.valueOf('Invalid Request Body');
                }
                else
                {
                    Map<String, cls_wrapper> userJSONMap 	= new Map<String, cls_wrapper>();
                    Map<Id, User> userMap 					= new Map<Id, User>();
                    Map<String, User> managerMap 			= new Map<String, User>();
                    Map<id, UserLogin> userLoginMap 		= new Map<id, UserLogin>();
                    Map<Integer, cls_wrapper> coveredPersonMap	= New Map<Integer, cls_wrapper>();
                    List<String> managerList 				= new List<String>();
                    List<User> updateUserList				= new List<User>();
                    List<UserLogin> updateUserLoginList 	= new List<UserLogin>();
                    List<User_Field_History__c> uhistory 	= new List <User_Field_History__c>();
                    Boolean isSandbox = [Select IsSandbox from Organization limit 1].IsSandbox;
                    
                    for(cls_wrapper cls : clsList)
                    {
                        //if(cls.formattedSalesforceUserRecordId <> NULL && cls.formattedSalesforceUserRecordId <> '')
                        if(cls.salesforceUserRecordId <> NULL && cls.salesforceUserRecordId <> '' && cls.salesforceUserRecordId.startsWith('005'))
                        {
                            userJSONMap.put(Id.valueOf(cls.salesforceUserRecordId), cls);
                            if(cls.IsCovered <> NULL)
                            {
                                coveredPersonMap.put(Integer.valueOf(cls.OmnicellEmployeeNumber), cls);
                            }
                            if(cls.Manager <> NULL && cls.Manager <> '')
                                managerList.add(cls.Manager);
                        }
                    }
                    
                    system.debug('managerList-->'+managerList);
                    system.debug('userJSONMap-->'+userJSONMap);
                    
                    if(!managerList.isEmpty())
                    {
                        for(User usr : [SELECT id, omnicell_employee_number__c FROM user 
                                        WHERE omnicell_employee_number__c IN :managerList])
                        {
                            managerMap.put(usr.omnicell_employee_number__c, usr);
                        }
                    }
                    system.debug('managerMap-->'+managerMap);
                    
                    userMap = new Map<Id, User>([SELECT id, username, lastname, alias, communitynickname, firstname, federationidentifier, 
                                                 employeenumber, omnicell_employee_number__c, title, department, companyname, cost_center__c, 
                                                 crm_login__c, city, postalcode, phone, isactive, MobilePhone, Street, ManagerId, Manager_Name__c, 
                                                 Manager_Email__c, LastModifiedDate, Email, CountryCode, Do_not_deactivate__c, Term_Date__c
                                                 FROM user
                                                 WHERE id IN :userJSONMap.keySet()
                                                 AND profile.name <> 'Omnicell B2B Storefront Profile'
                                                 AND isActive = TRUE]);
                    system.debug('userMap-->'+userMap);
                    
                    if(userMap.size() > 0)
                    {
                        for(UserLogin ul : [SELECT id, isFrozen, userId FROM UserLogin WHERE userId IN :userMap.keySet()])
                        {
                            userLoginMap.put(ul.userId, ul);
                        }
                        system.debug('userLoginMap-->'+userLoginMap);
                        
                        for(User usr : userMap.values())
                        {
                            try
                            {
                                String isFrozenOldVal = String.valueOf(userLoginMap.get(usr.id).isFrozen);
                                cls_validateReturn cls_ret = validateUserIsActive(usr, userJSONMap.get(usr.id), userLoginMap.get(usr.id));
                                
                                if(cls_ret.isULChange)
                                {
                                    uhistory.add(createUserFieldHistory('isFrozen', isFrozenOldVal, String.valueOf(cls_ret.ul.isFrozen), usr.Id));
                                    updateUserLoginList.add(cls_ret.ul);
                                }
                                
                                usr = cls_ret.usr;
                                
                                if(checkValidUsername(userJSONMap.get(usr.id).Email)){
                                    //IBA-4976 Starts SH
                                    EmailAliasEAC__c emailAlias = EmailAliasEAC__c.getValues(usr.Email);
                                    if(emailAlias == null){
                                        usr.Email = userJSONMap.get(usr.id).Email + ((isSandbox && !usr.Email.endsWithIgnoreCase('.invalid')) ? '.invalid' : ''); //Existing Code
                                    }
                                    //IBA-4976 Ends SH
                                }
                                
                                usr.LastName = userJSONMap.get(usr.id).LastName;
                                String nickName = userJSONMap.get(usr.id).CommunityNickname;
                                if(nickName <> NULL && nickName <> '' && nickName.length() > 40)
                                {
                                    nickName = nickName.subString(0,40);
                                }
                                usr.CommunityNickname = nickName;
                                usr.FirstName = userJSONMap.get(usr.id).FirstName;
                                usr.EmployeeNumber = userJSONMap.get(usr.id).EmployeeNumber;
                                usr.Omnicell_Employee_Number__c = userJSONMap.get(usr.id).OmnicellEmployeeNumber;
                                usr.Title = userJSONMap.get(usr.id).Title;
                                usr.Department = userJSONMap.get(usr.id).Department;
                                usr.CompanyName = userJSONMap.get(usr.id).CompanyName;
                                usr.Cost_Center__c = userJSONMap.get(usr.id).CostCenter;
                                usr.City = userJSONMap.get(usr.id).City;
                                usr.CountryCode = userJSONMap.get(usr.id).countryCode;
                                usr.StateCode = userJSONMap.get(usr.id).State == 'Victoria' ? 'VIC' : userJSONMap.get(usr.id).State;
                                usr.PostalCode = userJSONMap.get(usr.id).PostalCode;
                                usr.Phone = userJSONMap.get(usr.id).Phone;
                                usr.MobilePhone = userJSONMap.get(usr.id).MobilePhone;
                                usr.Street = userJSONMap.get(usr.id).Street;
                                usr.ManagerId = managerMap.containsKey(userJSONMap.get(usr.id).Manager) ? managerMap.get(userJSONMap.get(usr.id).Manager).id : NULL;//userJSONMap.get(usr.id).Manager;
                                usr.Manager_Name__c = userJSONMap.get(usr.id).ManagerName;
                                usr.Term_Date__c = userJSONMap.get(usr.id).termDate <> NULL ? date.parse(userJSONMap.get(usr.id).termDate) : null;
                                
                                if(userJSONMap.get(usr.id).ManagerEmail <> NULL && userJSONMap.get(usr.id).ManagerEmail <> '' 
                                   && checkValidUsername(userJSONMap.get(usr.id).ManagerEmail))
                                {
                                    usr.Manager_Email__c = userJSONMap.get(usr.id).ManagerEmail;
                                }
                                
                                if(cls_ret.ul.isFrozen && usr.Term_Date__c <> NULL)
                                {
                                    if(usr.Term_Date__c.year() == 2999)
                                        usr.Do_not_deactivate__c = true;
                                    else
                                        usr.Do_not_deactivate__c = false;
                                }
                                
                                updateUserList.add(usr);
                            }
                            catch(Exception ex)
                            {
                                saveErrorLogException(ex.getMessage(),'UserUpdateFromOpticWebService->saveErrorLogException->Error occur while processing user: '+userJSONMap.get(usr.id).Email, 'RestResource',JSON.serialize(userJSONMap.get(usr.id)));
                            }
                        }
                        
                        system.debug('updateUserList-->'+updateUserList);
                        
                        if(!updateUserList.isEmpty())
                            update updateUserList;
                        
                        if(!updateUserLoginList.isEmpty())
                        {
                            update updateUserLoginList;
                            system.enqueueJob(new UserTriggerHandler.UserHistoryTrack1(uhistory));
                        }
                        //Commented below line because of covered person issue
                        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('CoveredPersonInOpticIntegration');
                        if(!tc.IsDisabled__c)
                        {
                            processCoveredPersonObject(coveredPersonMap);
                        }
                        response.statusCode = 200;
                        response.responseBody=blob.valueOf('Success');
                    }
                    else
                    {
                        saveErrorLogException('No Users found','UserUpdateFromOpticWebService->saveErrorLogException->No Users found Catch Block','RestResource',requestBody);
                        response.statusCode = 400;
                        response.responseBody = blob.valueOf('No Users found');
                    }
                }
            }
        }
        catch(Exception ex)
        {
            system.debug('inside catch-->'+ex.getMessage());
            saveErrorLogException(ex.getMessage(),'UserUpdateFromOpticWebService->saveErrorLogException->Catch Block','RestResource',requestBody);
            response.statusCode = 400;
            response.responseBody = blob.valueOf(ex.getMessage());
        }
        /*finally
        {
            system.debug('inside finally--errorLogsList-->'+errorLogsList.size()+'::'+errorLogsList);
            if(!errorLogsList.isEmpty())
                insert errorLogsList;
        }*/
    }
    //Commented below method because of covered person issue
    
    public static void processCoveredPersonObject(Map<Integer, cls_wrapper> coveredPersonMap)
    {
        system.debug('coveredPersonMap-->'+coveredPersonMap);
        Map<Integer, Covered_Person__c> existingCPMap 	= new Map<Integer, Covered_Person__c>();
        List<Covered_Person__c> insertCPLst 			= new List<Covered_Person__c>();
        List<Covered_Person__c> deleteCPLst 			= new List<Covered_Person__c>();
        
        for(Covered_Person__c cp : [Select Id, Omnicell_Employee_Number__c,Status__c from Covered_Person__c where  Omnicell_Employee_Number__c IN :coveredPersonMap.keyset()])
        {
            existingCPMap.put(Integer.valueof(cp.Omnicell_Employee_Number__c), cp);
        }
        
        system.debug('existingCPMap-->'+existingCPMap);
            
        for(Integer employeeNum : coveredPersonMap.keySet())
        {
            if(existingCPMap.containsKey(employeeNum) && !coveredPersonMap.get(employeeNum).IsCovered)
            {
                deleteCPLst.add(existingCPMap.get(employeeNum));
            }
            else if(!existingCPMap.containsKey(employeeNum) && coveredPersonMap.get(employeeNum).IsCovered)
            {
                Covered_Person__c cp = new Covered_Person__c();
                cp.Status__c = coveredPersonMap.get(employeeNum).IsCovered;
                cp.Omnicell_Employee_Number__c = employeeNum;
                cp.First_Name__c = coveredPersonMap.get(employeeNum).FirstName;
                cp.Last_Name__c = coveredPersonMap.get(employeeNum).LastName;
                cp.Email__c = coveredPersonMap.get(employeeNum).Email;
                cp.userId__c = coveredPersonMap.get(employeeNum).Email;
                insertCPLst.add(cp);
            }
            else if(existingCPMap.containsKey(employeeNum) && coveredPersonMap.get(employeeNum).IsCovered)
            {
                //DO NOTHING as Covered_Person__c holds only records if Status = TRUE
            }
        }
        system.debug('deleteCPLst-->'+deleteCPLst);
        if(!deleteCPLst.isEmpty())
        {
            delete deleteCPLst;
        }
        
        system.debug('insertCPLst-->'+insertCPLst);
        if(!insertCPLst.isEmpty())
        {
            insert insertCPLst;
        }
    }
    
    public Static cls_validateReturn validateUserIsActive(User usr, cls_wrapper cls_usr, UserLogin ul)
    { 
        system.debug('usr-->'+usr);
        system.debug('cls_usr-->'+cls_usr);
        system.debug('ul-->'+ul);
        
        cls_validateReturn cls_ret = new cls_validateReturn();
        date fortyFiveDaysOldDate = date.today().adddays(-45);
        
        //Optic Status != ACTIVE and isFrozen = FALSE and isaCTIVE = TRUE, then set isFrozen = TRUE – Freezing user
        if(!cls_usr.IsActive && !ul.IsFrozen && usr.IsActive)
        {
            ul.isFrozen = true;
            cls_ret.isULChange = true;
        }
        //If Optic Status != ACTIVE and IsFreeze = true and isActive = true, lastmodifieddate >= 45days and donotdeactivate=false then make isActive = false – deactivating user(will also be done in nightly job)
        else if(!cls_usr.IsActive && ul.IsFrozen && usr.IsActive && usr.LastModifiedDate <= fortyFiveDaysOldDate && !usr.Do_not_deactivate__c)
        {
            //Commenting below line because 45days daily batch will handle deactivating users
            //usr.IsActive = false;
        }
        //Optic Status = ACTIVE and isFrozen = TRUE and isActive = true and LastModifiedDate < 45days, then set isFrozen = FALSE
        else if(cls_usr.IsActive && ul.IsFrozen && usr.IsActive && usr.LastModifiedDate > fortyFiveDaysOldDate)
        {
            ul.isFrozen = false;
            cls_ret.isULChange = true;
        }

        cls_ret.usr = usr;
        cls_ret.ul = ul;
        
        return cls_ret;
    }
    
    public Static Boolean checkValidUsername(String emailAddress)
    {
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        Matcher MyMatcher = MyPattern.matcher(emailAddress);
        
        if(MyMatcher.matches()){
            return true;
        }else{
            return false;
        }
    }
    
    @future
    public static void saveErrorLogException(String errorMessage, String errorLocation, String errorType, String JSON)
    {
        //Send Email to Sys Admin
        insert ErrorLogging.RestResourceLog(errorMessage, errorLocation,errorType,JSON);
    }
    
    Public static User_Field_History__c createUserFieldHistory(String fieldName, string oldValue, string newValue, Id usrId) 
    {
        User_Field_History__c usrHistory = new User_Field_History__c();
        usrHistory.User__c = usrId;
        usrHistory.Field__c = fieldName;
        usrHistory.Updated_by_User__c = UserInfo.getUserId(); 
        usrHistory.Date__c = Datetime.now();
        usrHistory.ORIGINAL_VALUE__c = oldValue;
        usrHistory.NEW_VALUE__c = newValue;
        return usrHistory;
    }
    
    public class cls_wrapper
    {
        public String salesforceUserRecordId;
        public Id formattedSalesforceUserRecordId;
        public String Email;
        public String LastName;
        public String CommunityNickname;
        public String FirstName;
        public String EmployeeNumber;
        public String OmnicellEmployeeNumber;
        public String Title;
        public String Department;
        public String CompanyName;
        public String CostCenter;
        public String City;
        public String State;
        public String CountryCode;
        public String PostalCode;
        public String Phone;
        public Boolean IsActive;
        public String MobilePhone;
        public String Street;
        public String Manager;
        public String ManagerName;
        public String ManagerEmail;
        public Boolean IsCovered;
        public String termDate;
    }
    
    public class cls_validateReturn
    {
        public User usr;
        public Boolean isULChange = false;
        public UserLogin ul;
    }
}

/*
 * SAMPLE JSON BODY
 */
/*
[
  {
    "salesforceUserRecordId": "0051N000007IZgPQAW",
    "Email": "zz_Heidi.Grossweiler@omnicell.com.dev",
    "LastName": "Grossweiler",
    "CommunityNickname": "4193HeidiHeidi.Grossweiler",
    "FirstName": "Heidi",
    "EmployeeNumber": "4193",
    "OmnicellEmployeeNumber": "4193",
    "Title": "Sr. Manager, Executive Briefing Program",
    "Department": "540005 - Field Employee Training",
    "CompanyName": "Omnicell, Inc.",
    "CostCenter": "540005",
    "City": "Fort Worth",
    "State": "TX",
    "CountryCode": "US",
    "PostalCode": "76137",
    "Phone": "",
    "IsActive": false,
    "IsCovered": false,
    "MobilePhone": "320-1471",
    "Street": "4220 North Freeway",
    "Manager": "4191",
    "ManagerName": "Nicole Burke",
    "ManagerEmail": "zz_nicole.burke@omnicell.com.dev",
    "termDate": "12/31/2024"
  },
  {
    "salesforceUserRecordId": "0053l00000HZAuGAAX",
    "Email": "zz_Patrick.Stang@omnicell.com.dev",
    "LastName": "Stang",
    "CommunityNickname": "15305PatrickPatrick.Stang",
    "FirstName": "Patrick",
    "EmployeeNumber": "15305",
    "OmnicellEmployeeNumber": "15305",
    "Title": "Product Data Manager",
    "Department": "560610 - Pricing PMM",
    "CompanyName": "Omnicell, Inc.",
    "CostCenter": "560610",
    "City": "Santa Clara",
    "PostalCode": "95054",
    "Phone": "",
    "IsActive": true,
    "IsCovered": false,
    "MobilePhone": "",
    "Street": "2625 Augustine Drive",
    "Manager": "4048",
    "ManagerName": "Buffy Bales",
    "ManagerEmail": "zz_buffy.bales@omnicell.com.dev",
    "termDate": "12/31/2024"
  }
]
*/