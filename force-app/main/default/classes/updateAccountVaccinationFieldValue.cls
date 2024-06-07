public class updateAccountVaccinationFieldValue implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String accStatus = 'Validated';
        //String isDel = 'false';
        String rcrId = '0011N00001pYk1UQAS';
        List<String> ss = new List<String>();
        ss.add('0011N00001pYpTbQAK');
        ss.add('0011N00001pYk1UQAS');
        return Database.getQueryLocator('Select id,segment__C,Requires_Covid_19_vaccination__c from Account where segment__C != NULL AND Validation_Status__c =: accStatus AND IsDeleted__c = false');
    }
    public void execute(Database.BatchableContext bc, List<Account> listAcc) {
        System.debug('rj...' +listAcc.size());
        List<Account> listAccUpdate = new List<Account>();
        for(Account a: listAcc) {
            List<String> str = new List<String>();
            str = a.segment__C.split(';');
            System.debug('rj...str' +str);
            string allstirng;
            boolean check = true;
            for(String s: str){
                if(!check){
                    allstirng +=',';
                }
                allstirng += s;
                check = false;
            }
             System.debug('rj...allstirng' +allstirng);
            if( allstirng.containsIgnoreCase('covid') && a.Requires_Covid_19_vaccination__c == false) {
                a.Requires_Covid_19_vaccination__c = true;
                listAccUpdate.add(a);
            }
            if(!allstirng.containsIgnoreCase('covid') && a.Requires_Covid_19_vaccination__c == true) {
                 a.Requires_Covid_19_vaccination__c = false;
                listAccUpdate.add(a);
            }
        }
        
        if(listAccUpdate.size() > 0) {
            System.debug('rj....listAccUpdate' +listAccUpdate.size());
            try {
                AccountTriggerHandler.TriggerDisabled = true;
                Database.update(listAccUpdate, false);
            } catch(Exception e) {
                System.debug(e);
            }
        }
    }
    public void finish(Database.BatchableContext bc) {
        
    }
}