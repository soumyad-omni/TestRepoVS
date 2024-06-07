global class TiAccountAddBatch implements Database.Batchable<sObject>{
    	Set<Id> acctIds;
    	String targetInitiaveName;
    	Id acctId;
    
public TiAccountAddBatch(Set<Id> acctIds,String tgIniName,Id acctId){
        this.acctIds = acctIds;
       	this.targetInitiaveName = tgIniName;
        this.acctId = acctId;
    }
    
global Database.QueryLocator start(Database.BatchableContext bc) {
        String query ='SELECT Id FROM Account WHERE Id IN :acctIds' ;
        return Database.getQueryLocator(query);
    }
    
global void execute(Database.BatchableContext bc, List<Account> accList){ 
            //System.debug('PT accList '+accList);
            Set<Id> accKeys=new Set<id>();
            for (Account ak:accList){
                accKeys.add(ak.Id);
            }
            Set<Id> ccAccKeys = new Set<Id>(accKeys);
            
            List<External_Data__c> extDataL= [SELECT Id,AccountID__c FROM External_Data__c WHERE AccountID__c IN :accKeys];          
            Set<Id> exDataKeys=new set<Id>();   
            for (External_Data__c exDt : extDataL){
                exDataKeys.add(exDt.AccountID__c);
            }
            
            for (Id exKey:exDataKeys){
                if(accKeys.contains(exKey))
                    accKeys.remove(exKey);
            }
            
            List<External_Data__c> extDataListIns = new List<External_Data__c> ();
            for (Id key:accKeys){    
                extDataListIns.add(new External_Data__c(AccountID__c=key));
            }
            if(extDataListIns!=null && !extDataListIns.isEmpty()){
                insert extDataListIns;
            }
            
            List<External_Data__c> extDataList= [SELECT Id,AccountID__c,Account_Segment__c,Own_Segment__c,isTiSegmentChanged__c 
                                                 FROM External_Data__c WHERE AccountID__c IN :ccAccKeys];          
            //System.debug('PT Ti extData List '+extDataList.size()+' '+extDataList);
            //System.debug('PT Ti extData targetInitiative '+targetInitiaveName);
            List<External_Data__c> extDataUpdate = new List<External_Data__c>();  
            for (External_Data__c uExtDt:extDataList){
                if(uExtDt.Account_Segment__c == null){
                    uExtDt.Account_Segment__c = targetInitiaveName;
                }
                else{
                    Set<String> segementSet = new Set<String>();
                    segementSet.addAll(uExtDt.Account_Segment__c.split(';'));
                    if(!segementSet.contains(targetInitiaveName)){
                        uExtDt.Account_Segment__c +=';'+targetInitiaveName;
                    }
                } 
                
                if(uExtDt.AccountID__c==acctId){
                    if(uExtDt.Own_Segment__c==null){
                        uExtDt.Own_Segment__c =  targetInitiaveName;
                    }
                    else {
                        Set<String> segementSet = new Set<String>();
                        segementSet.addAll(uExtDt.Own_Segment__c.split(';'));
                        if(!segementSet.contains(targetInitiaveName)){
                            uExtDt.Own_Segment__c +=';'+targetInitiaveName;
                        }
                    } 
                }
                
                uExtDt.isTiSegmentChanged__c = true;
                extDataUpdate.add(uExtDt);
            }
            
            if(!extDataUpdate.isEmpty()){
                ExternalDataTriggerHandler.TriggerDisabled= true; 
                update extDataUpdate;
            }        
    }
    
global void finish(Database.BatchableContext bc){
                AsyncApexJob a = [Select Id,Status,CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()]; 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                String[] toAddresses = new String[] {a.CreatedBy.Email}; 
                mail.setToAddresses(toAddresses); 
                mail.setSubject('Account is added to Target Initialtive Account : ' + a.Status); 
                mail.setPlainTextBody('Target Initialtive Account is added successfully.');
                if(!Test.isRunningTest())
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}