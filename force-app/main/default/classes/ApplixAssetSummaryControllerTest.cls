@isTest
private class ApplixAssetSummaryControllerTest {

    private static testMethod void test() {
        Default_Currency_by_Country_Code__c currencyCode = new Default_Currency_by_Country_Code__c(Name = 'AZ', Currency_Code__c = 'USD');
        insert currencyCode;
        accountTriggerHandler.TriggerDisabled = true;
        Account objAccount = new Account(Name = 'Test Account', Account_Role__c = 'ZCSN', BillingStreet = '330 Brookline Avenue', BillingCity = 'Boston', Validation_Status__c = 'Validated',
                                         BillingPostalCode = '2215', BillingCountryCode = 'AZ', SAP_Account_ID__c = '310210',Facility_Type__c = 'Short-term Acute Care Hospital');
        insert objAccount;
        
        List<Applix_Assets__c> lstApplixAsset = new List<Applix_Assets__c>{
                                                                            new Applix_Assets__c(Account__c = objAccount.Id, Category__c = 'AcuDose-Rx®'),
                                                                            new Applix_Assets__c(Account__c = objAccount.Id, Category__c = 'AcuDose-Rx®'),
                                                                            new Applix_Assets__c(Account__c = objAccount.Id, Category__c = 'Admin-Rx'),
                                                                            new Applix_Assets__c(Account__c = objAccount.Id, Category__c = 'Admin-Rx'),
                                                                            new Applix_Assets__c(Account__c = objAccount.Id, Category__c = 'Admin-Rx'),
                                                                            new Applix_Assets__c(Account__c = objAccount.Id, Category__c = 'Admin-Rx')
                                                                          };
        insert lstApplixAsset; 
        ApplixAssetSummaryController.getApplixAssetSummarys(objAccount.Id);
    }

}