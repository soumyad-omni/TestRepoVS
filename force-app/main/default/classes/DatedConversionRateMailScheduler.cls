/*********************************************************************
Jira Number: IBA-6001
Name:        DatedConversionRateMailScheduler
Test Class:  DatedConversionRateMailSchedulerTest
Purpose:     This class is used to send email alert to the IT support team if the currencies are not updated for the day OR if the currency rate has not changed between subsequent days.
=======================================================================
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Saptarsha Panthi        05/29/2024            Initial Creation
************************************************************************/
public class DatedConversionRateMailScheduler implements Schedulable{
    public void execute(SchedulableContext SC) {
        
        List<DatedConversionRate> DCRList = [SELECT ConversionRate,CreatedById,CreatedDate,Id,IsoCode,LastModifiedBy.Name,LastModifiedDate,NextStartDate,StartDate 
                                             FROM DatedConversionRate Where StartDate = LAST_N_DAYS:2 ORDER BY StartDate DESC];
        Map<String, DatedConversionRate> DCRUpdateTodayMap = new Map<String, DatedConversionRate>();
        Map<String, DatedConversionRate> DCRUpdateYesterdayMap = new Map<String, DatedConversionRate>();
        List<String> CurrencyIsoCodeforExchangeRateList = new List<String>();
        List<CurrencyIsoCodeforExchangeRate__c> CurrencyIsoCodeList = [Select Name From CurrencyIsoCodeforExchangeRate__c];
        for(CurrencyIsoCodeforExchangeRate__c Isocode: CurrencyIsoCodeList){
            CurrencyIsoCodeforExchangeRateList.add(Isocode.Name);
        }
        //Map<String, DatedConversionRate> DCRUpdateDaybeforYesterdayMap = new Map<String, DatedConversionRate>();
        For(DatedConversionRate dcr: DCRList){
            if(dcr.StartDate==System.Today()){
                DCRUpdateTodayMap.put(dcr.IsoCode,dcr);
            }
            if(dcr.StartDate==System.Today()-1){
                DCRUpdateYesterdayMap.put(dcr.IsoCode,dcr);
            } 
        }
        
        List<String> CurrenciesNotUpdatedListToday = new List<String>();
        List<String> CurrencyisSameforSubsequentDays = new List<String>();
        For(String IsoCurrencyCode: CurrencyIsoCodeforExchangeRateList){
            if(DCRUpdateTodayMap.get(IsoCurrencyCode)==null){
                CurrenciesNotUpdatedListToday.add(IsoCurrencyCode);
            }
            else{
                if(DCRUpdateYesterdayMap.get(IsoCurrencyCode)!=null && (DCRUpdateTodayMap.get(IsoCurrencyCode).ConversionRate == DCRUpdateYesterdayMap.get(IsoCurrencyCode).ConversionRate)){
                    String IsoCodeUnchangedwithConversionRate =  IsoCurrencyCode +' : '+DCRUpdateTodayMap.get(IsoCurrencyCode).ConversionRate;
                    CurrencyisSameforSubsequentDays.add(IsoCodeUnchangedwithConversionRate);
                }
            }
        }
        //String recipientEmail = System.Label.Recipient_Email_Label;
        //List<String> emailList = recipientEmail.split(';');
        List<String> emailList=new List<String>();
        List<EmailRecipientITSupport__c> EmailRes = [Select Email__c From EmailRecipientITSupport__c];
        for(EmailRecipientITSupport__c emailr: EmailRes){
            emailList.add(emailr.Email__c);
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailList);
        if(CurrenciesNotUpdatedListToday.size()>0){
            System.debug('List of currencies not updated Today:'+CurrenciesNotUpdatedListToday);
            email.setSubject('Exchange Rates not updated for Today');
            email.setPlainTextBody('Hello Team,\n\n'+'The following Currency Iso Code rates were not updated for Today:\n'+CurrenciesNotUpdatedListToday);
            try {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            } catch(Exception e) {
                System.debug('Email Error: '+ e);
            }
        }
        if(CurrencyisSameforSubsequentDays.size()>0){
            System.debug('Currency Rate has not changed between Subsequent days.'+CurrencyisSameforSubsequentDays);
            email.setSubject('Currency Rates are unchanged for Subsequent days.');
            email.setPlainTextBody('Hello Team,\n\n'+'The following currency Iso Code rates have not changed for subsequent days:\n'+CurrencyisSameforSubsequentDays);
            try {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            } catch(Exception e) {
                System.debug('Email Error: '+ e);
            }
        }    
    }
}