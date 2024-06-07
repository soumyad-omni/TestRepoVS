public class BCH_UpdateTerritoryInAccounts implements Database.Batchable<sObject>{
    private list<id> accidList = new list<id>();
    public BCH_UpdateTerritoryInAccounts(list<id> accidL){
        this.accidList.addAll(accidL);
    }
    public string tarAccId;
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, BillingPostalCode, ' +
                       ' Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c,ownerId from Account where id=:accidList'; //IBA-4149
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accountList){
        UpdateTerritoryInAccounts job = new UpdateTerritoryInAccounts() ;
        job.accountList = accountList; 
        System.enqueueJob(job); 
    }
    
    public void finish(Database.BatchableContext BC){
      
    }
      
    public static void setAccountFields (Account a,Map<String,Account_Territory_Information__c> accntTerritoryInfoMap ){
         Account_Territory_Information__c accntTerritoryInfo = accntTerritoryInfoMap.get(a.Territory_Name__c);
         a.Country_Cluster__c=accntTerritoryInfo.Country_Cluster__c;
         a.Division_Account__c=accntTerritoryInfo.Division__c;
         a.Region__c=accntTerritoryInfo.Region__c;
         a.Account_Territory__c = accntTerritoryInfo.Account_Territory__c;
     }
    
     public static void updateAccountTerritoryName(List<Account> accList,Map<Id, Account> oldMap){
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
        
          updateAccountFromAccountTerritoryInformation(accList,oldMap,territories); 
    }

    public static void addSubstringBasedOnIndexInList(String zipCode, Integer index, List<string> zipCodeList )
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
                                                                 Map<String,Territory_Zipcodes__c> zipCodeMap)
    {
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
                                                          Map<String,Territory_Zipcodes__c> zipCodeMap)
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
    
    public static void updateAccountFromAccountTerritoryInformation (List<Account> accList,Map<Id, Account> oldMap,Set<string> territories){
       
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
            //else
           // {   a.Country_Cluster__c='';  a.Division_Account__c=''; a.Region__c=''; a.Account_Territory__c ='';  }
        }
        setOwnerIdInAccountsBasedOnTerritoryRole(accList);
        /*Account oldAccount;/iba-3080
        Account acct;
        
        for(Integer j = 0; j < accList.size(); j++)
        {    acct = accList[j];              
            if(oldMap.get(acct.id) == null)
            { continue;}
            oldAccount = oldMap.get(acct.id); 
            if(acct.IsDeleted__c ||( acct.Country_Cluster__c == oldAccount.Country_Cluster__c 
                                 &&  acct.Division_Account__c == oldAccount.Division_Account__c
                                 &&  acct.Region__c == oldAccount.Region__c
                                 &&  acct.Account_Territory__c == oldAccount.Account_Territory__c
                                 &&  acct.Territory_Name__c == oldAccount.Territory_Name__c
                                 &&  acct.ownerId == oldAccount.ownerId))
            {
                accList.remove(j);
            } 
            
        }*/
    }
  
  
  public static void setOwnerIdInAccountsBasedOnTerritoryRole (List<Account> accList){
       //populate accountTerritoryMap and territorySet
        /* Set<Id> accountIds = new Set<Id>();/iba-3080
         for(Account acc : accList)
         {  accountIds.add(acc.Id); }
        Map<Id,UserTerritory2Association> utMap = new Map<Id,UserTerritory2Association>();
        Set<Id> territorySet = new Set<Id>();
        Map<Id,Set<Id>> accountTerritoryMap = new Map<Id,Set<Id>>();
        Map<Id,Territory2Model> modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model where State = 'Active']);
       if(Test.isRunningTest())
        {modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model LIMIT 1]);}
        Set<Id> territoryIds;
         for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority from ObjectTerritory2Association
                                              where objectId IN :accList and Territory2.Territory2ModelId = :modelMap.keySet()]){
            territoryIds = accountTerritoryMap.get(ota.ObjectId);
            if(!territorySet.contains(ota.Territory2Id))
            {
                territorySet.add(ota.Territory2Id);
            }
            if(territoryIds!= null && territoryIds.size() > 0){
                territoryIds.add(ota.Territory2Id);
            }
            else 
            {
                territoryIds = new  Set<Id>();
                territoryIds.add(ota.Territory2Id);                
            }            
            accountTerritoryMap.put(ota.ObjectId, territoryIds);
        }
      if(territorySet.size() == 0 )
      {
          return;
      }
      territoryIds= new Set<Id>();
      List<UserTerritory2Association> userTerrAssList = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                                                             from UserTerritory2Association 
                                                             where Territory2Id in:territorySet and User.IsActive =: true 
                                                               and RoleInTerritory2 = 'Account Owner'];
      for(UserTerritory2Association uta:userTerrAssList){
             for (Account acct: accList)
             { 
                   if(acct.IsDeleted__c)
                   {
                       continue;
                   }
                   territoryIds = accountTerritoryMap.get(acct.Id);
                   if(territoryIds!= null && territoryIds.size() > 0 && territoryIds.contains(uta.Territory2Id))
                   {
                     acct.ownerId = uta.userId;
                   }
             }
      } */
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
        for(AccountUserTerritory2View a:terU){
              for (Account acct: accList)
             { 
                 if(a.AccountId ==acct.Id){
                    system.debug('accountid '+acct.id);
                   	acct.ownerId = a.userId;
                 }
                 
                   
             }      
            
        }
      
   }    
     // SF-BUG-592 End
}