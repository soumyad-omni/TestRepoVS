@istest
public class SCP_AG_PL_Webservice_test {

    @istest
    public static void SCP_AG_PL_Webservice_testMethod(){
        //req = '{"AGPLS":{"ccrz__E_AccountGroup__c":{}}}';
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        string accountId = acc.Id;
    
     	RestRequest req = new RestRequest();
        String reqBody = '{"AGPLS":{"ccrz__E_AccountGroup__c":[{"name":"test123","ccrz__AccountGroupID__c":"12345","ccrz__PriceListSelectionMethod__c":"test","CurrencyIsoCode":"USD","accountid":"'+accountId+'","CHILD":{"ccrz__E_AccountGroupPriceList__c":[{"ccrz__AccountGroup__c":"12345","ccrz__Pricelist__c":"123","PLNAME":"test","ccrz__Sequence__c":"123","ccrz__AccountGroupPriceListID__c":"test","ccrz__Enable__c":"true","ccrz__StartDate__c":"2021-01-01","ccrz__EndDate__c":"2021-02-02"}]}}]}}';
        req.requestBody=Blob.valueof(reqBody);

        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/accountgroup'; //Request URL
        req.httpMethod = 'POST';
    
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        	SCP_AG_PL_Webservice.post();
        Test.stopTest();
    }
}