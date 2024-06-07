@isTest
public class getCasesFromPandoraTest 
{
    public static testmethod void method1()
    {
        Pandora_Endpoint_Details__c cs = New Pandora_Endpoint_Details__c();
        cs.Name ='Pandora';
        cs.Client_Id__c = '123';
        cs.Client_Secret__c = '123';
        cs.UserName__c = '123@omnicell.com';
        cs.Password__c = '123';
        insert cs;
        getCasesFromPandora.createPandoraProducts();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new pandoraMockDataTest());
        getCasesFromPandora.getCases();
        getCasesFromPandora.insertMoreCase('[{"records":[{"Id":"123"}]}]');
        test.stopTest();
    }
}