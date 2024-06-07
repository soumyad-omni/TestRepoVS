@isTest
public class DatedConversionRateMailSchedulerTest {
    @testsetup
    static void testdatasetup(){
        List<EmailRecipientITSupport__c> EmailRecipientsList = new List<EmailRecipientITSupport__c>();
        EmailRecipientITSupport__c emailrecipient = new EmailRecipientITSupport__c();
        emailrecipient.Name= 'IT Support';
        emailrecipient.Email__c= 'aloha_integration_errors@omnicell.com';
        EmailRecipientsList.add(emailrecipient);
        EmailRecipientITSupport__c emailrecipient1 = new EmailRecipientITSupport__c();
        emailrecipient1.Name= 'Saptarsha Panthi';
        emailrecipient1.Email__c= 'Saptarsha.panthi@omnicell.com';
        EmailRecipientsList.add(emailrecipient1);
        insert EmailRecipientsList;
        
        List<CurrencyIsoCodeforExchangeRate__c> CurrenciesIsoCodeRateList = new List<CurrencyIsoCodeforExchangeRate__c>();
        CurrencyIsoCodeforExchangeRate__c Iso1 = new CurrencyIsoCodeforExchangeRate__c();
        Iso1.name='AED';
        CurrenciesIsoCodeRateList.add(Iso1);
        
        CurrencyIsoCodeforExchangeRate__c Iso2 = new CurrencyIsoCodeforExchangeRate__c();
        Iso2.name='AUD';
        CurrenciesIsoCodeRateList.add(Iso2);
        
        CurrencyIsoCodeforExchangeRate__c Iso3 = new CurrencyIsoCodeforExchangeRate__c();
        Iso3.name='CAD';
        CurrenciesIsoCodeRateList.add(Iso3);
        
        CurrencyIsoCodeforExchangeRate__c Iso4 = new CurrencyIsoCodeforExchangeRate__c();
        Iso4.name='INR';
        CurrenciesIsoCodeRateList.add(Iso4);
        
        CurrencyIsoCodeforExchangeRate__c Iso5 = new CurrencyIsoCodeforExchangeRate__c();
        Iso5.name='CHF';
        CurrenciesIsoCodeRateList.add(Iso5);
        
        CurrencyIsoCodeforExchangeRate__c Iso6 = new CurrencyIsoCodeforExchangeRate__c();
        Iso6.name='CNY';
        CurrenciesIsoCodeRateList.add(Iso6);
        
        CurrencyIsoCodeforExchangeRate__c Iso7 = new CurrencyIsoCodeforExchangeRate__c();
        Iso7.name='EUR';
        CurrenciesIsoCodeRateList.add(Iso7);
        
        CurrencyIsoCodeforExchangeRate__c Iso8 = new CurrencyIsoCodeforExchangeRate__c();
        Iso8.name='GBP';
        CurrenciesIsoCodeRateList.add(Iso8);
        
        CurrencyIsoCodeforExchangeRate__c Iso9 = new CurrencyIsoCodeforExchangeRate__c();
        Iso9.name='HKD';
        CurrenciesIsoCodeRateList.add(Iso9);
        
        insert CurrenciesIsoCodeRateList;
    }
    public static testMethod void testschedule() {
        Test.StartTest();
        DatedConversionRateMailScheduler sh1 = new DatedConversionRateMailScheduler();
        String sch = '0 0 0 ? * SUN'; 
        system.schedule('DatedConversionRateMailScheduler Job', sch, sh1); 
        Test.stopTest(); 
    }
}