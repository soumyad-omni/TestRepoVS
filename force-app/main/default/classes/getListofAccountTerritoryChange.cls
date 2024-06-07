public class getListofAccountTerritoryChange implements Database.Batchable<sObject>, Database.Stateful{
    public list<id> accId = new list<id>();
    private Integer countLimit;
    public getListofAccountTerritoryChange(Integer countL ){
        
        this.countLimit = countL;
    } 
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select  id,OwnerId from Account where IsDeleted__c = false';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accountList){
        /*Date myDateStart = date.today().addDays(-7);
        list<AccountUserTerritory2View> terU = new list<AccountUserTerritory2View>();
        for(account a:accountList){
            terU = [SELECT Id FROM AccountUserTerritory2View WHERE 
                    AccountId =: a.id  and LastModifiedDate >=: myDateStart];
            if(terU.size() > 0){
                accId.add(a.id);
            }
        }*/
        //List<Account> accountList = [Select  id,OwnerId from Account where id =:accList];
        Map<Id,Territory2Model> modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model where State = 'Active']);
       	if(Test.isRunningTest()){modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model LIMIT 1]);}
        map<id,id> acMap = new map<id,id>();
        list<id> acc = new list<id>();
        for(Account a:accountList){
                    acc.add(a.id);
                    acMap.put(a.id,a.OwnerId);
                }
        list<AccountUserTerritory2View> terU = [SELECT AccountId,UserId,LastModifiedDate,RoleInTerritory2 FROM AccountUserTerritory2View 
                                                where accountid=: acc and RoleInTerritory2='Account Owner' and 
                                                territory2id IN (Select Territory2Id from ObjectTerritory2Association where objectId =: acc and 
                                                                 Territory2.Territory2ModelId =:modelMap.keySet()) ];
        for(AccountUserTerritory2View a:terU){
                    
            id uid = acMap.get(a.AccountId);
            if(uid != a.UserId){
                accId.add(a.AccountId);
                
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
      	//system.debug('s '+accId.size());
        map<String, String> result = new map<String, String> ();
        String csv = 'Acc id\n';
        if(accId != null){
        for ( id accts : accId ) 
        {
            
                csv += accts + '\n';
            
        }
        }
        result = SendCsvEmail(csv);
        if(countLimit ==1){
            BCH_UpdateOwnerInAccounts job = new BCH_UpdateOwnerInAccounts() ;
            job.accountIds = accId;
            job.x = 0;
            System.enqueueJob(job);
        }else{
            BCH_UpdateTerritoryInAccounts updateTerritoryInAccountsBatch = new BCH_UpdateTerritoryInAccounts(accId);
            Database.executeBatch(updateTerritoryInAccountsBatch, 30);
        }
        
        
    }
    
    public static map<String,String> SendCsvEmail(String CsvData)
    {
        System.debug('CsvData' +CsvData); 
        map<String, String> result = new map<String, String> ();
        try{
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(CsvData);
            String csvName = 'SelectedAccId.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'aloha_integration_errors@omnicell.com'};//aloha_integration_errors@omnicell.com
            System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
            String subject = 'Selected Account id for Acc Owner update '+d.getSandboxName();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Acc id');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            
        }
        catch(Exception EX)
        {
            System.debug('The email failed to send: ' + Ex.getMessage());
            result.put('ERROR', 'The email failed to send: ' + Ex.getMessage());
        }
        return result;
    }
 
}