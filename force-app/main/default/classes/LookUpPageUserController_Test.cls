@isTest
public class LookUpPageUserController_Test {
    public static testmethod void lookUpPageUserControllerTest(){
        User u = TestDataFactory.createUser(True, 'Test_', 'IBA-1993');
        u.IsActive = true;
        update u;
        User u2 = TestDataFactory.createSalesUser(True, 'Test_2_', 'IBA-1993_2');
        Test.startTest();
            PageReference pageRef = Page.LookUpPageUser;
            pageRef.getParameters().put(u.id, u.name);
        	pageRef.getParameters().put(u2.id, u2.name);
            
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageUserController lpc = new LookUpPageUserController();
            lpc.getlistUsers();
        test.stopTest();
    }
}