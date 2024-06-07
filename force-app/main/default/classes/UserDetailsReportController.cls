//Test Class: UserDetailsReportControllerTest
public class UserDetailsReportController
{
    @AuraEnabled
    public static List<cls_wrapper> getUserDetails()
    {
        Map<Id, UserLogin> isFrozenMap = new Map<Id, UserLogin>();
        List<cls_wrapper> ret_cls = new List<cls_wrapper>();
        
        for(UserLogin ul : [SELECT id, isFrozen, userId,lastModifieddate FROM UserLogin WHERE isFrozen = TRUE])
        {
            isFrozenMap.put(ul.UserId, ul);
        }
        
        ret_cls = getUserWrapperDetails(isFrozenMap);
        return ret_cls;
    }
    
    public static List<cls_wrapper> getUserWrapperDetails(Map<Id, UserLogin> isFrozenMap)
    {
        List<cls_wrapper> ret_cls = new List<cls_wrapper>();
        Map<Id, User> userMap = New Map<Id, User>([SELECT id, FirstName, LastName, isActive, Profile.name, Term_date__c,
                                                   Omnicell_Employee_Number__c, Manager.FirstName, Manager.LastName, 
                                                   Do_not_deactivate__c
                                                   FROM User
                                                   WHERE profile.name <> 'Omnicell B2B Storefront Profile' 
                                                   AND isActive = TRUE
                                                   AND id IN :isFrozenMap.keyset()
                                                   ORDER BY FirstName, LastName asc]);
        
        for(User usr : UserMap.Values())
        {
            ret_cls.add(new cls_wrapper(usr, isFrozenMap.get(usr.id)));
        }
        ret_cls.sort();
        return ret_cls;
    }
    
    public class cls_wrapper implements Comparable
    {
        @AuraEnabled public String UserId;
        @AuraEnabled public String Name;
        @AuraEnabled public String ManagerName;
        @AuraEnabled public String ProfileName;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public String isFrozen;
        @AuraEnabled public String dateFrozen;
        @AuraEnabled public Integer daysFrozen;
        @AuraEnabled public String termDate;
        @AuraEnabled public String adstatus;
        @AuraEnabled public Integer termToFrozen;
        @AuraEnabled public String doNotDeactivate;
        
        public cls_wrapper(User usr, UserLogin ul)
        {
            UserId = usr.Id;
            Name = (usr.FirstName == NULL ? '' : usr.FirstName) + ' ' + (usr.LastName == NULL ? '' : usr.LastName) + (usr.Omnicell_Employee_Number__c == NULL ? '' : ' - ' + usr.Omnicell_Employee_Number__c);
            ManagerName = (usr.Manager.FirstName == NULL ? '' : usr.Manager.FirstName) + ' ' + (usr.Manager.LastName == NULL ? '' : usr.Manager.LastName);
            ProfileName = usr.Profile.Name;
            isActive = usr.isActive;
            isFrozen = 'Frozen';
            Datetime dt = ul.lastmodifieddate;
            dateFrozen = date.newinstance(dT.year(), dT.month(), dT.day()).format();
            daysFrozen = (ul.lastmodifieddate.date()).daysBetween(system.today());
            if(usr.Term_date__c.year() == 2999)
            {
                adstatus =  'LOA';
            }
            else
            {
                termDate = date.newinstance(usr.Term_date__c.year(), usr.Term_date__c.month(), usr.Term_date__c.day()).format();
                termToFrozen = (usr.Term_date__c).daysBetween(Date.valueOf(date.newinstance(dT.year(), dT.month(), dT.day())));
                adstatus =  'Terminated';
            }
            doNotDeactivate = (usr.Do_not_deactivate__c ? 'Do not De-activate' : '');
        }
        
        public Integer compareTo(Object ObjToCompare) 
        {
            Integer otherDaysFrozen = ((cls_wrapper)ObjToCompare).daysFrozen;
            return daysFrozen < otherDaysFrozen ? -1 : (daysFrozen == otherDaysFrozen ? 0 : 1);
        }
    }
}