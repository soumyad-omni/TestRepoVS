@isTest
public class LoginAsAccessControllerTest {
    Public static String modifyallPermId;
    Public static boolean method1;
    Public static boolean method2;
    
    @testsetup
    static void testdatasetup(){
        LoginAsPermission__c setting12 = new LoginAsPermission__c();
        setting12.Name='ABC';
        setting12.id__c = '0PS8a000001ZFGvGAO';
        insert setting12;
        modifyallPermId = setting12.id__c;
        
        LoginAsAccessEmailSettings__c email10 = new LoginAsAccessEmailSettings__c();
        email10.Name='loginAsAccessEmail';
        email10.to__c ='pabitra.tripathy@omnicell.com';
        email10.body__c='[salesforce login-as req] UserID:';
        email10.subject__c='The user requested for Login As access';
        insert email10;
    }
    
    public static testMethod void testlogin1(){
        Test.StartTest();
        method1=LoginAsAccessController.grantLoginAsAccess();
        method2=LoginAsAccessController.isLoginAccessPermAssigned();
        Test.stopTest();
    }
    
    public static testMethod void testschedule() {
        UserTriggerHandler.TriggerDisabled=true;
        Profile pf= [Select Id from profile where Name='Business Administrator']; 
        UserRole ur = [Select Id from UserRole where Name='Covered'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         IsActive = False,
                         UserPermissionsInteractionUser =true,
                         UserPermissionsMarketingUser = true,
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23),
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         ProfileId = pf.Id,
                         UserRoleId=ur.Id); 
        insert uu;
        
        integer resetDuration=24;
        Datetime nextResetTime = Datetime.now().addHours(resetDuration);           
        String dayOfWeekString = nextResetTime.format('u'); // 'u' extract day (1-7 for mon-sun)
        Integer dayOfWeek = Integer.valueOf(dayOfWeekString);
        String ss = String.valueOf(nextResetTime.second());
        String min = String.valueOf(nextResetTime.minute());
        String hour = String.valueOf(nextResetTime.hour());
        String day = String.valueOf(nextResetTime.day());
        String month = String.valueOf(nextResetTime.month());
        String year = String.valueOf(nextResetTime.year());			
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month + ' ? '+year; 
            
        Test.StartTest();
        ScheduleLoginAsPermOff schLoginAsOff=new ScheduleLoginAsPermOff(modifyallPermId,uu.Id);
        System.schedule('LoginAsRmvPermSetSch'+nextFireTime, nextFireTime, schLoginAsOff);
        LoginAsAccessController.sendEmail(uu.Email);
        Test.stopTest(); 
    } 
}