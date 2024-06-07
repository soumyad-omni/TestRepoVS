public class BCH_UpdateOwnerInAccounts implements Queueable{
   public list<id> accountIds =new list<id>();
    public integer x;
    public void execute(QueueableContext context) {
        setOwnerId(accountIds,x);
        if(x+1 <= accountIds.size()){
            BCH_UpdateOwnerInAccounts job = new BCH_UpdateOwnerInAccounts() ;
            job.accountIds = accountIds;
            job.x = x+100;
            if(!Test.isRunningTest()){  
            System.enqueueJob(job);
            }
        }
        
    }
    public static void setOwnerId (list<id> aList, integer x){
        list<id> accountIds1 =new list<id>();
        for(Integer i=x; i<=(x+99); i++){
            if(i <= (aList.size()-1)){
                accountIds1.add(aList[i]);
            }else{
                break;
            }
        }
        list<account> accList = [select Country_Cluster__c, Division_Account__c, Region__c,Owner_Full_Name__c,   Account_Territory__c ,Id, Name, BillingPostalCode,   //IBA-4149
                                 Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c,ownerId from account where id =:accountIds1 ];
        updateAccountTerritoryName(accList);
        list<id> acc = new list<id>();
        Map<Id,Territory2Model> modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model where State = 'Active']);
        if(Test.isRunningTest()){modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model LIMIT 1]);}
        for(Account a:accList){
            acc.add(a.id);
        }
        list<AccountUserTerritory2View> terU = [SELECT AccountId,UserId,LastModifiedDate,RoleInTerritory2 FROM AccountUserTerritory2View 
                                                where accountid=: acc and RoleInTerritory2='Account Owner' and 
                                                territory2id IN (Select Territory2Id from ObjectTerritory2Association where objectId =: acc and 
                                                                 Territory2.Territory2ModelId =:modelMap.keySet()) ];
        map<id,id> tmap = new map<id,id>();
        for(AccountUserTerritory2View a:terU){
            tmap.put(a.AccountId,a.userId);
        }
        
        for (Account acct: accList){
            string aid = tmap.get(acct.Id);
            if(aid != null){
                system.debug('accountid '+acct.id);
                acct.ownerId = aid;
            }
            
            
        } 
        AccountTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        List<Database.SaveResult> results = Database.update(accList, false);
        String csv = 'id'+ ',' +'Reason\n';
        boolean sm = false;
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()){
                for (Database.Error err : result.getErrors()){
                    System.debug('Error: '+ result.getId());
                    string e = result.getId() + ',' + err.getStatusCode() + ' ' + err.getMessage();
                    csv += e + '\n';
                    
                }
                sm = true; 
            }
        }
        if(sm == true){SendCsvEmail(csv);}
    }  
    
    public static map<String,String> SendCsvEmail(String CsvData)
    {
        System.debug('CsvData' +CsvData); 
        map<String, String> result = new map<String, String> ();
        try{
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(CsvData);
            String csvName = 'FailedAccInfo.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'aloha_integration_errors@omnicell.com'};
            System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
            String subject = 'Account owner updation failed '+d.getSandboxName();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Acc id of Account owner updation failed');
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
    
    public static void setAccountFields (Account a,Map<String,Account_Territory_Information__c> accntTerritoryInfoMap ){ //**4.1
         Account_Territory_Information__c accntTerritoryInfo = accntTerritoryInfoMap.get(a.Territory_Name__c);
         a.Country_Cluster__c=accntTerritoryInfo.Country_Cluster__c;
         a.Division_Account__c=accntTerritoryInfo.Division__c;
         a.Region__c=accntTerritoryInfo.Region__c;
         a.Account_Territory__c = accntTerritoryInfo.Account_Territory__c;
     }
    
     public static void updateAccountTerritoryName(List<Account> accList){ //**1
        List<string> zipCodeList = new List<string>(); 
        List<string> countryList = new List<string>();
        //List<Decimal> DHCList = new List<Decimal>();
        Set<string> territories = new Set<string>();
        for(Account a: accList){
             
            if(a.billingPostalCode != null && a.billingPostalCode != '')
            {  
              zipCodeList.add(a.billingPostalCode);
              addSubstringBasedOnIndexInList(a.billingPostalCode, 6, zipCodeList );
              addSubstringBasedOnIndexInList(a.billingPostalCode, 5, zipCodeList );
              addSubstringBasedOnIndexInList(a.billingPostalCode, 4, zipCodeList );
              addSubstringBasedOnIndexInList(a.billingPostalCode, 3, zipCodeList );
              addSubstringBasedOnIndexInList(a.billingPostalCode, 2, zipCodeList );
            }               
            if(a.billingCountry != null && a.billingCountry != 'United States')
            {
               countryList.add(a.billingCountry);                
            }         
         }
         
        List<Territory_Zipcodes__c> objList = [SELECT Zipcode__c,Territory_Name__c, Country__c 
                                               FROM Territory_Zipcodes__c
                                               Where Zipcode__c in : zipCodeList OR Country__c in : countryList 
                                               ];
        Map<String,Territory_Zipcodes__c> zipCodeMap = new Map<String,Territory_Zipcodes__c>();
        Map<String,Territory_Zipcodes__c> countryMap = new Map<String,Territory_Zipcodes__c>();
        for(Territory_Zipcodes__c atl: objList) {
             if(atl.Country__c != null && (atl.Zipcode__c == null)) {                        
                countryMap.put(atl.Country__c,atl);
            }
            if(atl.Country__c != null && (atl.Zipcode__c != null)) {                        
                zipCodeMap.put(atl.Zipcode__c+'--'+atl.Country__c,atl);
            }
        }
        Boolean isSetTerritoryName = false;
        String territoryName = '';              
        for(Account a: accList){            
            isSetTerritoryName = false;
            territoryName = '';           
            
            //Set Territory Name                   
            if (!String.isBlank(a.BillingPostalCode) || !String.isBlank(a.BillingCountry))
            {  
                             
                if(!isSetTerritoryName && countryMap.size()>0 && a.billingCountry != null && countryMap.get(a.billingCountry) != null && countryMap.get(a.billingCountry).Territory_Name__c != null)
                {
                    a.Territory_Name__c = countryMap.get(a.billingCountry).Territory_Name__c; 
                    isSetTerritoryName = true;
                }
                if(a.BillingPostalCode!= null && a.BillingCountry != null && !isSetTerritoryName && zipCodeMap.size()>0) {
                    territoryName = getTerritoryBasedOnZipCodeAndCountry(a.BillingPostalCode,a.BillingCountry,zipCodeMap);
                    if(!String.isBlank(territoryName)){ a.Territory_Name__c = territoryName; isSetTerritoryName = true;}
                }
                if(isSetTerritoryName == false)
                { a.Territory_Name__c = '' ; }
            }
            if(a.Territory_Name__c != null && a.Territory_Name__c != '' && !territories.contains(a.Territory_Name__c) )
              territories.add(a.Territory_Name__c);
        }
        
          updateAccountFromAccountTerritoryInformation(accList,territories); 
    }

    public static void addSubstringBasedOnIndexInList(String zipCode, Integer index, List<string> zipCodeList ) //**2
    {
        system.debug('index'+index);
        system.debug('zipcode'+zipcode);
        system.debug('length'+zipCode.length());
        if(zipCode!=null && zipCode.length() >= index)
        {
           zipCodeList.add(zipcode.substring(0,index));
        }
    }

    public static String getSubstringBasedOnIndexAndConcatCountry(String zipCode, Integer index, String country,
                                                                  Map<String,Territory_Zipcodes__c> zipCodeMap){ //**3.1
    
        string formattedCode = '';
        string territoryName = '';
        if(zipCode!=null && zipCode.length() >= index)
        {
           formattedCode = zipcode.substring(0,index);
           formattedCode = formattedCode +'--'+country;
           if(zipCodeMap.get(formattedCode) != null && zipCodeMap.get(formattedCode).Territory_Name__c !=null)
           {  
               territoryName = zipCodeMap.get(formattedCode).Territory_Name__c;               
           }
        }
        return territoryName;
    }

    public static String getTerritoryBasedOnZipCodeAndCountry(String zipCode, String country ,
                                                          Map<String,Territory_Zipcodes__c> zipCodeMap) //**3
    {
        string territoryName = '';
        territoryName = getSubstringBasedOnIndexAndConcatCountry(zipCode,6,country,zipCodeMap);
        if(String.isBlank(territoryName))
        {
          territoryName = getSubstringBasedOnIndexAndConcatCountry(zipCode,5,country,zipCodeMap);  
        }
        if(String.isBlank(territoryName))
        {
          territoryName = getSubstringBasedOnIndexAndConcatCountry(zipCode,4,country,zipCodeMap);  
        }
        if(String.isBlank(territoryName))
        {
          territoryName = getSubstringBasedOnIndexAndConcatCountry(zipCode,3,country,zipCodeMap);  
        }
        if(String.isBlank(territoryName))
        {
          territoryName = getSubstringBasedOnIndexAndConcatCountry(zipCode,2,country,zipCodeMap);  
        }
        return territoryName;
    }
    
    public static void updateAccountFromAccountTerritoryInformation (List<Account> accList,Set<string> territories){ //**4
       
        List<Account_Territory_Information__c> objList = [SELECT Territory_Name__c,Country_Cluster__c,Region__c,Division__c,Account_Territory__c 
                                                          FROM Account_Territory_Information__c
                                                          WHERE Territory_Name__c =: territories LIMIT 50000];
        
        List<UserTerritory2Association> userTerrAssList = [select user.Name,RoleInTerritory2,userid from UserTerritory2Association 
                                                             where RoleInTerritory2 = 'Account Owner' and 
                                                              territory2.Name =:territories LIMIT 50000 ];
        
        Map<String,UserTerritory2Association> userAssociationMap = new Map<String,UserTerritory2Association>();
       
        Map<String,Account_Territory_Information__c> accntTerritoryInfoMap = new Map<String,Account_Territory_Information__c>();
        for(Account_Territory_Information__c atl: objList) {
            if(!accntTerritoryInfoMap.containsKey(atl.Territory_Name__c) || accntTerritoryInfoMap.get(atl.Territory_Name__c) == null) {                        
                accntTerritoryInfoMap.put(atl.Territory_Name__c,atl);
            }
        }
                        
        for(Account a: accList){         
            if (!String.isBlank(a.Territory_Name__c))
            {                     
                if(accntTerritoryInfoMap.size()>0 && accntTerritoryInfoMap.get(a.Territory_Name__c) != null) {
                    setAccountFields(a,accntTerritoryInfoMap);
                }             
            }
            
        }
        

    }
    
}