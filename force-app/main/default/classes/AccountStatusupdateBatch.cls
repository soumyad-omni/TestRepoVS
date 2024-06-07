Global class AccountStatusupdateBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        id rId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        id IntId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId();//IBA-3369-Start
        List<Id> recordtypeIdList = new List<Id>();
        recordtypeIdList.add(rId);
        recordtypeIdList.add(IntId);        //IBA-3369-End
		String lost = 'Lost';
        String closed = 'Closed';
        String query = 'Select id,Has_Historic_Bookings__c,Account_Status__c From Account Where RecordTypeId IN :recordtypeIdList AND Account_Status__c != :lost AND Account_Status__c != :closed'; //IBA-3369
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> accList){
        System.debug('r...' +accList.size());
        Map<Id,String> newval = new Map<Id,String>();//IBA-4357
        Map<Id,String> oldval = new Map<Id,String>();//IBA-4357
        Set<id> accountId = new Set<id>();
        List<Account> listAccUpdate = new List<Account>();
        date today = Date.today();
        Date currentQuarterStart = quarterStartDate(today);
        List<String> oppStatus = new List<String>{'Non Comissionable Booking','Commissionable - No Service PO','Non Comm. Book - No Service PO','Fully Booked','Booked with No PO','Booked with No Service PO','Booked with No Product PO'}; //IBA-4182 //IBA-4684
		List<Opportunity> oppList = [Select id,AccountId,CloseDate From Opportunity Where AccountId IN : accList AND OppStatus__c IN :oppStatus];
		for(Opportunity op:oppList)
        {
            if(op.CloseDate < currentQuarterStart)
            {
             	accountId.add(op.AccountId);
            }
		}
        for(Account acc : accList) {        
            Boolean check;
            check = accountId.contains(acc.id); 
            if(acc.Has_Historic_Bookings__c == true || check == true) {
                if(acc.Account_Status__c != 'Active') {
                    oldval.put(acc.Id, acc.Account_Status__c) ;//IBA-4357
                    acc.Account_Status__c ='Active';
                    newval.put(acc.Id, acc.Account_Status__c) ;//IBA-4357
                    if(!listAccUpdate.contains(acc))
                    listAccUpdate.add(acc);
                }
            } else {
                if(acc.Account_Status__c != 'Prospect') {
                    oldval.put(acc.Id, acc.Account_Status__c) ;//IBA-4357
                    acc.Account_Status__c ='Prospect';
                    newval.put(acc.Id, acc.Account_Status__c) ;//IBA-4357
                    if(!listAccUpdate.contains(acc))
                    listAccUpdate.add(acc);
                }
            } 
        }
        if(listAccUpdate.size() > 0) {
            try {
                AccountTriggerHandler.TriggerDisabled = true;
                Database.update(listAccUpdate, false);
            } catch(Exception e) {
                System.debug(e);
            }
            List<Account_History__c> listTOinsertACChistory = new List<Account_History__c>();//IBA-4357 Start
            for (Account a:listAccUpdate){
                Account_History__c accHistory = new Account_History__c();
                accHistory.Account__c = a.Id;
                accHistory.ORIGINAL_VALUE__c=oldval.get(a.Id);
                accHistory.NEW_VALUE__c=newval.get(a.id);
                accHistory.Date__c=DateTime.now();
                accHistory.User__c = UserInfo.getUserId();
                accHistory.Field__c = 'Account Status';
                listTOinsertACChistory.add(accHistory);
            }
            insert listTOinsertACChistory; //IBA-4357 End
        }
        
    }    
    global void finish(Database.BatchableContext bc){
    // execute any post-processing operations
    /*String chron_exp = '0 0 0 1 JAN,APR,JUL,OCT ?';
system.debug(chron_exp);
ScheduleAccountStatusupdateBatch qaub = new ScheduleAccountStatusupdateBatch();
//Schedule the next job
System.schedule('AccountStatusupdateBatch Scheduled',chron_exp,qaub);*///uncomment this section before deploy in production
    }
    public date quarterStartDate(Date dt){
        Integer cquarter;
        String dstr='';
        Integer year = dt.year();
        Integer t = (Integer)Math.ceil((dt.Month()-1)/3);
        cquarter = t+1;
        if(cquarter == 1)
        {
            dstr = '1/1/'+year;
        }
        else if(cquarter == 2)
        {
            dstr = '4/1/'+year;
        }
        else if(cquarter == 3)
        {
            dstr = '7/1/'+year;
        }
        
        else if(cquarter == 4)
        {
            dstr = '10/1/'+year;
        }
        Date currentQuarterStart = Date.parse(dstr);
        return currentQuarterStart;
    }    
}