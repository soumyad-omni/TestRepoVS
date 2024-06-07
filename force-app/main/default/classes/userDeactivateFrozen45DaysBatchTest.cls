@isTest
public class userDeactivateFrozen45DaysBatchTest 
{
    @isTest public static void method1()
    {
        Id profId = [SELECT id FROM Profile WHERE name = 'System Administrator'].Id;
        
        User usr = new User();
        usr.FirstName = 'Optic';
        usr.LastName = 'Integration';
        usr.Alias = 'optic';
        usr.Email = 'test.optic@omnicell.com';
        usr.UserName = 'test.optic@omnicell.com';
        usr.ProfileId = profId;
        usr.EmailEncodingKey='UTF-8';
        usr.LanguageLocaleKey='en_US';
        usr.LocaleSidKey='en_US';
        usr.TimeZoneSidKey='America/Los_Angeles';
        UserTriggerHandler.TriggerDisabled = True;
        insert usr;
        
        UserLogin ul = [SELECT Id, isfrozen FROM UserLogin WHERE userId = :usr.Id];
        ul.isfrozen = true;
        update ul;
        
        test.startTest();
        userDeactivateFrozen45DaysBatch sc = new userDeactivateFrozen45DaysBatch();
        sc.execute(null);
        test.stopTest();
    }
}