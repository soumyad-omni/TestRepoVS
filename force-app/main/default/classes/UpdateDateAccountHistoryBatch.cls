/**********************************************************************
Name:  UpdateDateAccountHistoryBatch
======================================================
======================================================                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1      	 Pritha Nandi            05/05/2022       INITIAL DEVELOPMENT
***********************************************************************/
global class UpdateDateAccountHistoryBatch implements Database.Batchable<sObject> {
    private List<Account_History__c> AllAccountHistory;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query = 'select id,Date__c,Edited_Time__c from Account_History__c where Date__c = null and Edited_Time__c!= null LIMIT 150000 ';
    return Database.getQueryLocator(query);
    }
    
     global void execute (Database.BatchableContext BC,List<Account_History__c> AllAccountHistory)
    {
       system.debug('AllAccountHistory Ids'+ AllAccountHistory);
        for(Account_History__c a: AllAccountHistory ){
                    System.debug('a.Edited_Time__c: '+ a.Edited_Time__c);
                    String dt = a.Edited_Time__c;
					DateTime dtF = DateTime.parse(a.Edited_Time__c);
                    a.Date__c = dtF;
            system.debug('updateRecords'+ AllAccountHistory.size()); 
        }
        if(AllAccountHistory != null && AllAccountHistory.size()>0){
            Try{
           		update AllAccountHistory;
       		}catch(Exception e){
           		 system.debug('##The following exception has occurred: '+ e.getMessage());
        	}
        }
	}
     global void finish(Database.BatchableContext bc){
        
    }
}