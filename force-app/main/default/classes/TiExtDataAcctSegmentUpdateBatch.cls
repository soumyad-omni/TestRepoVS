/**
* @Description        : Replicates External_Data object segment to Account
* @File Name          : TiExtDataAcctSegmentUpdateBatch.cls
* @Author             : Pabitra Tripathy
**/
global class TiExtDataAcctSegmentUpdateBatch  implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,AccountID__c,Account_Segment__c,Account_Market_Segment__c,Own_Segment__c,isTiSegmentChanged__c FROM '+   // IBA-4272
            'External_Data__c WHERE isTiSegmentChanged__c=true';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<External_Data__c> extDataList){
        System.debug('TiExtDataAcctSegmentUpdateBatch Batch Execution Started');
        Set<Id> accSet = new Set<Id>();
        for (External_Data__c extData:extDataList){
            accSet.add(extData.AccountID__c);
        }
        
        Map<Id,Account> acctMap=new Map<Id,Account>([SELECT Id,Segment__c,Account_Market_Segment__c,External_Data__c,Is_NAC_Account__c,Facility_Type__c,Territory_Assignment_Criteria__c From     // IBA-4272
                                                     Account where Id IN :accSet]); //IBA-4057  //IBA-4272
        //IBA-4057 start
        list<IsNACAccount_Rule_False__c> nacf = [select name from IsNACAccount_Rule_False__c];
        list<string> nac = new list<string>();
        
        for(IsNACAccount_Rule_False__c n : nacf){
            nac.add(n.Name);
        }
        //IBA-4057 end
        Set<String> accountIds = new Set<String>();//IBA-4411
        for (External_Data__c extData:extDataList){
            Account acc = acctMap.get(extData.AccountID__c);
            
            extData.isTiSegmentChanged__c = false;
            System.debug('Before Processing the Accounts');
            if(acc!= Null){
                acc.Segment__c = extData.Account_Segment__c;
                acc.Market_Segment__c = extData.Account_Market_Segment__c;   //IBA-4272
                acc.SyncToC4C__c = true;
                //acc.External_Data__c = extData.AccountID__c; 
                //IBA-4411
                accountIds.add(extData.AccountID__c);
                //IBA-4057 start
                string seg = '';
                if(acc.Segment__c != null)
                    seg=acc.Segment__c;
                //IsNACAccount_Rule_False
                if( (((nac.contains(acc.Facility_Type__c) || acc.Territory_Assignment_Criteria__c == 'Acute' || acc.Territory_Assignment_Criteria__c == 'Under 100 Bed – Sales Development') && 
                      (acc.Territory_Assignment_Criteria__c != 'NAC Health System Owned' && acc.Territory_Assignment_Criteria__c != 'NAC Health System' 
                       && acc.Territory_Assignment_Criteria__c != 'NAC CSE')) || seg.contains('Top Accounts'))){
                           
                           acc.Is_NAC_Account__c = 'No';
                       }
                
                //IsNACAccount_Rule_True                
                if(((!(nac.contains(acc.Facility_Type__c)) && acc.Territory_Assignment_Criteria__c != 'Acute' && acc.Territory_Assignment_Criteria__c != 'Under 100 Bed – Sales Development') || 
                    (acc.Territory_Assignment_Criteria__c == 'NAC Health System Owned' || acc.Territory_Assignment_Criteria__c == 'NAC Health System' 
                     || acc.Territory_Assignment_Criteria__c == 'NAC CSE')) && !seg.contains('Top Accounts')){ 
                         
                         acc.Is_NAC_Account__c = 'Yes';
                     }
                //IBA-4057 end
            }//IBA-3635 END
        }
        AccountTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        ExternalDataTriggerHandler.TriggerDisabled = true;
        
        try{
            update extDataList;
            System.debug('Before Updating the Accounts');
            update acctMap.values();
            System.debug('After Updating the Accounts');
            //IBA-4411
            RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
            job.accntIds = accountIds; 
            if(!Test.isRunningTest()){
                System.enqueueJob(job);
            }
        }catch(Exception ex){
            System.debug('AccountSegmentUpdate error #'+ex.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
            mail.setToAddresses(toAddresses); 
        mail.setSubject('Batch Job Status for updating the Account Segment : ' + a.Status); 
        mail.setPlainTextBody('The batch job for updating Account Segment from External Data Object is completed successfully.');
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}