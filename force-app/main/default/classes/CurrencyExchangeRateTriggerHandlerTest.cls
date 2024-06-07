@IsTest
public class CurrencyExchangeRateTriggerHandlerTest {
    @TestSetup
    static void setupTestData() {
        Trigger_Configuration__c tc = new Trigger_Configuration__c();
        tc.Name = 'CurrencyExchangeRateTrigger';
        tc.IsDisabled__c = false;
        insert tc;
    }
    @isTest
    static void testBeforeInsertWithDuplicateCurrency() {
        // Create an active currency exchange rate with the same currency code
        Currency_Exchange_Rate__c existingRate = new Currency_Exchange_Rate__c(
            CurrencyIsoCode = 'USD',
            M1_Exchange_Rate__c = 0.12525,
            Quarter_Period__c = 'Q1 (First Quarter)',
            Status__c = 'Active');
        insert existingRate;
        Currency_Exchange_Rate__c newRate1 = new Currency_Exchange_Rate__c(
            CurrencyIsoCode = 'USD',
            M1_Exchange_Rate__c = 0.12525,
            Quarter_Period__c = 'Q1 (First Quarter)',
            Status__c = 'Active');
        Currency_Exchange_Rate__c newRate2 = new Currency_Exchange_Rate__c(
            CurrencyIsoCode = 'EUR',
            M1_Exchange_Rate__c = 0.11145,
            Quarter_Period__c = 'Q1 (First Quarter)',
            Status__c = 'Active');
        List<Currency_Exchange_Rate__c> newRates = new List<Currency_Exchange_Rate__c>{newRate1, newRate2};
        Test.startTest();
        Database.SaveResult[] results = Database.insert(newRates, false);
        Test.stopTest();
        System.assertEquals(false, results[0].isSuccess());
        System.assertEquals('A record with the same Currency and Status set to Active already exists.', results[0].getErrors()[0].getMessage());
        System.assertEquals(true, results[1].isSuccess());
    }
}