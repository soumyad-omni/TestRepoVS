/**********************************************************************
Name:  ContactTriggerHandler
Copyright © 2018
======================================================
====================================================== 
Purpose: Handler contains method for ContactTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          ?                          ?          INITIAL DEVELOPMENT 
***********************************************************************/
public class ContactTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static Boolean isFirstTime = true;
    public static boolean workflowupdate = false;
    public static boolean updatefromallcontbatch = false;//Added by sravan for SF-BUG-847
    public static boolean isContactNoSAPGuid=false; //IBA-1120
    public static boolean isUpdateFromAccount = false; // IBA-4798
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('ContactTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        List<Contact> contactList = newItems;
        //SF-BUG-1076
        List<Account> accList = new List<Account>();
        Map<String,id> map1 = new Map<String,id>();
        Set<id> uniqueAcc = new Set<Id>();
        checkPhoneIfBlank(contactList); //IBA-1988
        if(userinfo.getName() != Label.Integration_admin_user){ 
            for(Contact c: contactList){
                if(c.SAP_Contact_GUID__c != null){
                    c.SAP_Contact_GUID__c = null;
                }
                if(c.SAP_Contact_ID__c != null){
                    c.SAP_Contact_ID__c = null;
                }
                //SF-BUG-1076
                if(contactList!= null && contactList.size() > 0) {
                    uniqueAcc.add(c.AccountId);
                    map1.put(c.id,c.AccountId);    
                }
                                
                /*if(c.isClone()){
                System.debug(LoggingLevel.ERROR, '====> isClone: '+c.isClone());
                }
                else{
                System.debug(LoggingLevel.ERROR, '====> isClone44: '+c.isClone());
                System.debug(LoggingLevel.ERROR,'===>'+c.getCloneSourceId());
                }*/
            }
            //SF-BUG-1076
            
            /*IBA-1860 Starts*/
            
            Map<ID, Account> AccDetail = new Map<ID, Account>([SELECT Id, SAP_Customer_Number__c, IsDeleted__c, RecordTypeId, House_Number__c, OwnerId FROM Account where Id IN: uniqueAcc]); //Added RecordTypeId & House_Number__c as part of IBA-4152, added OwnerId as part of IBA-4798 SH
            for(Contact con: contactList){
                Account act = AccDetail.get(con.AccountId);
                if(act != null){
                   con.Account_Number__c = act.SAP_Customer_Number__c; 
                }
                //IBA-2339 starts
                if(act.IsDeleted__c){
                    con.Account_IsDeleted__c = act.IsDeleted__c;
                }else{
                    con.Account_IsDeleted__c = act.IsDeleted__c;
                }
                //IBA-2339 ends
                
                //IBA-4152 starts
                if(act.House_Number__c != null && act.RecordTypeId == System.Label.Intl_Account_RecordTypeID){
                    con.House_Number__c = act.House_Number__c;
                }
                //IBA-4152 ends
            }
            if(!isUpdateFromAccount){ //IBA-4798 SH
                updateContactOwner(contactList, null, AccDetail); //IBA-4798 SH
            }
            
            /*IBA-1860 End*/
            
            accList = [Select id,IsDeleted__c from Account where id IN: uniqueAcc];
            System.debug('accList...' +accList);
            setETMRoleOnContactBasedOnTerritoryRole(accList,contactList); //change the method name for IBA-1129
            
        }
        updateContactrecord(contactList);   // soumyad SF-bug-883
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Contact> contactList = newItems.values();
        //SF-BUG-1076
        List<Account> accList = new List<Account>();
        Map<String,id> map1 = new Map<String,id>();
        Set<id> uniqueAcc = new Set<Id>();
        updateContactrecord(contactList); // soumyad SF-bug-883
        //Added by sravan for SF-BUG-847 START
        /*for(Contact c: contactList){
            if(c.SAP_Contact_ID__c == null && c.sent_to_SAP__c == true){
                c.sent_to_SAP__c = false;
            }       
        }*/
        //Added by sravan for SF-BUG-847 END
        
        if(!updatefromallcontbatch){//Added by sravan for SF-BUG-847
            /*Bug-487-Job title II data will send to the castIron org - Balaji*/
            
            /* //Bug-403 - Written By Balaji////commented by sravan for NOV 15 release*/
            List<Contact> changedConList = new List<Contact>();
            for(Contact con:contactList){
                Contact oldCon = (Contact)oldItems.get(con.Id);
                if(con.contact_interested_products__c!=oldCon.contact_interested_products__c && !changedConList.contains(con))
                    changedConList.add(con);
                
            }
            //*///commented by sravan for NOV 15 release // uncommented the above code by sravan on 20 DEC
            
            for(Contact c: contactList){
                string jobtitle2 = c.Title;
                //SF-BUG-1076
                if(contactList!= null && contactList.size() > 0) {
                    uniqueAcc.add(c.AccountId);
                    map1.put(c.id,c.AccountId);    
                }
                try{
                    if(jobtitle2.length()>39 && (jobtitle2 !='' || jobtitle2 !=NULL)){     
                        c.Job_Title_II__c = jobtitle2.substring(0, 39);   
                    }
                    else{
                        c.Job_Title_II__c = c.Title;
                    }
                }catch (System.NullPointerException e){
                    
                }
                // changedConList.add(c);//commented by sravan for NOV 15 release
            }
            //SF-BUG-1076
            
            /*IBA-1860 Starts*/
            
            Map<ID, Account> AccDetail = new Map<ID, Account>([SELECT Id, SAP_Customer_Number__c, IsDeleted__c, RecordTypeId, House_Number__c, OwnerId FROM Account where Id IN: uniqueAcc]); //Added RecordTypeId & House_Number__c as part of IBA-4152, added OwnerId as part of IBA-4798 SH
            for(Contact con: contactList){
                Account act = AccDetail.get(con.AccountId);
                if(act != null){
                   con.Account_Number__c = act.SAP_Customer_Number__c; 
                }
                //IBA-2339 starts
                if(act.IsDeleted__c){
                    con.Account_IsDeleted__c = act.IsDeleted__c;
                }else{
                    con.Account_IsDeleted__c = act.IsDeleted__c;
                }
                //IBA-2339 ends
                                
                //IBA-4152 starts
                if(act.House_Number__c != null && act.RecordTypeId == System.Label.Intl_Account_RecordTypeID){
                    con.House_Number__c = act.House_Number__c;
                }
                //IBA-4152 ends
            }
            if(!isUpdateFromAccount){ //IBA-4798 SH
            	updateContactOwner(contactList, oldItems, AccDetail); //IBA-4798 SH  
            }             
            /*IBA-1860 End*/
            
            accList = [Select id,IsDeleted__c from Account where id IN: uniqueAcc]; 
            setETMRoleOnContactBasedOnTerritoryRole(accList,contactList); //change the method name for IBA-1129
            // productChanged(contactList);//commented by sravan for NOV 15 release
        }//Added by sravan for SF-BUG-847  
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        set<Id> newconIds = new set<Id>();
        List<Contact> contactList = newItems.values();
        for(Contact con : contactList)
        {
            newconIds.add(con.Id);
            system.debug('newconIds..'+newconIds);
        }
        //TestCastIronIntegration_Contact.callOutMethodInsert_SendAllContacts(newconIds);
        connectToCastIronInsert(contactList);
    } 
    
    //Once Contact is created,invoke REST api class to connect to CastIron. 
    public void connectToCastIronInsert(List<Contact> contactList){        
        Set<Id> contactIds = new Set<Id>();
        set<Id> newconIds = new set<Id>();
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String soldto = csValue1 != null ? csValue1.AccountRole_SoldTo__c : ''; 
        system.debug('soldto...'+soldto);
        
        //Map<string,CastIronIntegration__c> csValue2 = CastIronIntegration__c.getAll();
        //system.debug('csValue2...'+csValue2);
                
        if(contactList.size()>0)
        {
            for (Contact c : contactList)
            {
                system.debug('inside for...');
                contactIds.add(c.Id);
                system.debug('contactIds...'+contactIds);
            } 
        }
        //List<Contact> cList = [select id,Name,AccountId,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c,SAP_Contact_ID__c from Contact where id IN:contactIds and Account.Validation_Status__c='Validated' and Account.Account_Role__c=:soldto];
        List<Contact> cList = [select id,Name,AccountId,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c,SAP_Contact_ID__c from Contact where id IN:contactIds and Account.Validation_Status__c='Validated' and Account.SAP_Account_ID__c!=''];
        system.debug('cList...'+cList);
        
        
        if(cList.size()>0)
        {
            for(Contact con : cList)
            {
                newconIds.add(con.Id);
                system.debug('newconIds..'+newconIds);                
            }
        }
        if(System.IsBatch() == false && System.isFuture() == false && newconIds.size()>0){ 
            system.debug('Check batch or future is running..');
            OmnicellContactToCastIron_Class.callOutMethodInsert(newconIds);            
        }
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<String> quotebookedstatuses = New List<String>{'E0013','E0014','E0019','E0017','E0023','E0024'};//IBA-4980 Saptarsha Panthi
        if(!updatefromallcontbatch){ //Added by sravan for SF-BUG-847
            Map<Id,Contact> userConMap = new Map<Id,Contact>();//IBA-4525 - Start
            List<User> userList = [Select Id,ContactId From User Where ContactId IN :newItems.keySet() AND Profile.Name = 'Omnicell B2B Storefront Profile'];
            Map<Id,Id> userConJun = new Map<Id,Id>();
            for(User usr: userList){
                userConJun.put(usr.ContactId, usr.Id);
            }												   //IBA-4525 - End
            List<Contact> listSendToSAP = new List<Contact>();
            
            List<Contact> contactList = oldItems.values();
            List<Contact> contactNew = newItems.values();
            List<Id> conIds = new List<Id>();
            /*for(Contact c: newContacts){
                conIds.add(c.id);
            }*/
            Boolean isEmailUpdate = false;//updated by sravan for SF-BUG-574
            Boolean isActiveUpdate = false; //added for SCP-775
            for(integer i=0;i<contactNew.size();i++){
                if(contactNew[i].email != contactList[i].email || contactNew[i].Phone != contactList[i].Phone ){
                    conIds.add(contactNew[i].id); 
                    isEmailUpdate = true;//updated by sravan for SF-BUG-574
                    System.debug('Saptarsha Test:'+isEmailUpdate);//IBA-4980 Remove
                }
                //added for SCP-775
                if(contactNew[i].Is_Active__c != contactList[i].Is_Active__c && contactNew[i].Is_Active__c == 'N' ){
                 system.debug('********'+contactNew[i].Is_Active__c);
                    conIds.add(contactNew[i].id); 
                    isActiveUpdate =true;
                }
                
                if(
                    contactNew[i].Salesforce_Contact_ID__c != contactList[i].Salesforce_Contact_ID__c 
                    || contactNew[i].Salutation != contactList[i].Salutation 
                    || contactNew[i].FirstName != contactList[i].FirstName 
                    || contactNew[i].LastName != contactList[i].LastName
                    || contactNew[i].Language_Code__c != contactList[i].Language_Code__c 
                    || contactNew[i].Name != contactList[i].Name 
                    || contactNew[i].Omnicell_Job_Code__c != contactList[i].Omnicell_Job_Code__c 
                    || contactNew[i].Title != contactList[i].Title
                    || contactNew[i].Phone != contactList[i].Phone 
                    || contactNew[i].Phone_Country_Code__c != contactList[i].Phone_Country_Code__c 
                    || contactNew[i].Mobile_Country_Code__c != contactList[i].Mobile_Country_Code__c 
                    || contactNew[i].MobilePhone != contactList[i].MobilePhone
                    || contactNew[i].Fax_Country_Code__c != contactList[i].Fax_Country_Code__c 
                    || contactNew[i].Fax != contactList[i].Fax 
                    || contactNew[i].Email != contactList[i].Email 
                    || contactNew[i].Preferred_Contact_Method__c != contactList[i].Preferred_Contact_Method__c
                    || contactNew[i].Is_Active__c != contactList[i].Is_Active__c 
                    || contactNew[i].Inactive_Reason__c != contactList[i].Inactive_Reason__c 
                    || contactNew[i].Opt_in__c != contactList[i].Opt_in__c 
                    || contactNew[i].Opt_In_Date__c != contactList[i].Opt_In_Date__c
                    || contactNew[i].SAP_Contact_ID__c != contactList[i].SAP_Contact_ID__c 
                    || contactNew[i].SAP_Contact_GUID__c != contactList[i].SAP_Contact_GUID__c 
                    || contactNew[i].Contact_Role__c != contactList[i].Contact_Role__c 
                    || contactNew[i].Notes__c != contactList[i].Notes__c
                    || contactNew[i].Phone_Extn__c != contactList[i].Phone_Extn__c
                    || contactNew[i].Department__c != contactList[i].Department__c
                    || contactNew[i].AccountId != contactList[i].AccountId
                )
                    listSendToSAP.add(contactNew[i]);
                
            }
             //added for SCP-775
            if(isActiveUpdate){
              updateUserFields(conIds);
            }
            if(isEmailUpdate){//updated by sravan for SF-BUG-574
                List<Quote> quoteList = [select id,name,email,phone,Shipping_contact__c from quote where shipping_Contact__c=:conIds and status != :quotebookedstatuses];//updated by sravan for SF-BUG-574//IBA-4980 Saptarsha Panthi
                
                for(Quote quote : quoteList){
                    for(Contact con : contactNew){
                        if(con.id == quote.Shipping_contact__c){
                            System.debug('Inside if shipp cont mail change');
                            quote.email = con.Email;
                            System.debug('email : '+quote.email);
                            quote.phone = con.Phone;
                            System.debug('phone : '+quote.phone);
                        }
                    }
                }
                System.debug('Quote List'+quoteList);
                QuoteTriggerHandler.TriggerDisabled = True; //IBA-2129
                update quoteList;
            }        
            //IBA-1120
            List<Contact> contactNoSapGuidList = new List<Contact>();
            for(Integer i=0;i<contactNew.size();i++){
                System.debug('contactNew[i]'+contactNew[i].Salesforce_Contact_ID__c);
              /*  if(contactNew[i].Salesforce_Contact_ID__c == null)
                {
                    System.debug('contactNew[i]****'+contactNew[i].Salesforce_Contact_ID__c);    
                    workflowupdate = true;
                } */
                //IBA-1120 - if SdP Contact sync is checked 
                if(contactNew[i].Contact_Sync__c) {
                    if(contactNew[i].SAP_Contact_ID__c==null || contactNew[i].SAP_Contact_GUID__c== null) {
                        contactNoSapGuidList.add(contactNew[i]);
                        isContactNoSAPGuid=true;
                    }
                } //IBA-1120   
                if(userConJun.get(contactNew[i].Id) != null){ //IBA-4525 - Start
                    Contact oldCon = (Contact)oldItems.get(contactNew[i].Id);
                    if(contactNew[i].FirstName != oldCon.FirstName || contactNew[i].LastName != oldCon.LastName || contactNew[i].MiddleName != oldCon.MiddleName){
                        userConMap.put(userConJun.get(contactNew[i].Id),contactNew[i]);
                    }
                }											  //IBA-4525 - End
            }
            //IBA-1120
            if(isContactNoSAPGuid){
               System.debug('Adding contacts without GUID');
               connectToCastIronInsert(contactNoSapGuidList); 
               isContactNoSAPGuid=false;
            }//IBA-1120
                       
            if(isFirstTime){
                isFirstTime = false;
                System.Debug('In After Update-----');
                if(userinfo.getName() != Label.Integration_admin_user && workflowupdate == false){
                    if(!listSendToSAP.isEmpty())
                    {
                        System.Debug('In After Update-----workflowupdate==false');
                        connectToCastIronUpdate(listSendToSAP);
                    }
                }
                if(userConMap.keySet().size()>0){ //IBA-4525-Start
                    system.enqueueJob(new UpdateContactInfoInUser(userConMap));
                }								  //IBA-4525-End
            }
        }//Added by sravan for SF-BUG-847
    }
    //added for SCP-775
    @future
    public static void updateUserFields(List<ID> contIds) {   
      List<User> userLst = new List<User>();
        for(User u:[SELECT id,FederationIdentifier,ContactId,Isactive FROM User WHERE ContactId IN :contIds]){
            u.FederationIdentifier = '';
            u.Isactive= false;
            userLst.add(u);
        }
        UserTriggerHandler.isFirstRun = false; //IBA-5967 SH
        update userLst;
    }
    //Bug-403-- Balaji////commented by sravan for NOV 15 release //uncommented below code by sravan on DEC 20
    public void productChanged(List<Contact> conList){
        for(Contact con:conList){
            System.debug(con.Interested_Products__c );
            con.contact_interested_products__c = con.Interested_Products__c ;
            System.debug(con.contact_interested_products__c);
        }
    }
    //Bug-403-- Balaji END
    
    //Once Contact is updated,invoke REST api class to connect to CastIron. 
    public void connectToCastIronUpdate(List<Contact> contactList){        
        Set<Id> contactIds = new Set<Id>();
        Set<Id> newconIds = new Set<Id>();
        Set<Id> inactiveconIds = new Set<Id>();
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String soldto = csValue1 != null ? csValue1.AccountRole_SoldTo__c : ''; 
        system.debug('soldto...'+soldto);
        
        if(contactList.size()>0)
        {
            for (Contact c : contactList)
            {
                system.debug('inside for...');
                contactIds.add(c.Id);
                system.debug('contactIds...'+contactIds);
            } 
        }
        //List<Contact> cList = [select id,Name,AccountId,Is_Active__c ,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c,SAP_Contact_ID__c from Contact where id IN:contactIds and Account.Validation_Status__c='Validated' and Account.Account_Role__c=:soldto];
        List<Contact> cList = [select id,Name,AccountId,Is_Active__c ,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c,SAP_Contact_ID__c from Contact where id IN:contactIds and Account.Validation_Status__c='Validated' and Account.SAP_Account_ID__c!=''];         
        system.debug('cList...'+cList);
                
        if(cList.size()>0)
        {
            for(Contact con : cList)
            {
                newconIds.add(con.Id);
                system.debug('newconIds..'+newconIds);
            }            
        }
        
        if(System.IsBatch() == false && System.isFuture() == false && newconIds.size()>0 ){ 
            system.debug('Check batch or future is running..');
            OmnicellContactToCastIron_Class.callOutMethodUpdate(newconIds);
        }
        
    }
    
    // soumyad SF-bug-883 added below function
    public static void updateContactrecord(List<Contact> conList) {
        List<contact> updatel = new List<contact>();
        List<contact> le = conList;
        List<Job_title_Classification__c> custm = [SELECT name, Classification__c FROM Job_title_Classification__c];
        for (contact l : le) {
            for (Job_title_Classification__c c : custm) {
                if(l.Omnicell_Job_Code__c == c.name){
                    l.Classification__c = c.Classification__c;
                    system.debug('*** updating record '+l.Classification__c);
                }                
            }
        }
        system.debug('updatel '+updatel);
        
    }
    //SF-BUG-1076
    public static void setETMRoleOnContactBasedOnTerritoryRole (List<Account> accList, List<Contact> contactList){ //change the method name for IBA-1129
        List<Account> actvAcountList =new List<Account>(); //IBA-1510 - holds non-deleted accounts
        //populate accountTerritoryMap and territorySet
       /* Set<Id> accountIds = new Set<Id>();
        Map<String, String> map2 = new Map<String, String>();
        Map<String, String> map3 = new Map<String, String>();
        */
        for(Account acc : accList){
            if(!acc.IsDeleted__c){
                actvAcountList.add(acc);
         //       accountIds.add(acc.Id); 
            }             
        }

        //Map<Id,UserTerritory2Association> utMap = new Map<Id,UserTerritory2Association>();
        Set<Id> territorySet = new Set<Id>();
        Map<Id,Set<Id>> accountTerritoryMap = new Map<Id,Set<Id>>();
        Map<Id,Territory2Model> modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model where State = 'Active']);
        if(Test.isRunningTest())
        {
            modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model Where DeveloperName='Test_Model' LIMIT 1]); //IBA-1129
        }
        
        Set<Id> territoryIds;
        List<ObjectTerritory2Association> objTerritoryAssoList =new List<ObjectTerritory2Association>([Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority from ObjectTerritory2Association where objectId IN :actvAcountList and Territory2.Territory2ModelId = :modelMap.keySet()]);
        
        for(ObjectTerritory2Association ota:objTerritoryAssoList){
            territoryIds = accountTerritoryMap.get(ota.ObjectId);
            if(!territorySet.contains(ota.Territory2Id)) {
                territorySet.add(ota.Territory2Id);
            }
            if(territoryIds!= null && territoryIds.size() > 0) {
                territoryIds.add(ota.Territory2Id);
            }
            else {
                territoryIds = new  Set<Id>();
                territoryIds.add(ota.Territory2Id);                
            }            
            accountTerritoryMap.put(ota.ObjectId, territoryIds);
        }
        if(territorySet.size() == 0 ) {
                      return;
        }
        //System.debug('territorySet'+territorySet);
        //territoryIds= new Set<Id>();
        /* List<UserTerritory2Association> userTerrAssList = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                                                             from UserTerritory2Association 
                                                             where Territory2Id in:territorySet and User.IsActive =: true 
                                                               and RoleInTerritory2 IN('Sales Associate','NAC Sales Associate')];
        System.debug('userTerrAssList'+userTerrAssList);
        for(UserTerritory2Association uta:userTerrAssList){
             for (Account acct: actvAcountList){ 
                territoryIds = accountTerritoryMap.get(acct.Id);*/
                 /*  if(territoryIds!= null && territoryIds.size() > 0 && territoryIds.contains(uta.Territory2Id))
                   {
                     System.debug('Sales Associate.....' +uta.userId);
                       map2.put(acct.id,uta.userId);
                   }*/
                 
         /*      if(territoryIds!= null && territoryIds.size() > 0 && territoryIds.contains(uta.Territory2Id)){
                    if(map3.containsKey(acct.id)) {
                           String value = map3.get(acct.id);
                           if(value == 'Sales Associate') {
                               continue;
                           }else {
                               map2.put(acct.id,uta.userId);
                               map3.put(acct.id,uta.RoleInTerritory2);
                           }
                       } else {
                       System.debug('value1.....' +uta.Territory2Id);
                       System.debug('value.....' +uta.userId);
                       map2.put(acct.id,uta.userId);
                       map3.put(acct.id,uta.RoleInTerritory2);
                       }
                   }
             }
      }*/ 
       //Added for IBA-1129 by Sourav Start
       // updated for IBA-1510
        List<UserTerritory2Association> userTerrAssList2 = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                                                            from UserTerritory2Association 
                                                            where Territory2Id in:territorySet and User.IsActive =: true 
                                                            and RoleInTerritory2 IN('Sales Associate','NAC Sales Associate',
                                                            'Client Success Executive','Client Success Executive - Govt',
                                                            'Health Systems Executive','Health System Executive - Govt',
                                                            'Health System Executive - GPO')];

        Map<String, String> sdIsrUser = new Map<String, String>();
        Map<String, String> sdIsrTrRole = new Map<String, String>();
        Map<String, String> cse1 = new Map<String, String>();
        Map<String, String> cse2 = new Map<String, String>();
        Map<String, String> hse1 = new Map<String, String>();
        Map<String, String> hse2 = new Map<String, String>();
        Set<Id> territoryIds2= new Set<Id>();
        
        //System.debug('userTerrAssList2'+userTerrAssList2);
        for(UserTerritory2Association uta:userTerrAssList2){
          //  Integer i = 0;
            //IBA-1510
             for (Account acct: actvAcountList)
             {
                territoryIds2 = accountTerritoryMap.get(acct.Id);
                //IBA-1510
                if(territoryIds2!= null && territoryIds2.size() > 0 && territoryIds2.contains(uta.Territory2Id)){
                    /*if(uta.RoleInTerritory2 ==  'Sales Associate' || uta.RoleInTerritory2 == 'NAC Sales Associate'){ //commented from here as part of IBA-4067
                        sdIsrUser.put(acct.id,uta.userId);
                        sdIsrTrRole.put(acct.id,uta.RoleInTerritory2);
                    }
                    else if(uta.RoleInTerritory2 == 'Client Success Executive' || uta.RoleInTerritory2 == 'Client Success Executive - Govt'){*/ //commented till here as part of IBA-4067
                    if(uta.RoleInTerritory2 == 'Client Success Executive' || uta.RoleInTerritory2 == 'Client Success Executive - Govt'){
                        cse1.put(acct.id,uta.userId);
                        cse2.put(acct.id,uta.RoleInTerritory2);
                    }
                    else if(uta.RoleInTerritory2 == 'Health Systems Executive' || uta.RoleInTerritory2 == 'Health System Executive - Govt' || uta.RoleInTerritory2 == 'Health System Executive - GPO'){
                        hse1.put(acct.id,uta.userId);
                        hse2.put(acct.id,uta.RoleInTerritory2);
                    }
                   }
             } //end IBA-1510
      } //Added for IBA-1129 by Sourav End
        for(Contact c: contactList) { 
            //c.SDR_ISR_Owner__c = null; //commented as part of IBA-4067
            c.Client_Success_Executive__c = null;
            c.Health_Systems_Executive__c = null;

            /*if(sdIsrTrRole.containsKey(c.AccountId)) { //commented from here as part of IBA-4067
                String usrId = sdIsrUser.get(c.AccountId);
 /               System.debug('usrId...' +usrId);
                c.SDR_ISR_Owner__c = usrId;
            }*/ //commented till here as part of IBA-4067
            if(cse2.containsKey(c.AccountId)) {   //Added for IBA-1129 by Sourav
                String usrId = cse1.get(c.AccountId);
                c.Client_Success_Executive__c = usrId;
            }
            if(hse1.containsKey(c.AccountId)) {   //Added for IBA-1129 by Sourav
                String usrId = hse1.get(c.AccountId);
                c.Health_Systems_Executive__c = usrId;
            }
        }
   }
    //IBA-1988
    public void checkPhoneIfBlank(List<Contact> conList) {
        for(Contact con : conList){
            if(con.Created_from_Lead__c == true && (con.Phone == '' || con.Phone == Null) ) {
                con.adderror('Phone is mandatory field on Contact. Please fill Phone on lead and convert.');
            }
        }
    }
    
    //IBA-4798
    public void updateContactOwner(List<Contact> nCon, Map<Id, SObject> oCon,  Map<ID, Account> Acc){
        Id ownerId = (Id)Label.Admin_Integration_User_Id;
        if(oCon != null && oCon.size()>0){
            for(Contact con: nCon){
                Contact oldcon = (Contact)oCon.get(con.id);
                Account act = Acc.get(con.AccountId);
                if(con.AccountId != null && con.Is_Active__c != 'N' && (con.AccountId != oldcon.AccountId || con.OwnerId != act.OwnerId)){
                    con.OwnerId = act.OwnerId;
                }
                if(con.Is_Active__c == 'N' && act.IsDeleted__c == false){
                    con.OwnerId = ownerId;
                }
            }
        }else{
            for(Contact con: nCon){
                Account act = Acc.get(con.AccountId);
                if(con.AccountId != null && con.Is_Active__c != 'N' && con.OwnerId != act.OwnerId){
                    con.OwnerId = act.OwnerId;
                }
                if(con.Is_Active__c == 'N' && act.IsDeleted__c == false){
                    con.OwnerId = ownerId;
                }
            }
        }
    }
}