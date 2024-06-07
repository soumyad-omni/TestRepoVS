/*********************************************************************
Name:      AccountTriggerHandler
Purpose:   Calls AccountCreateController to update a SAP Account
Copyright © 2018
=======================================================================
History :
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Linda Neel                 7/1/2018            Initial Creation
Andrew Hilsher             8/29/2018           Added setting Transportation Zone Country in Before Update
************************************************************************/
public class AccountTriggerHandler implements ITriggerHandler{
    set<id> AccId = new set<id>();    // SCP-22
    set<id> ConId = new set<id>();    // SCP-22
    set<id> UserList = new set<id>(); // SCP-22
    public static boolean isFirstRun = True;
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public static boolean updateFromExternalTrigger= false;//IBA-3101
    public static boolean isTriggerExecuted = false;
    public boolean isDisabled;
    public boolean isValidationStatusChanged;
    public static boolean isOppInsert = false;//added by sravan for SF-BUG-518
    public static boolean TiUpdate = true;  //IBA-2820 pabitra
    public static boolean isTriggerDeleteDisabled = false;  //IBA-5832
    public static Map<Id,Decimal> accIdLicensedOC1BedsMap = new Map<Id,Decimal>(); //IBA-3101
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('AccountTriggerDisabled');
        if(tc != null) isDisabled = tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        
        //Method to populate top level parent
        // getTopLevelParent(newItems);
        
        // update the currency of newly created account according to the table in custom settings
        List<Account> newAccnts= newItems; 
        list<id> pid = new list<id>(); //IBA-3292
        list<id> uid = new list<id>(); //IBA-3292
        for (Account a : newAccnts) { 
            a.CurrencyIsoCode = Default_Currency_by_Country_Code__c.getValues(a.BillingCountryCode) != null ? Default_Currency_by_Country_Code__c.getValues(a.BillingCountryCode).Currency_Code__c : 'USD'; 
            if(a.ParentId != null){ //IBA-3292
                pid.add(a.ParentId);
            }
            uid.add(a.CreatedById);
            uid.add(a.OwnerId);
        }
        updateLicensedBedsForOC1Quoting(newAccnts);//IBA-3101
        definitivePopulate(newAccnts);
        setAccValues(newAccnts); //IBA-1988
        //checkGDPR(newAccnts);
        //SF BUG 592 Changes started
        Map<Id, SObject> mockMap = new Map<Id, SObject>();
        if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled()|| System.isFuture()))
        {
            updateAccountTerritoryName(newAccnts,mockMap);
        }
        AccountCreateController.validateAddress(newAccnts); //Added by Pavan Palla
        //SF BUG 592 changes ended  
        //IBA-2186  
        updateRefEdgeValues(newAccnts);
        automationAccountBeforeInsert(newAccnts, pid); //IBA-3292
        automationAccountInsertUpdate(newAccnts, uid); //IBA-3292

    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        // mark custom isDeleted so doesnot move to salesforce delete 
        //List<Account> accnts= oldItems.values();
        //for (Account a : accnts) {
        //    a.IsDeleted__c = true;
        //} 
        //IBA-5832 Starts
        if(isTriggerDeleteDisabled == false){
            Set<String> allowedProfiles = new Set<String>();
            for (AllowedProfiles__c setting : AllowedProfiles__c.getAll().values()) {
                allowedProfiles.add(setting.ProfileName__c);
            }
            Id userProfileId = UserInfo.getProfileId();
            String userProfileName = [SELECT Name FROM Profile WHERE Id = :userProfileId].Name;
            
            for (Account acc : (List<Account>)oldItems.values()) {
                if (acc.SAP_Customer_Number__c != null && allowedProfiles.contains(userProfileName)) {
                    // Allow deletion
                } 
                else if (acc.SAP_Customer_Number__c == null){
                    // Allow deletion
                }
                else{
                    acc.addError('You do not have permission to delete this account');
                }
            } 
        }
        
        //IBA-5832 Stop
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    
    public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newItems){
        
        //Method to populate top level parent   
        /*if(!system.isBatch() && (newItems.size() == 1)){  
getTopLevelParent(newItems.values());   
}*/
        Set<Id> newaccountIds = newItems.keySet(); //IBA-3292
        System.Debug('Account Trigger Before Update ');  
        List<Account> newAccounts= newItems.values();
        List<Account> oldAccounts= oldMap.values();
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;//IBA-3101 Start
        List<Account> oc1toUpdate = new List<Account>();
        if(!updateFromExternalTrigger){
            if(profileName!='System Administrator' && profileName!='Business Administrator' && profileName!='Marketing'){
                updateLicensedBedsForOC1Quoting(newAccounts);
            }
            else{
                for(Integer i=0;i<newAccounts.size();i++){
                    if((newAccounts[i].texcellency__DefHC_NumBeds__c != (oldAccounts[i].texcellency__DefHC_NumBeds__c))&&
                       (newAccounts[i].Licensed_Beds_for_OC1_Quoting__c == oldAccounts[i].Licensed_Beds_for_OC1_Quoting__c)){
                           oc1toUpdate.add(newAccounts[i]);
                       }
                       //IBA-3335 starts
                     if((oc1toUpdate.size() == 0) && (newAccounts[i].Licensed_Beds_for_OC1_Quoting__c != oldAccounts[i].Licensed_Beds_for_OC1_Quoting__c)){
                       newAccounts[i].OC1FieldManualUpdate__c = true;
                       system.debug('Manual Update Done for Account:'+newAccounts[i].Id);
                     }
                    //IBA-3335 ends
                }
                updateLicensedBedsForOC1Quoting(oc1toUpdate);
            }
            
        }
        //IBA-3101 End      
        List<Account> oldAccnts = oldMap.values();
        updateDHCExternalDataField(newAccounts, oldAccnts); //IBA-3113 // open the commented out part for IBA-3632
        Map<Id, Account> oldItems = new Map<Id, Account>(oldAccnts);
        List<Account> listAcc1 = new List<Account>();//IBA-2847
        //IBA-2186
        updateRefEdgeValues(newAccounts);
        //IBA-2847
        list<id> pid = new list<id>(); //IBA-3292
        list<id> uid = new list<id>(); //IBA-3292
        map<id,string> actid = new map<id,string>(); //IBA-4074
        for(Account a: newAccounts) {
            Account b = oldItems.get(a.Id);//IBA-3641 Start (Validation Rule)
            if(a.name != b.name){//IBA-4074
                actid.put(a.id,a.name);
            }
            if(b!=null && (a.Account_Role__c != b.Account_Role__c)){  //IBA-3641 Start (Validation Rule)
                if(((a.Account_Role__c == 'ZCSS')||(a.Account_Role__c == 'ZCSB')||(a.Account_Role__c == 'ZCSP')||(a.Account_Role__c == 'ZGPO')||(a.Account_Role__c == 'ZIDN')||(a.Account_Role__c == 'NA - Non-Buying/Competitor'))&& (b.Account_Role__c !='ZCSN')){
                    a.addError('Account Role needs to be changed to "Sold To" first'); 
                }}//IBA-3641 End.
            if(a.BillingStreet != oldItems.get(a.Id).BillingStreet) {
                listAcc1.add(a);
            }
            if(a.ParentId != null){ //IBA-3292
                pid.add(a.ParentId);
            }
            uid.add(a.CreatedById);
            uid.add(a.OwnerId);
        }	
        
        //IBA-4074
        if(!actid.isempty()){
            TopLevelParentNameChange updateName = new TopLevelParentNameChange(actid);
            Database.executeBatch(updateName);
        }
       
        //IBA-2847
        definitivePopulate(newItems.values());
        //System.debug('rj..' +listAcc1.size());
        //IBA-2847
        if(listAcc1.size()>0) {
            AccountCreateController.validateAddress(listAcc1); //added by Pavan palla
        }
        
        // Map<Id,Account> oldAcctMap = new Map<Id,Account>(oldAccnts);
        
        if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled()|| System.isFuture())&& !QuoteTriggerHandler.quoteUpdated
           && !OpportunityTriggerHandler.opportunityChanged)
        {  
            List<Profile> assignedProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            List<User> adminUserList = [SELECT Id, Name FROM User WHERE name = 'Admin Integration' LIMIT 1];
            for (Account a : newAccounts) {
                Account acc = (Account)(oldmap.get(a.Id));
                if(a.OwnerId != acc.OwnerId  && assignedProfile[0].Name != 'System Administrator'
                   && assignedProfile[0].Name != 'Business Administrator' && assignedProfile[0].Name != 'International Sales Ops' && assignedProfile[0].Name != 'Booking Team')
                { a.addError('Only Business Admins and System Administrators can change owner of an account');} 
                if(a.IsDeleted__c && adminUserList.size() > 0)
                { a.OwnerId = adminUserList[0].Id;}
            /*    if(a.ParentId != acc.ParentId && a.Is_Top_200__c && (a.ParentId == null || a.parent.is_top_200__c != true))
                {
                    a.Is_Deleted_From_Top_Accounts__c = true;
                }     IBA-4149*/
            }
            //IBA-2847
            if((newAccounts != null && newAccounts.size() > 0) && (oldAccnts != null && oldAccnts.size() > 0)){ 
                updateAccountTerritoryName(newAccounts,oldMap);
            }
            
        }
        //IBA-2847
        /*if((newAccounts != null && newAccounts.size() > 0) && (oldAccnts != null && oldAccnts.size() > 0)){  

//SF BUG 592 Changes started
if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled() || System.isFuture())&& !QuoteTriggerHandler.quoteUpdated
&& !OpportunityTriggerHandler.opportunityChanged)
{
updateAccountTerritoryName(newAccounts,oldMap);
}

//SF BUG 592 changes ended             
}*/
        if (!AccountCreateController.isTriggerExecuting && AccountCreateController.isFirstRun ){
            
            boolean user_has_permission = checkUserPermission();
            boolean account_notes_update_permission = checkUserPermissionToUpdateNotes();//IBA-2484
            boolean onlyAccNotesFieldUpdate = false; //IBA-2484
            Map<string,id> recordTypeMap = getRecordTypes();
            
            List<Account> newAccnts = newItems.values();
            
            //Map<Id, Account> oldItems = new Map<Id, Account>(oldAccnts); //IBA-2847
            /* allow change to validate if user has persmission to validate account
if((newAccnts != null && newAccnts.size() > 0) && (oldAccnts != null && oldAccnts.size() > 0)){         
for(Account n : newAccnts){
Account pv = (Account)oldItems.get(n.Id);           
// if incommng status is validate and its not the same as previous
if( (n.Validation_Status__c != pv.Validation_Status__c)){
isValidationStatusChanged = true;
}
else{
isValidationStatusChanged = false;
}
}
}
*/
            //IBA-3343 - Start
            for(Account a:newAccnts){
                if((!user_has_permission) && a.Validation_Status__c == 'Validated') {
                    if(a.Account_Territory__c != oldItems.get(a.Id).Account_Territory__c){
                        a.addError('You do not have permission to change Account Territory on a validated account.');
                    }
                }
            }
            //IBA-3343 - End
            if((newAccnts != null && newAccnts.size() > 0) && (oldAccnts != null && oldAccnts.size() > 0)){  
                for (Account a : newAccnts) {
                    //System.debug('User is Permitted  ' + user_has_permission);
                    if(a.Name == oldItems.get(a.Id).Name && a.Account_Name2__c == oldItems.get(a.Id).Account_Name2__c 
                       && a.Account_Name3__c == oldItems.get(a.Id).Account_Name3__c 
                       && a.Account_Name4__c == oldItems.get(a.Id).Account_Name4__c
                       && a.Address_Line_2__c == oldItems.get(a.Id).Address_Line_2__c
                       && a.Validation_Status__c == oldItems.get(a.Id).Validation_Status__c 
                       && a.IsDeleted__c == oldItems.get(a.Id).IsDeleted__c 
                       && a.Transport_Zone__c == oldItems.get(a.Id).Transport_Zone__c 
                       && a.Website == oldItems.get(a.Id).Website 
                       && a.Search_Term__c == oldItems.get(a.Id).Search_Term__c
                       //&& a.Account_Territory__c == oldItems.get(a.Id).Account_Territory__c //commented for IBA-3343
                       && a.Primary_Language__c == oldItems.get(a.Id).Primary_Language__c
                       && a.Master_Agreement__c == oldItems.get(a.Id).Master_Agreement__c 
                       && a.Partner_Type__c == oldItems.get(a.Id).Partner_Type__c 
                       && a.BillingCountryCode == oldItems.get(a.Id).BillingCountryCode 
                       && a.BillingStreet == oldItems.get(a.Id).BillingStreet 
                       && a.BillingStateCode == oldItems.get(a.Id).BillingStateCode 
                       && a.BillingCity == oldItems.get(a.Id).BillingCity
                       && a.BillingCountry == oldItems.get(a.Id).BillingCountry 
                       && a.BillingPostalCode == oldItems.get(a.Id).BillingPostalCode
                       && a.Account_Status__c == oldItems.get(a.Id).Account_Status__c 
                       && a.Account_Role__c  == oldItems.get(a.Id).Account_Role__c
                       && a.Phone == oldItems.get(a.Id).Phone 
                       && a.Classification__c == oldItems.get(a.Id).Classification__c
                       && a.Po_Box__c == oldItems.get(a.Id).Po_Box__c
                       && a.TriggerSync__c == oldItems.get(a.Id).TriggerSync__c // Added by Pavan Kumar 26/08/2020, IBA-1231 
                       && a.ParentId == oldItems.get(a.Id).ParentId //IBA-3083
                       && a.MKOI__c == oldItems.get(a.Id).MKOI__c //IBA-3360
                   && a.Dea_Number__c==oldItems.get(a.Id).Dea_Number__c//IBA-4905
                       && a.House_Number__c == oldItems.get(a.Id).House_Number__c //IBA-3070
                       && a.Facility_Type__c == oldItems.get(a.Id).Facility_Type__c //IBA-5007
                      ){
                          if(a.Customer_AR_Notes__c == oldItems.get(a.Id).Customer_AR_Notes__c //IBA-2484 - Start
                           	&& a.Customer_SO_Notes__c == oldItems.get(a.Id).Customer_SO_Notes__c 
                           	&& a.Shipping_Notes__c == oldItems.get(a.Id).Shipping_Notes__c 
                           	&& a.Sales_Notes__c == oldItems.get(a.Id).Sales_Notes__c){
                            System.debug('//// No SAP Field has been changed');
                                 continue;
                          }
                          else{
                              	System.debug('//// Only Account Notes have been changed');
                              	onlyAccNotesFieldUpdate = true;
                          } //IBA-2484 - End
                      }
System.debug(a.TriggerSync__c+':1:'+oldItems.get(a.Id).TriggerSync__c);
                    // Added by Pavan Kumar 26/08/2020, IBA-1231 
                    if(a.TriggerSync__c != oldItems.get(a.Id).TriggerSync__c && !a.TriggerSync__c) 
                        continue;                        
                    
System.debug(a.TriggerSync__c+':2:'+oldItems.get(a.Id).TriggerSync__c);
                    //set the Transportation Zone Country based upon the Billing Address Country
                    //so the dependent picklist on Transportation Zone shows filtered list.
                    if ((a.BillingCountryCode!=null)&&(a.BillingCountryCode!='')) 
                    {
                        a.Transportation_Zone_Country__c=a.BillingCountryCode;
                    }
                    
                    // Must have permission and set status to Validated
                    // Must be International Or US Customer
                    // Move the code outside for IBA-2484
                    Id us_customer = recordTypeMap.get('US & Canada Customer');
                    Id international_customer = recordTypeMap.get('International Customer');
                    Id competitorRecordTypeId = recordTypeMap.get('Competitor');//IBA-2695
                        
                        // Must include Sales Organization
                    integer orgCount = checkSalesOrgData(a.Id);
                        
                    boolean has_sales_org = (orgCount > 0) ? true : false;
                    boolean has_transport_zone = (a.Transport_Zone__c != null && a.Transport_Zone__c != '') ? true : false;
                    boolean has_partner_type = (a.Partner_Type__c != null && a.Partner_Type__c != '') ? true : false;
                    boolean has_customer_type = (a.RecordTypeId == us_customer || a.RecordTypeId == international_customer || a.RecordTypeId == competitorRecordTypeId) ? true : false; // as part of IBA-1741 removed "a.RecordTypeId == uk_customer"
                    boolean has_master_agree  = (a.Master_Agreement__c != null && a.Master_Agreement__c != '') ? true : false;
                    String errorMsg = '';
                    Account olditem = (Account)oldItems.get(a.Id);
                    String oldAccountValues = json.serialize(olditem); 
                    string  sid;
                    if(user_has_permission && a.Validation_Status__c == 'Validated') {
                        System.debug('//// user has permission to update SAP account');
                        if (has_sales_org && has_customer_type && has_transport_zone && has_partner_type ){   
                            // get old values from map - use if callout fails
                             
                            if(!Test.isRunningTest()){ 
                                AccountCreateController.CreateAccountFromProspect(a.Id, oldAccountValues,sid);
                            }
                        }
                        else {
                            errorMsg = validationCheck(has_sales_org,has_partner_type,has_transport_zone,has_customer_type);
                            a.addError(errorMsg);
                        } 
                    }
                    else{ 
                        // user does not have persmission
                        System.debug('//// user do not has permission to update SAP account');
                        if(a.Validation_Status__c == 'Validated') {
                            if(account_notes_update_permission && onlyAccNotesFieldUpdate){//IBA-2484
                                  System.debug('//// user has permission to update account Notes');
                  if (has_sales_org && has_customer_type && has_transport_zone && has_partner_type ){   
                                        // get old values from map - use if callout fails
                                        if(!Test.isRunningTest()){ 
                                            System.debug('//// Calling SAP for Notes');
                                            AccountCreateController.CreateAccountFromProspect(a.Id, oldAccountValues,sid);
                                        }
                                    }
                                    else {
                                        errorMsg = validationCheck(has_sales_org,has_partner_type,has_transport_zone,has_customer_type);
                                        a.addError(errorMsg);
                                    }                                
                            }
                            else{
                                // status is 'Validated" and user does not have persmission
                                // only allow non SAP fields to be updated
                                boolean allowUpdate = AllowSaveWithoutPermission(newAccnts, oldItems);
                                
                                if (!allowUpdate){
                                    a.addError('You do not have permission to change a validated account.'); 
                                }
                            }  
                        }
                    }
                }
            } 
        }
        System.Debug('Account Trigger Reset First Run '); 
        AccountCreateController.isFirstRun = false;
        automationAccountInsertUpdate(newAccounts, uid); //IBA-3292
        automationAccountUpdate(oldMap, newAccounts, pid,newItems, uid); //IBA-3292
        //IBA-3292
        /* List<Account> newAccnts = newItems.values();
List<Id> newIds = new List<Id>();
for(Account a : newAccnts){
newIds.add(a.Id);
}
checkGPORelation(newIds);*/
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    
    //=============================================================================
    // AFTER UNUPDATE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        
        List<Account> newAccnts = newItems.values();//IBA-2820 pabitra
        //IBA-1814 && IBA-1856 
        //IBA-3677 parentChangeTiCalculation(null,newAccnts);//IBA-2820 pabitra
        List<FeedItem> listofFeed = new List<FeedItem>();
        List<Account> accnts= newItems.values();
        //IBA-1148 START
        Map<string,id> recordTypeMap = getRecordTypes();
        Id us_customer = recordTypeMap.get('US & Canada Customer');
        Id international_customer = recordTypeMap.get('International Customer');
        //Id uk_customer = recordTypeMap.get('UK Customer'); commented out as part of IBA-1741
        List<Account> listAccts = new List<Account>();
        // IBA-1148 END
        //SF-BUG-592
        Set<String> accountIds = new Set<String>();
        accountOwnerToATM(accnts);
        Set<String> acc_Ids = new Set<String>(); //IBA-3341
        for (Account a : accnts) {
            //iba-1697 start
            AccountTriggerHandler.isFirstRun = false;
            Account_History__c accHistory = new Account_History__c();
            accHistory.Account__c = a.Id;
            accHistory.Field__c = 'Account Created';
            accHistory.User__c = UserInfo.getUserId();
            insert accHistory;
            //iba-1697 end
            accountIds.add(a.Id);
            if(a.parentId != null){
                FeedItem fd = new FeedItem();
                fd.ParentId = a.parentId;
                fd.Body = 'New Child Account Created '+ 'Name : '+a.name+'  Id : '+a.id;
                listofFeed.add(fd);
            }
            //IBA-1148 START
            //boolean has_customer_type = (a.RecordTypeId == us_customer || a.RecordTypeId == international_customer || a.RecordTypeId == uk_customer || a.Account_Type__c == 'US & Canada Customer' || a.Account_Type__c == 'International Customer' || a.Account_Type__c == 'UK Customer') ? true : false;
            boolean has_customer_type = (a.RecordTypeId == us_customer || a.RecordTypeId == international_customer || a.Account_Type__c == 'US & Canada Customer' || a.Account_Type__c == 'International Customer') ? true : false; // as part of IBA-1741 removed "a.RecordTypeId == uk_customer AND a.Account_Type__c == 'UK Customer'"
            if(has_customer_type == true) {
                listAccts.add(a); 
            }
            // IBA-1148 END
            
            acc_Ids.add(a.Id); // IBA-3341
        }
        //IBA-1148 START
        if(listAccts.size() > 0 && listAccts != Null) {
            createAccountApprovalRecord(listAccts);
        }
        // IBA-1148 END
        
        //IBA-3341 START
        if(acc_Ids.size() > 0 && acc_Ids != Null) {
            createExDataAfterAccCreation(acc_Ids);
        }
        // IBA-3341 END
        
        // IBA-1814 && IBA-1856
        Set<id> AccIds = Trigger.newMap.keySet();
        List<Account> account2UpdateList = new List<Account>();
        List<Account> accountListWithParentData = [Select ParentId, Account_Type__c, RecordTypeId, BillingCountry, Likelihood_to_Convert__c, 
                                                   Parent.Likelihood_to_Convert__c, Parent.Customer_Success_Segment__c, Customer_Success_Segment__c,
                                                   Parent.Advanced_Services_Segment__c, Advanced_Services_Segment__c, id, Name,
                                                   SAP_Customer_Number__c, Top_level_1__c,Top_level_2__c, Top_Level_Parent_CSN_Number__c,
                                                   Parent.Top_level_1__c,Parent.Top_level_2__c, Parent.Top_Level_Parent_CSN_Number__c
                                                   from Account where Id in :AccIds];
        //Top level parent
        list<account> accounts = new list<account>();
        list<account> accountsToUp = new list<account>();
        list<id> paccounts = new list<id>();
        
        //Update Account RT to International Account
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        list<string> a = new list<string>();
        a.add('United States');
        a.add('Canada');
        a.add('Puerto Rico');
        a.add('Guam');
        
                
        for(Account ac: accountListWithParentData){
            boolean t = false;
            if(ac.ParentId != null && ac.Likelihood_to_Convert__c == null || ac.Customer_Success_Segment__c == null || ac.Advanced_Services_Segment__c ==null){
                ac.Likelihood_to_Convert__c = ac.Parent.Likelihood_to_Convert__c;
                ac.Customer_Success_Segment__c = ac.Parent.Customer_Success_Segment__c;
                ac.Advanced_Services_Segment__c = ac.Advanced_Services_Segment__c;
                t = true;
            }
            //Update Account RT to International Account
            if((ac.Account_Type__c == 'International Customer') ||((a.contains(ac.BillingCountry) == false)  && (ac.RecordTypeId == devRecordTypeId1)) ){
                Id devRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId();
                ac.RecordTypeId = devRecordTypeId2;
                t = true;
            }
            //Top level parent
            if(ac.ParentId == null){ //no parent during insert
                ac.Top_level_1__c = ac.Id;
                ac.Top_level_2__c = ac.Name;
                ac.Top_Level_Parent_CSN_Number__c = ac.SAP_Customer_Number__c;
                t = true;
            }else{//added parent during insert
                ac.Top_level_1__c = ac.Parent.Top_level_1__c;
                ac.Top_level_2__c = ac.Parent.Top_level_2__c;
                ac.Top_Level_Parent_CSN_Number__c = ac.Parent.Top_Level_Parent_CSN_Number__c;
                t = true;
            }
            
            if(t == true){
                account2UpdateList.add(ac);
            }
            
        }
        // IBA-1814 && IBA-1856
        
        insert listofFeed;
        System.debug('listofFeed'); 
        boolean runTer = false;//IBA-3677
        //SF-BUG-592 - Run assignment rules
        if(!(System.isQueueable() || System.isBatch() || System.isScheduled() || System.isFuture())&& !QuoteTriggerHandler.quoteUpdated
           && !OpportunityTriggerHandler.opportunityChanged)
        {   
            /*//IBA-3677 RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
            job.accntIds = accountIds; 
            System.enqueueJob(job);*/
            runTer = true;//IBA-3677
        }
        parentChangeTiCalculation(null,newAccnts,runTer,accountIds,true);//IBA-3677
        set<id> acctids = new set<id>();
        
        //AccountTriggerHandler_Top200Customer.handleAfterInsert(accountIds);
        // IBA-1814 && IBA-1856
        if(account2UpdateList.size() > 0){
            TriggerDisabled = true;
            update account2UpdateList;
            TriggerDisabled = false;
        }   
        
        //IBA-3292
        /*//IBA-3677 AccountTriggerHandler_Top200Customer job = new AccountTriggerHandler_Top200Customer() ;
        job.accountIds = accountIds;
        job.isInsert = true;
        if(!Test.isRunningTest()){
        System.enqueueJob(job);
        }*/
    } 
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        // soumyad start SF-Bug-897
        list<id> aid =new list<id>();
        Map<Id, Account> mpNewAcc = (Map<Id, Account>)newItems;
        Map<Id, Account> mpOldAcc = (Map<Id, Account>)oldItems;
        Set<Id> licensedOC1BedsChangedIds = new Set<Id>();//IBA-3101
        // Map<Id,Decimal> accIdLicensedOC1BedsMap2 = new Map<Id,Decimal>();//IBA-3101
        List<Account> newAccnts = newItems.values();
        List<Account> oldAccnts1 = oldItems.values();
        //IBA-1814 && IBA-1856 
        //IBA-3677 parentChangeTiCalculation(mpOldAcc,newAccnts);//IBA-2820 pabitra
        
        for(Account a : newAccnts) {
            if(mpNewAcc.get(a.Id).Licensed_Beds_for_OC1_Quoting__c != mpOldAcc.get(a.Id).Licensed_Beds_for_OC1_Quoting__c){//IBA-3101 Start
                //System.debug(a.Id+'***'+a.Licensed_Beds_for_OC1_Quoting__c);
                accIdLicensedOC1BedsMap.put(a.Id, a.Licensed_Beds_for_OC1_Quoting__c);
            }
            aid.add(a.id);                                                                                                  
        }
        Set<Id> accIdsforOC1 = accIdLicensedOC1BedsMap.keySet();//IBA-3101
        DeactivateUser(newAccnts); //SCP-22 //Anil 2021-04-22 commented this line due to production issue
        //SCP-325
        
        /*IBA-1814 && IBA-1856 Start*/
        //IBA-2528
        //Set<Id> accId = new Set<Id>();
        for(Account a: newAccnts){
            //accId.add(a.Id);
            Account oldAcc=mpOldAcc.get(a.Id); //IBA-2528
            if(a.Likelihood_to_Convert__c != oldAcc.Likelihood_to_Convert__c || a.Customer_Success_Segment__c != oldAcc.Customer_Success_Segment__c || a.Advanced_Services_Segment__c != oldAcc.Advanced_Services_Segment__c){
                ParentToChildFieldUpdate.AllChilAccounts(new Set<Id>{a.Id});
            }
            //IBA-2889 start
            if(a.IsDeleted__c != oldAcc.IsDeleted__c && a.Id != (Id)Label.Omnicellinc_CSN469498){
                //system.debug('##newIsDeleted: ' + a.IsDeleted__c + '##oldIsDeleted: ' + oldAcc.IsDeleted__c);
                updateContactIsDeleted(new Set<Id>{a.Id}, a.IsDeleted__c);
            }           
            //IBA-2889 ends
        }
        /*IBA-1814 && IBA-1856 End*/
        
        list <Relationship__c> rr1 = [select id, Primary_Account__c, Primary_Account_Sales_Org__c, Secondary_Account__c, SAP_Division__c, 
                                      Relationship__c, PARZA__c, Default_Partner_Flag__c 
                                      from Relationship__c where Primary_Account__c =: aid]; //IBA-4266
        
        RestRequest request = RestContext.request;
        Map<String, String> requestHeaders = new Map<String, String>();
        if(request != null)
            requestHeaders = request.headers;
        else
            requestHeaders = null;
        if(newAccnts != null && newAccnts.size() > 0 && !(System.isQueueable() ||System.isFuture() || System.isBatch() || System.isScheduled()) &&
           !(requestHeaders != null && requestHeaders.containsKey('Sfdc-Stack-Depth') && '1'.equals(requestHeaders.get('Sfdc-Stack-Depth')))){      
               for (Account a1 : newAccnts) { 
                   for (Account a2 : oldAccnts1) {   
                       //system.debug('new -'+a1.OwnerId);
                       //system.debug('old -'+a2.OwnerId);
                       //system.debug('id....-'+a1.Id);
                       //system.debug('id....-'+a2.Id);
                       //IBA-1597 START
                       if (a1.id == a2.id && a1.IsDeleted__c == False && (a1.Credit_Amount_Approved__c != a2.Credit_Amount_Approved__c || a1.Credit_Approval_Comment__c != a2.Credit_Approval_Comment__c))// Added By Abhrajitc IBA-1724
                           sendCreditInfoUpdateNotification(a1);
                       //IBA-1597 END
                       if(a1.OwnerId != a2.OwnerId && a1.id == a2.id){
                           //update rr;
                           if(rr1.size() > 0){
                               Relationship__c rr = rr1[0];
                               String defaultFlag = '';//IBA-4266-Start
                               if(rr.Default_Partner_Flag__c == true){
                                   defaultFlag = 'X';
                               }							//IBA-4266-End
                               RelationshipCreateController.UpdateAccountRelationship(rr.Id,a1.id, rr.Primary_Account_Sales_Org__c, 
                                                                                      rr.Secondary_Account__c,rr.SAP_Division__c,
                                                                                      rr.Relationship__c, rr.PARZA__c, a2.OwnerId, 
                                                                                      rr.Primary_Account_Sales_Org__c, rr.Secondary_Account__c,
                                                                                      rr.SAP_Division__c,rr.PARZA__c,rr.Relationship__c,
                                                                                      defaultFlag,defaultFlag);//IBA-4266
                           }else{
                               string rr11 = '';
                               id rr12 = null;
                               RelationshipCreateController.UpdateAccountRelationship(rr12,a1.id, rr12, rr12,rr11,rr11, rr11, a2.OwnerId, rr12, rr12,rr11,rr11,
                                                                                      rr11,rr11,rr11);//IBA-4266
                           }
                           
                       }
                       
                   }
               }
           }
        // soumyad end SF-Bug-897
        //SF-BUG-592
        Set<String> accountIds = new Set<String>();
        //Written By Venu Kukkapalli
        List<Account> accList = newItems.values();
        List<Account> delAccList = new List<Account>();
        List<Account> gdprAccList = new List<Account>();
        List<Account> oldAccountOwnerList = new List<Account>();
        List<Account> ownerChangeAccList = new List<Account>();
        //SF-BUG-892 START -- flagSet value setup
        List<Account> oldValues =  oldItems.values();
        List<String> changeFields = new List<String>();
        List<String> dhcFields = new List<String>();
        Boolean flagSet = false;
        Schema.DescribeSObjectResult objSchema = Account.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            if(fieldName.containsIgnoreCase('texcellency') || fieldName.containsIgnoreCase('DefHC') || fieldName.containsIgnoreCase('DHC') || fieldName.containsIgnoreCase('Definitive')) {
                dhcFields.add(fieldName);
            }
            if((oldValues[0].get(fieldName))!=(accList[0].get(fieldName))) {
                changeFields.add(fieldName);
            }
        }
        for(String str : changeFields) {
            for(String str2 : dhcFields) {
                if(str == str2 || str == 'lastmodifieddate' || str == 'systemmodstamp') {
                    flagSet = true;
                    break;
                }else {
                    flagSet = false;
                }
            }
            if(flagSet == false) {
                break;
            }
        }
        
        //SF-BUG-892 END -- -- flagSet value setup
        Map<Id,Id> ownerChangeAccMap = new Map<Id, Id>();
        
        for(Account acc: accList){
            Account ac = (Account)oldItems.get(acc.id);
            //SF-BUG-592 if Block
            if(ac.Territory_Name__c != acc.Territory_Name__c || ac.IsDeleted__c != acc.IsDeleted__c  
               || ac.Validation_Status__c != acc.Validation_Status__c // IBA-2573
               || ac.Facility_Type__c != acc.Facility_Type__c
               || ac.Account_Status__c != acc.Account_Status__c
               || ac.Account_Role__c != acc.Account_Role__c
             //IBA4149  || ac.Is_Top_200__c != acc.Is_Top_200__c
               || ac.Top_Level_Account__c != acc.Top_Level_Account__c
               || ac.Top_level_1__c != acc.Top_level_1__c
               || ac.Top_level_2__c != acc.Top_level_2__c
               || ac.Territory_Assignment_Criteria__c != acc.Territory_Assignment_Criteria__c
               || ac.BillingStreet != acc.BillingStreet//Added by Sourav for IBA-1129 Start
               || ac.BillingCity != acc.BillingCity
               || ac.BillingState != acc.BillingState 
               || ac.BillingPostalCode != acc.BillingPostalCode
               || ac.BillingCountry != acc.BillingCountry)//Added by Sourav for IBA-1129 End
            {
                accountIds.add(acc.Id);  
            }
            if(ac.IsDeleted__c != acc.IsDeleted__c && acc.IsDeleted__c == TRUE && !delAccList.contains(acc)){
                delAccList.add(acc);                
            }
            if(ac.GDPR__c != acc.GDPR__c && !gdprAccList.contains(acc)){
                gdprAccList.add(acc);
            }
            // Added by Venu Kukkapalli as part of bug -266 fix 
            if(ac.OwnerId != acc.OwnerId){
                if(!ownerChangeAccList.contains(acc))
                    ownerChangeAccList.add(acc);
                if(!ownerChangeAccMap.containsKey(acc.Id))
                    ownerChangeAccMap.put(acc.Id,ac.OwnerId);
                if(!oldAccountOwnerList.contains(ac))
                    oldAccountOwnerList.add(ac);
            }
        }
        if(ownerChangeAccList.size()>0)
            deleteAccOwnerFromATM(ownerChangeAccMap);
        if(ownerChangeAccList.size()>0)
            accountOwnerToATM(ownerChangeAccList);
        if(oldAccountOwnerList.size()>0)
            deleteAccOwner(oldAccountOwnerList);
        List<Opportunity> optyList = [SELECT Id,AccountId,CustomerType__c, IV_Product_Line__c,Performance_Center_Product_Line__c   FROM Opportunity WHERE stageName != '6 Closed Won' AND stageName !='7 Closed Lost' AND AccountId IN: ownerChangeAccList];
        OpportunityTriggerHandler oth = new OpportunityTriggerHandler();
        //System.debug(optyList);
        //if(optyList.size()>0)
        // oth.populateOpportunityTeam(optyList);
        
        //
        //Added by Sravan
        /*List<Account> oldacnts = oldItems.values();
for(Integer i=0;i<accList.size();i++){
if(oldacnts[i].Account_Territory__c != accList[i].Account_Territory__c){
delAccList.add(accList[i]);
}
}*/
        //System.debug(delAccList);
        if(delAccList.size()>0){
            //updateContactOwner(delAccList); // Commented out as part of IBA-4798 SH
            //IBA-4798 starts SH
            Map<id,Contact> conMap = new Map<id,Contact>([SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId In: delAccList]);
            if(conMap.size()>0){
                if(!Test.isRunningTest()){
                    System.enqueueJob(new UpdateContactOwnerFromAcc(conMap));
                }
            }                
            //IBA-4798 ends SH
        }
        //////////////////
        //System.debug('oldItems'+oldItems); 
        List<FeedItem> listofFeed = new List<FeedItem>();
        List<Account> accnts= newItems.values();
        List<Account> oldAccnts = oldItems.values();
        //System.debug('accnts'+accnts);
        List<Id> accIds = new List<Id>();
        for(Account a : accnts){
            for(Account old : oldAccnts){
                if((a.id == old.id) && a.Shipping_Instructions__c  != old.Shipping_Instructions__c )
                    accIds.add(a.id);
            }  
        }
        for (Account a : accnts) {
            
            if(a.parentId != null){
                FeedItem fd = new FeedItem();
                fd.ParentId = a.parentId;
                fd.Body = 'Child Account updated : '+'  Name : '+a.name+'  Id : '+a.id;
                listofFeed.add(fd);
            }
            
        }
        insert listofFeed;
        //System.debug('listofFeed');
        for(Id i:accIds){//IBA-3101 Start
            if(accIdLicensedOC1BedsMap.keySet().contains(i)){
                accIdsforOC1.remove(i);
            }
        }                       //IBA-3101 End
        if(accIds.size()>0){
            updateQuotes(accIds);
            
        }
        /*List<Quote> qtListLicensedBedNeedToUpdate = [Select Id,of_beds__c,Status,AccountId From Quote Where  //IBA-3101 Start 
                                                     AccountId IN:accIdsforOC1];
        for(Quote qt:qtListLicensedBedNeedToUpdate){
            if(qt.Status == 'E00001' || qt.Status ==null){
                    qt.of_beds__c = accIdLicensedOC1BedsMap.get(qt.AccountId);
                }
        }       */                                                                                                                          //IBA-3101 End
        
        //Modified for SF-BUG-892
        if(!isOppInsert){//added by sravan for SF-BUG-518
            //System.debug('Calling updateHasOpportunityOnTargetInitiativeAccount******');
            
            if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled())){ //SF-BUG-592 condition updated
                
                if(flagSet == false)
                {
                    updateHasOpportunityOnTargetInitiativeAccount(accnts,oldAccnts);
                }
                sendAllContactsToCastIron(accnts,oldAccnts);
            }
            //changeOwner(oldItems, newItems, accnts);
        }
        
        // updateChildAccounts(oldItems, newItems);
        //SF-BUG-592 - Run assignment rules
        boolean runTer = false;
        if(accountIds.size() > 0 && (!(System.isQueueable() || System.isBatch() || System.isScheduled() || System.isFuture()))&& !QuoteTriggerHandler.quoteUpdated &&  !OpportunityTriggerHandler.opportunityChanged)
        {
            // List<accountShare> acctShares = [SELECT Id, AccountId, UserOrGroupId, RowCause from accountShare where AccountId in: accountIds and
            // (RowCause = 'Territory' OR RowCause = 'TerritoryManual')]
            /*AccountTriggerHandler.isTriggerExecuted = true;
            RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
            job.accntIds = accountIds; 
            System.enqueueJob(job);*/
            runTer = true;
        }
        parentChangeTiCalculation(mpOldAcc,accList,runTer,accountIds,false); //IBA-3677
        //IBA-1697 start
        list<Account_Field_Tracking__c> s = [select name from Account_Field_Tracking__c];
        list<string> s1 = new list<string>();
        for(Account_Field_Tracking__c i : s){
            s1.add(i.name);
        }
        set<string> st = new set<string>();
        st.addall(s1);
        Map<String, Schema.SObjectField> allaccFieldsMap = Schema.SObjectType.Account.fields.getMap();
        Map<String, Schema.DescribeFieldResult> accFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
        for (Schema.SObjectField accField : allaccFieldsMap.values()) {
            Schema.DescribeFieldResult describeResult = accField.getDescribe();
            
            if (describeResult.getName() != 'CreatedDate' &&
                describeResult.getName() != 'LastModifiedDate' &&
                describeResult.getName() != 'SystemModstamp' &&
                describeResult.isAccessible() &&
                !describeResult.isCalculated()
               )
            {
                accFieldsToTrack.put(describeResult.getName(), describeResult);
            }
            
        }
        Account newa = (Account)newAccnts[0];
        Account olda = (Account)oldAccnts1[0];
        list<Account_History__c> historiesToInsert = new list<Account_History__c>();
        for (Schema.DescribeFieldResult fieldDescribe : accFieldsToTrack.values()) {
            if (olda.get(fieldDescribe.getName()) != newa.get(fieldDescribe.getName())) {
                system.debug('fieldDescribe.getName()'+fieldDescribe.getName());
                system.debug('fieldDescribe.getName()'+st.contains(fieldDescribe.getName().toUpperCase()));
                if(st.contains(fieldDescribe.getName().toUpperCase()) == true){
                    //system.debug('olda.get(fieldDescribe.getName()'+olda.get(fieldDescribe.getName()));
                    //system.debug('newa.get(fieldDescribe.getName()'+newa.get(fieldDescribe.getName()));
                    if (fieldDescribe.getType() == Schema.DisplayType.Boolean){
                        string newval='False';
                        string oldval='False';
                        if(newa.get(fieldDescribe.getName()) ==true){
                            newval = 'True';
                        }
                        if(olda.get(fieldDescribe.getName()) ==true){
                            oldval = 'True';
                        }
                        Account_History__c complHistory = createUpdateHistory(fieldDescribe, oldval, newval, newa);
                        historiesToInsert.add(complHistory);
                    }else if(fieldDescribe.getName().toUpperCase() == 'ACCOUNT_ROLE__C'){
                        Schema.DescribeFieldResult fieldResult = Account.ACCOUNT_ROLE__C.getDescribe();
                        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                        
                        Map<String,String> MapValueLabel = new Map<String,String>();
                        String publicLabel1;
                        String publicLabel2;
                        
                        for( Schema.PicklistEntry v : values) {
                            MapValueLabel.put(v.getValue(),v.getLabel());        
                        }
                        
                        publicLabel1 = MapValueLabel.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = MapValueLabel.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Account_History__c complHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        historiesToInsert.add(complHistory);
                        
                    }else if(fieldDescribe.getName().toUpperCase() == 'PARENTID' || fieldDescribe.getName().toUpperCase() == 'CREDIT_APPROVED_FOR__C'){
                        string acc1 = '';
                        string acc2 = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            acc1 = [select name from Account where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            acc2 = [select name from Account where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Account_History__c complHistory = createUpdateHistory(fieldDescribe, acc1, acc2, newa);
                        historiesToInsert.add(complHistory);
                        
                    }else if(fieldDescribe.getName().toUpperCase() == 'RECORDTYPEID'){
                        string acc1 = Schema.SObjectType.Account.getRecordTypeInfosById().get(string.valueOf((olda.get(fieldDescribe.getName())))).getName();
                        string acc2 = Schema.SObjectType.Account.getRecordTypeInfosById().get(string.valueOf((newa.get(fieldDescribe.getName())))).getName();
                        
                        Account_History__c complHistory = createUpdateHistory(fieldDescribe, acc1, acc2, newa);
                        historiesToInsert.add(complHistory);
                        
                    }else if(fieldDescribe.getName().toUpperCase() == 'GPO_AC__C'){
                        string acc1 = '';
                        string acc2 = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            acc1 = [select name from Account where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            acc2 = [select name from Account where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Account_History__c complHistory = createUpdateHistory(fieldDescribe, acc1, acc2, newa);
                        historiesToInsert.add(complHistory);
                        
                    }else{
                        
                        Account_History__c complHistory = createUpdateHistory(fieldDescribe, string.valueOf((olda.get(fieldDescribe.getName()))), string.valueof((newa.get(fieldDescribe.getName()))), newa);
                        historiesToInsert.add(complHistory);
                    }
                }
            }
        }
        if (!historiesToInsert.isEmpty()) {
            //system.debug('historiesToInsert '+historiesToInsert);
            List<Account_History__c> historiesToInsertWithoutDuplicates = new List<Account_History__c>();
            Set<Account_History__c> historiesSet = new Set<Account_History__c>();
            historiesSet.addAll(historiesToInsert);
            historiesToInsertWithoutDuplicates.addAll(historiesSet);
            if(AccountTriggerHandler.isFirstRun){
                AccountTriggerHandler.isFirstRun = false;
                insert historiesToInsertWithoutDuplicates;
            }
            
        }
        
      insertRelationShipOnGuarantorChange(mpNewAcc, mpOldAcc);  
      /*  try{                                                                  //IBA-3101 Start
            QuoteTriggerHandler.TriggerDisabled = true;
            update qtListLicensedBedNeedToUpdate;
        }
        catch(Exception e){
            System.debug(e);
        }   */                                                                  //IBA-3101 End
    }
    /* public static void updateChildAccounts(Map<Id, SObject> oldItems, Map<Id, SObject> newItems)
{        
list<Account> parentAccounts = new list<Account>();
for(Account newAcc : (list<Account>)newItems.values())
{            
Account oldAcc = (Account)oldItems.get(newAcc.Id);
if(newAcc.Is_Top_200__c != oldAcc.Is_Top_200__c && newAcc.Account_Role__c == 'ZCSN')
{
parentAccounts.add(newAcc);
}
}
if(parentAccounts.isEmpty()) return;

list<Account> childAccounts = [SELECT Id,Name,Parent.Is_Top_200__c FROM Account WHERE ParentId IN: parentAccounts AND Account_Role__c = 'ZCSN'];
for(Account acc : childAccounts)
{
acc.Is_Top_200__c = acc.Parent.Is_Top_200__c;
}
update childAccounts;
}*/
    //If Account has Opportunity, then updates "Has Opportunity" check box as true on Target_Initiative_Account__c object
    public void updateHasOpportunityOnTargetInitiativeAccount(List<Account> accnts,List<Account> oldAccnts)
    {
        //system.debug('accnts....'+trigger.New);
        set<Id> acctid = new set<Id>();
        set<Id> taregtid = new set<Id>();
        set<Id> tpid = new set<Id>(); //SF-BUG-892
        set<Id> tiaidNew = new set<Id>(); //IBA-1227
        List<Target_Initiative_Account__c> tiaList = new List<Target_Initiative_Account__c>();
        //soumyad
        set<Target_Initiative_Account__c> updatetiaList = new set<Target_Initiative_Account__c>();
        List<Target_Initiative_Account__c> updatetiaList1 = new List<Target_Initiative_Account__c>();           
        //soumyad
        
        if(accnts.size()>0)
        {
            for(Account act : accnts)
            {
                acctid.add(act.Id);
                //system.debug('acctid....'+acctid);
            }
        }
        
        tiaList = [select id,Has_Opportunities__c,Account__c,Target_Initiative__r.id from Target_Initiative_Account__c where Account__r.Id IN:acctid];
        system.debug('tiaList...'+tiaList);
        //SF-BUG-892
        if(tiaList.size()>0) {
            for(Target_Initiative_Account__c ti : tiaList){
                tpid.add(ti.Target_Initiative__c);
                tiaidNew.add(ti.id);//IBA-1227
                //system.debug('acctid....'+tpid.size() +tpid);
            }
        }
        //soumyad
        List<Target_Initiative_Opportunity__c> tiopList = new List<Target_Initiative_Opportunity__c>();
        //SF-BUG-892
        tiopList = [select Opportunity__r.Account.NAME,Target_Initiative__r.id from Target_Initiative_Opportunity__c where Target_Initiative__r.id IN :tpid]; //IBA-1227
        //string tarint = tiaList[0].Target_Initiative__r.id;
        //system.debug('tarint ...'+tarint);
        //SF-BUG-892
        /*
for(Target_Initiative_Account__c ti: tiaList)
{
tiopList = [select Opportunity__r.Account.NAME from Target_Initiative_Opportunity__c where Target_Initiative__r.id= :ti.Target_Initiative__r.id];
}
*/
        //system.debug('tiopList ...'+tiopList);
        List<opportunity> oppid = new List<opportunity>();
        oppid = [SELECT Id, name FROM Opportunity WHERE Account.Id IN:acctid];
        set<id> oponlyid = new set<id>();//IBA-1227 added by Sourav Start
        for(Opportunity op: oppid)
        {
            oponlyid.add(op.id);
        }
        //system.debug('oppid ...'+oppid);
        //system.debug('***'+oponlyid.size());
        Map<String,Target_Initiative_Opportunity__c> tio_map = new Map<String,Target_Initiative_Opportunity__c>();
        Set<id> newTI_id = new Set<id>();
        for(Target_Initiative_Opportunity__c t1: tiopList)
        {
            tio_map.put(t1.id,t1);
        }
        for(Target_Initiative_Opportunity__c tiopp: tio_map.values())
        {
            if(oponlyid.contains(tio_map.get(tiopp.id).Opportunity__r.id))
            {
                newTI_id.add(tio_map.get(tiopp.id).Target_Initiative__r.id);
            }
        }                                                                                           //IBA-1227 added by Sourav End
        //System.debug('***'+newTI_id.size());
        for(Account a: accnts)
        {
            if((a.of_Active_Commit_Opportunities__c>0 || a.Num_of_Active_Opportunities__c>0 || a.of_Active_Pipeline_Opportunities__c>0 ||
                a.of_Active_Strong_Upside_Opportunities__c >0 || a.of_Active_Upside_Opportunities__c >0) && tiaList.size()>0) //IBA-1227 added by Sourav Start
            {
                
                for(Target_Initiative_Account__c t_new : [Select id,Has_Opportunities__c From Target_Initiative_Account__c Where Target_Initiative__c IN : newTI_id AND id IN :tiaidNew])
                {
                    if(t_new.Has_Opportunities__c != true)
                    {                            
                        t_new.Has_Opportunities__c= true;
                        updatetiaList.add(t_new);
                    }
                    
                }             //IBA-1227 added by Sourav End
            }
        }
        //System.debug('***'+updatetiaList.size());
        updatetiaList1.addall(updatetiaList);
        try{
            if(updatetiaList.size()>0)
                update updatetiaList1;
            
        }  
        catch(Exception e){ }
        
    }
    // Added by Venu Kukkapalli as part of bug 266 fix to delete account owner from opportunity Team when account owner gets updated
    public void deleteAccOwner(List<Account> oldAccList){
        Map<Id, List<OpportunityTeamMember>> accOtmMap= new Map<Id, List<OpportunityTeamMember>>();
        List<OpportunityTeamMember> delOtmList = new List<OpportunityTeamMember>();
        for(Opportunity opp: [SELECT Id,AccountId, (SELECT Id, OpportunityId, UserId, TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE stageName != '6 Closed Won' AND stageName !='7 Closed Lost' AND AccountId  IN: oldAccList]){
            for(OpportunityTeamMember otm: opp.OpportunityTeamMembers){
                if(!accOtmMap.containsKey(opp.AccountId))
                    accOtmMap.put(opp.AccountId, new List<OpportunityTeamMember>());
                accOtmMap.get(opp.AccountId).add(otm);
            }
        }
        for(Account acc: oldAccList){
            if(accOtmMap.containsKey(acc.Id)){
                for(OpportunityTeamMember otm : accOtmMap.get(acc.Id)){
                    if(acc.OwnerId == otm.UserId && !delOtmList.contains(otm))
                        delOtmList.add(otm);
                }
            }
        }
        delete delOtmList;
    }
    //Written Venu Kukkapalli to delete old account owner from Account team members when account owner updated
    public void deleteAccOwnerFromATM(Map<Id,Id> accOwnerMap){
        /* List<AccountTeamMember> atmList = new List<AccountTeamMember>();
for(Account acc:[SELECT Id, OwnerId,(SELECT Id, userId FROM AccountTeamMembers) FROM Account WHERE Id IN: accOwnerMap.keyset()]){
for(AccountTeamMember atm:acc.AccountTeamMembers){
if(atm.UserId == accOwnerMap.get(acc.Id) && !atmList.contains(atm))
atmList.add(atm);
}
}
delete atmList; */
    }
    //Written by Venu Kukkapalli to populate account owner to account team members with the role Account owner
    public void accountOwnerToATM(List<Account> accList){
        /*  List<AccountTeamMember> atmList = new List<AccountTeamMember>();
for(Account acc:accList){
AccountTeamMember atm = new AccountTeamMember();
atm.UserId = acc.ownerId;
atm.TeamMemberRole = 'Account Owner';
atm.AccountId = acc.Id;
atm.AccountAccessLevel = 'Read';
atm.OpportunityAccessLevel = 'Edit';
atm.ContactAccessLevel = 'Edit';            
if(!atmList.contains(atm))
atmList.add(atm);
}
if(atmList.size()>0)
insert atmList;*/
    }
    public static void definitivePopulate(List<Account> accList){
        for(Account acc: accList){
            acc.Definitive_Id__c = String.valueof(acc.texcellency__DefHC_HospitalID__c);
        }
    }
    public static void checkGPORelation(List<Id> accIds){
        List<Account> accList = [select id,GPOCheck__c from Account where id=:accIds];
        List<Relationship__c> relgpo = [select id from Relationship__c where primary_account__c =:accIds and relationship__c = 'ZG'];
        if(relgpo.size()>0){
            for(Account a : accList){
                a.GPOCheck__c = true;
            }
        }
    }
    public static void updateQuotes(List<Id> accIds){
        //System.debug('Inside Update Quotes');
        List<Quote> quotes = [select id,Opportunity.Account.shipping_instructions__c,Status,AccountId,of_beds__c,OpportunityId,shipping_instructions__c from Quote where accountid =:accIds];
        List<Quote> quotes1 = new List<Quote>();
        
        for(Quote q:quotes){
            q.Shipping_Instructions__c = q.Opportunity.Account.shipping_instructions__c;
            q.Master_Agreement__c = q.Opportunity.Account.Master_Agreement__c;
                                                                                                //IBA-3101 End
            quotes1.add(q);
        }
        
        update quotes1;
        
    }
    
    public static boolean checkUserPermission(){
        
        Boolean user_has_permission = false;
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>([SELECT PermissionSet.Name FROM PermissionSetAssignment 
                                                                                   WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSet.Name ='Permission_to_update_SAP_Accounts']);
        User u = [SELECT UserRole.Name,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        if ( !psaList.isEmpty() || u.Profile.Name=='System Administrator' ){        
            user_has_permission= true;  
        }
        return user_has_permission;
    }
    
    public static boolean checkUserPermissionToUpdateNotes(){//IBA-2484
        
        Boolean user_has_permission = false;
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>([SELECT PermissionSet.Name FROM PermissionSetAssignment 
                                                                                   WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSet.Name ='Permission_to_update_Account_Notes']);
        User u = [SELECT UserRole.Name,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        if ( !psaList.isEmpty() || u.Profile.Name=='System Administrator' ){   
            user_has_permission= true;  
        }
        return user_has_permission;
    }
    
    public static String validationCheck(boolean has_sales_org,boolean has_partner_type,boolean has_transport_zone,boolean has_customer_type){ //IBA-2484
        String errorMsg = '';
        if (!has_sales_org){
             errorMsg = 'Account Record Must Include Sales Organization Data.';
        }
        else if (!has_partner_type) { 
             errorMsg = 'Account Record Must Include Partner Type.';
        }
        else if (!has_transport_zone) { 
             errorMsg = 'Account Record Must Include Transportation Zone.'; 
        }
        else if (!has_customer_type){ 
             errorMsg = 'Account Record Type Must be \'NAA Customer\' or \'International\'.';
        } 
        return errorMsg;
    }//IBA-2484
    
    public static boolean AllowSaveWithoutPermission(List<Account> newAccnts,Map<Id, SObject> oldItems){
        
        boolean hasFieldChanged = true;
        string accountRole;
        
        if((newAccnts != null && newAccnts.size() > 0) && (oldItems != null && oldItems.size() > 0)) {
            
            for(Account n : newAccnts){
                
                // if this is a validated account
                if (n.Validation_Status__c == 'Validated') {
                    
                    //translate account role for new account
                    if (n.Account_Role__c == 'ZGPO' || n.Account_Role__c == 'ZIDN'){ accountRole = 'ZCSP'; } else accountRole = n.Account_Role__c; 
                    
                    // get the old values
                    Account pv = (Account)oldItems.get(n.Id);
                    
                    // has required fields been changed
                    if( (n.Validation_Status__c != pv.Validation_Status__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.RecordTypeId != pv.RecordTypeId)){
                        hasFieldChanged = false;
                    }
                    else if( (n.IsDeleted__c != pv.IsDeleted__c)){
                        hasFieldChanged = false;
                    }                   
                    else if( (n.Transport_Zone__c != pv.Transport_Zone__c)){
                        hasFieldChanged = false;
                    }
                    else if( (accountrole != pv.Account_Role__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.Transport_Zone__c != pv.Transport_Zone__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.Account_Territory__c != pv.Account_Territory__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.SAP_Account_ID__c != pv.SAP_Account_ID__c)){
                        hasFieldChanged = false;
                    }
                    /* Below lines are commented and replaced for SF-BUG-547
else if( (n.Primary_Language__c != pv.Primary_Language__c)){
hasFieldChanged = false;
}*/
                    /* Below lines are added for SF-BUG-547 */
                    else if( (n.Primary_Language__c != pv.Primary_Language__c)){
                        User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
                        //System.debug('User Profile : '+u.profile.name);
                        
                        if ( u.profile.name == 'Sales Manager' || u.profile.name == 'Sales Representative' ||  u.profile.name == 'Sales Development' ||
                            u.profile.name == 'International Sales Representative' || u.profile.name == 'International Sales UK' ||
                            u.profile.name == 'International Sales France' || u.profile.name == 'International Sales Ops'  ||
                            u.profile.name == 'System Administrator' || u.profile.name == 'Business Administrator' )                            
                        { hasFieldChanged = true;}
                        else {  hasFieldChanged = false;}
                        
                    }
                    
                    /* Above lines are added for SF-BUG-547 */
                    else if( (n.Master_Agreement__c != pv.Master_Agreement__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.Partner_Type__c != pv.Partner_Type__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.BillingCountryCode != pv.BillingCountryCode)){
                        hasFieldChanged = false;
                    }
                    else if( (n.BillingStreet != pv.BillingStreet)){
                        hasFieldChanged = false;
                    }
                    else if( (n.BillingStateCode != pv.BillingStateCode)){
                        hasFieldChanged = false;
                    }
                    else if( (n.BillingCity != pv.BillingCity)){
                        hasFieldChanged = false;
                    }
                    else if( (n.BillingCountry != pv.BillingCountry)){
                        hasFieldChanged = false;
                    }
                    else if( (n.BillingPostalCode != pv.BillingPostalCode)){
                        hasFieldChanged = false;
                    }
                    else if( (n.Account_Status__c != pv.Account_Status__c)){
                        hasFieldChanged = false;
                    }
                    else if( (n.Master_Agreement__c != pv.Master_Agreement__c)){
                        hasFieldChanged = false;
                    }
                    else if( n.Customer_AR_Notes__c != pv.Customer_AR_Notes__c){ //IBA-2484 - Start
                    	hasFieldChanged = false;
                    }
                    else if( n.Customer_SO_Notes__c != pv.Customer_SO_Notes__c){
                     	hasFieldChanged = false;   
                    } 
                    else if( n.Shipping_Notes__c != pv.Shipping_Notes__c ){
                     	hasFieldChanged = false;   
                    }
                    else if( n.Sales_Notes__c != pv.Sales_Notes__c){
                     	hasFieldChanged = false;   
                    }//IBA-2484 - End
                } 
            }
        }
        return hasFieldChanged;
    }
    
    // check if sales org record exists for given account
    public static integer checkSalesOrgData(ID accountId){
        Integer count = [SELECT count() FROM SAP_Sales_Org__c where Account__c =: accountId];
        return count; 
    }
    
    //Method to get the map of recordType Name as key and recordTypeId as value 
    Public static Map<String,Id> getRecordTypes(){
        String obj='Account';
        Map<String,Id> recordTypeMap=new Map<String,Id>();
        if(obj!= null){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()){
                recordTypeMap.put(recInfo.getName(),recInfo.getRecordTypeId());
            }
        }        
        return recordTypeMap;       
    }
    
    public static void deleteAccountTeam(List<Account> accList){
        /* List<AccountTeamMember> atmList = new List<AccountTeamMember>();
List<Account> accList1 = [SELECT Id,(SELECT Id FROM AccountTeamMembers) FROM Account WHERE Id in: accList];
for(Account acc: accList1){
If(acc.accountTeamMembers.size()>0){
for(AccountTeamMember atm : acc.accountTeamMembers){
atmList.add(atm);
}
}
}
if(atmList.size()>0)
delete atmList;*/
    }
    /*public static void deleteOpportunityTeam(List<Account> accList){
List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
for(Opportunity opp:[SELECT Id,AccountId,(SELECT Id FROM OpportunityTeamMembers) FROM Opportunity WHERE AccountId In: accList]){
If(opp.OpportunityTeamMembers.size()>0){
for(OpportunityTeamMember otm : opp.OpportunityTeamMembers){
otmList.add(otm);
}
}
}
if(otmList.size()>0)
delete otmList;
}*/
    /*commented this method as part of IBA-4798
    public static void updateContactOwner(List<Account> accnts){
        //System.debug(accnts);
        List<Contact> updateConList = new List<Contact>();
        List<Contact> conList = [SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId In: accnts];
        Id ownerId = (Id)Label.Admin_Integration_User_Id;
        //System.debug(conList);
        for(Contact con : conList){
            if(ownerId!=NULL){
                con.OwnerId = ownerId; 
                con.Is_Active__c= 'N';
                con.Inactive_Reason__c=Label.ContactInactiveReason;
                //System.debug('con' +con);
                if(!updateConList.contains(con))
                    updateConList.add(con);
            } 
        }
        try{    
            System.debug(updateConList);
            Database.update(updateConList,false);
        }
        Catch(Exception e){
            //System.debug(e);
        }
    }commented this method as part of IBA-4798*/ 
    
    //This method is to update associated contacts owner to Admin integration when account is_deleted__c =true
    /*public static void updateContactOwner1(List<Account> accnts){
System.debug(accnts);
List<Contact> conList = [SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId In: accnts];
List<AccountContactRelation> acrDelList = new List<AccountContactRelation>();
List<Contact> updateConList = new List<Contact>();
Map<Id, Integer> acrCountMap = new Map<Id, Integer>();
Map<String, AccountContactRelation> conAcrMap = new Map<String, AccountContactRelation>();
for(AccountContactRelation acr : [SELECT Id, ContactId, AccountId, IsDirect,roles FROM AccountContactRelation WHERE ContactId In: conList]){
String str = (String)acr.ContactId+(String)acr.AccountId; 
Integer count = 0; 
conAcrMap.put(str,acr);
if(!acrCountMap.containsKey(acr.ContactId))
acrCountMap.put(acr.ContactId,0);
count = acrCountMap.get(acr.ContactId);
count++;
acrCountMap.put(acr.ContactId,count);
}
Id ownerId = (Id)Label.Admin_Integration_User_Id;
for(Contact con : conList){
//if(acrCountMap.get(con.id)>1)
//{
//  String str = (String)con.Id+(String)con.AccountId;
//  if(!acrDelList.contains(conAcrMap.get(str)))
//  acrDelList.add(conAcrMap.get(str));
//}
//else
if(acrCountMap.get(con.id)==1){
System.debug('ownerId' +ownerId);
if(ownerId!=NULL){
con.OwnerId = ownerId;
con.Is_Active__c= 'N';
con.Inactive_Reason__c=Label.ContactInactiveReason;
System.debug('con' +con);
if(!updateConList.contains(con))
updateConList.add(con);
}
} 
}
try{
System.debug('updateConList' +updateConList);
Database.update(updateConList,false);
// Database.delete(acrDelList,false);
}
Catch(Exception e){
System.debug(e);
}       
}*/
    
    //If Account.Validation_Status__c=Validated && Account. SAP_Account_ID__c!=null and contacts which have SAP_Contact_ID__c='' then sending all those contacts to SAP,which are currently associated to this account.
    public void sendAllContactsToCastIron(List<Account> accnts,List<Account> oldAccnts)
    {
        
        List<Contact> conlist = new List<Contact>();
        set<Id> newconIds = new set<Id>();
        set<Id> oldaccid = new set<Id>();
        string sapacctid='';
        
        for(Account oldact: oldAccnts)
        {
            oldaccid.add(oldact.Id);
            //system.debug('oldaccid..'+oldaccid);
            sapacctid = oldact.SAP_Account_ID__c;
            //system.debug('sapacctid..'+sapacctid);
            
        }
        
        conlist=[select id,AccountId from contact where AccountId IN:oldaccid and SAP_Contact_ID__c=null];
        //system.debug('conlist..'+conlist);
        
        
        
        for(Account a : accnts){
            if(a.Validation_Status__c=='Validated' && a.SAP_Account_ID__c!=null){
                //system.debug('a.Validation_Status__c..'+a.Validation_Status__c);
                //system.debug('a.SAP_Account_ID__c..'+a.SAP_Account_ID__c);
                if(conlist.size()>0)
                {
                    for(contact con : conlist)
                    {
                        if(con.AccountId == a.Id)
                        { 
                            //system.debug('con.AccountId...'+con.AccountId);
                            newconIds.add(con.Id);
                            //system.debug('newconIds...'+newconIds);
                        }
                    }
                }       
            }
        }         
        //if(System.IsBatch() == false && System.isFuture() == false && newconIds.size()>0)
        if(System.IsBatch() == false){
            //system.debug('Check batch is running..');
            if(System.isFuture() == true){
                //system.debug('Check future is running..');
                if(newconIds.size()>0)
                { 
                    //system.debug('Check list size..');
                    //OmnicellContactToCastIron_Class.callOutMethodInsert(newconIds); // code added for the bulkification in the same insert method
                }
            }
        }
        
    }      
    // This method is to populate Top Level Parent of An Account
    /*Public void getTopLevelParent(List<Account> accList){
for(Account acc: accList){
Boolean topLevelParent = false;
Id id=acc.ParentId;
while ( !topLevelParent ) {
if(id!=null){
Account a = [ Select Id, ParentId From Account where Id =: id ];
if ( a.ParentID != null ) {
id = a.ParentID;
}
else {
id=a.id;
topLevelParent = true;
}
}
else{
topLevelParent = true;
}
}
if(id!=acc.Id)
acc.Top_Level_Parent__c =id;
}
}*/
    
    public static void validationBasedOnUsers(map<id, sObject>oldmap, map<id, sObject> newmap, list<Account> lstAcc){
        Schema.FieldSet fs1 = Schema.SObjectType.Account.fieldSets.getMap().get('AccountTeamPer');
        
        for(Account objAcNew : lstAcc){
            //Object o = objAcNew.get(fieldName);
            //String returnValue = String.valueOf(o);
        }
        //schema.describefieldresult dfield = sfield.getDescribe();
        //fieldsName.add(new SelectOption(dfield.getName(),dfield.getLabel()));
        /*<apex:repeat value="{!$ObjectType.Contact.FieldSets.properNames}" var="f"> 
<apex:outputText value="{!Contact[f]}" /><br/>
</apex:repeat>*/
        
    }
    //SF-BUG-592 Start
    public static void updateAccountTerritoryName(List<Account> accList,Map<Id, SObject> oldMap){
        List<string> zipCodeList = new List<string>(); 
        List<string> countryList = new List<string>();
        //List<Decimal> DHCList = new List<Decimal>();
        Set<string> territories = new Set<string>();
        String billingPostalCode = '';
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
            if(atl.Country__c != null && (!countryMap.containsKey(atl.Country__c) || countryMap.get(atl.Country__c) == null)
               &&(atl.Zipcode__c == null)) {                        
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
            billingPostalCode = '';
            if(a.BillingPostalCode!= null)
            {  billingPostalCode = a.BillingPostalCode; }
            if(a.BillingPostalCode!= null && a.billingPostalCode.contains('-'))
            {  billingPostalCode = a.billingPostalCode.split('-')[0];  }
            //Set Territory Name                   
            if (!String.isBlank(a.BillingPostalCode) || !String.isBlank(a.BillingCountry))
            {    
                /* if(billingPostalCode!= null && zipCodeMap.size()>0 && zipCodeMap.get(billingPostalCode) != null && zipCodeMap.get(billingPostalCode).Territory_Name__c !=null) {
a.Territory_Name__c = zipCodeMap.get(billingPostalCode).Territory_Name__c;
isSetTerritoryName = true;
}*/            
                if(!isSetTerritoryName && countryMap.size()>0 && a.billingCountry != null &&
                   countryMap.get(a.billingCountry) != null && countryMap.get(a.billingCountry).Territory_Name__c != null)
                {  a.Territory_Name__c = countryMap.get(a.billingCountry).Territory_Name__c;  isSetTerritoryName = true; }
                if(a.BillingPostalCode!= null && a.BillingCountry != null && !isSetTerritoryName) {
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
        if(zipCode.length() >= index)
        {
            zipCodeList.add(zipcode.substring(0,index));
        }
    }
    public static String getSubstringBasedOnIndexAndConcatCountry(String zipCode, Integer index, String country,
                                                                  Map<String,Territory_Zipcodes__c> zipCodeMap)
    {
        string formattedCode = '';
        string territoryName = '';
        if(zipCode.length() >= index)
        {
            formattedCode = zipcode.substring(0,index);
            formattedCode = formattedCode +'--'+country;
            if(zipCodeMap.get(formattedCode) != null && zipCodeMap.get(formattedCode).Territory_Name__c !=null)
            { territoryName = zipCodeMap.get(formattedCode).Territory_Name__c; }
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
    
    public static void updateAccountFromAccountTerritoryInformation (List<Account> accList,Map<Id, SObject> oldMap,Set<string> territories){
        
        List<Account_Territory_Information__c> objList = [SELECT Territory_Name__c,Country_Cluster__c,Region__c,Division__c,
                                                          Account_Territory__c 
                                                          FROM Account_Territory_Information__c
                                                          WHERE Territory_Name__c =: territories LIMIT 50000];
        
        
        Map<String,UserTerritory2Association> userAssociationMap = new Map<String,UserTerritory2Association>();
        
        Map<String,Account_Territory_Information__c> accntTerritoryInfoMap = new Map<String,Account_Territory_Information__c>();
        for(Account_Territory_Information__c atl: objList) {
            if(!accntTerritoryInfoMap.containsKey(atl.Territory_Name__c) || accntTerritoryInfoMap.get(atl.Territory_Name__c) == null) {                        
                accntTerritoryInfoMap.put(atl.Territory_Name__c,atl);
            }
        }
        //list<Account_History__c> aHistList = new list<Account_History__c>();
        for(Account a: accList){         
            if (!String.isBlank(a.Territory_Name__c))
            {                     
                if(accntTerritoryInfoMap.size()>0 && accntTerritoryInfoMap.get(a.Territory_Name__c) != null) {
                    Account_Territory_Information__c accntTerritoryInfo = accntTerritoryInfoMap.get(a.Territory_Name__c);
                    
                    /*Account_History__c accHistory = new Account_History__c() ;
                    accHistory.Account__c = a.id;                    
                    accHistory.ORIGINAL_VALUE__c = a.Division_Account__c;
                    accHistory.User__c = UserInfo.getUserId();*/
                    
                    a.Country_Cluster__c=accntTerritoryInfo.Country_Cluster__c;
                    a.Division_Account__c=accntTerritoryInfo.Division__c;
                    a.Region__c=accntTerritoryInfo.Region__c;
                    a.Account_Territory__c = accntTerritoryInfo.Account_Territory__c;
                    //IBA-3292
                    
                    /*accHistory.NEW_VALUE__c = a.Division_Account__c;
                    accHistory.Field__c = 'Division';
                    if(accHistory.NEW_VALUE__c != accHistory.ORIGINAL_VALUE__c)
                    aHistList.add(accHistory);*/
                }               
                
            }
            /* else
{
a.Country_Cluster__c='';
a.Division_Account__c='';
a.Region__c='';
a.Account_Territory__c ='';                
}*/
        }
        /*if(aHistList.size()>0){
            insert aHistList;
        }*/
        setOwnerIdInAccountsBasedOnTerritoryRole(accList);
    }
    
    
    public static void setOwnerIdInAccountsBasedOnTerritoryRole (List<Account> accList){
        
        //to skip account owner update when it is done from Update Territory button
        RestRequest request = RestContext.request;
        Map<String, String> requestHeaders = new Map<String, String>();
        if(request != null)
            requestHeaders = request.headers;
        else
            requestHeaders = null;
        if((requestHeaders != null && requestHeaders.containsKey('Sfdc-Stack-Depth') 
            && '1'.equals(requestHeaders.get('Sfdc-Stack-Depth'))))
        {return;}
        
        //populate accountTerritoryMap and territorySet
        Set<Id> accountIds = new Set<Id>();
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
        { return;}
        territoryIds= new Set<Id>();
        List<UserTerritory2Association> userTerrAssList = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive from UserTerritory2Association 
                                                           where Territory2Id in:territorySet and User.IsActive =: true and RoleInTerritory2 = 'Account Owner'];
        for(UserTerritory2Association uta:userTerrAssList){
            for (Account acct: accList)
            {    if(acct.IsDeleted__c)
            { continue;}
             territoryIds = accountTerritoryMap.get(acct.Id);
             if(territoryIds!= null && territoryIds.size() > 0 && territoryIds.contains(uta.Territory2Id))
             { acct.ownerId = uta.userId;}
            }
        } 
    }     
    // SF-BUG-592 End
    //IBA-1148 START
    public static void createAccountApprovalRecord(List<Account> accList) {
        List<Account_Approval__c> aarList = new List<Account_Approval__c>();
        for(Account a : accList) {
            Account_Approval__c aar = new Account_Approval__c();
            aar.Account__c = a.id;
            aar.Request_Type__c = 'Account Validate Request';
            aarList.add(aar);
        }
        if(aarList.size() > 0 && aarList != Null) {
            try {
                insert aarList;
            }catch(Exception e) {
                System.debug('Exception:' +e);
            }  
        }
        
    }
    //IBA-1148 END
    //IBA-1597 START
    public static void sendCreditInfoUpdateNotification(Account acc){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Notify Updates to Account Credit Fields'];
        
        message.setTemplateID(emailTemplate.Id); 
        
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Account.Name}', acc.Name);
        if (acc.SAP_Customer_Number__c != NULL)
            plainBody = plainBody.replace('{!Account.SAP_Customer_Number__c}', String.valueOf(acc.SAP_Customer_Number__c));
        else
            plainBody = plainBody.replace('{!Account.SAP_Customer_Number__c}', '');
        if (acc.Credit_Amount_Approved__c != NULL)
            plainBody = plainBody.replace('{!Account.Credit_Amount_Approved__c}', String.valueOf(acc.Credit_Amount_Approved__c));
        else
            plainBody = plainBody.replace('{!Account.Credit_Amount_Approved__c}', '');
        if (acc.Credit_Approval_Comment__c != NULL) 
            plainBody = plainBody.replace('{!Account.Credit_Approval_Comment__c}', String.valueOf(acc.Credit_Approval_Comment__c));
        else
            plainBody = plainBody.replace('{!Account.Credit_Approval_Comment__c}', '');
        plainBody = plainBody.replace('{!Account.Link}', URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id);
        
        Territory2Model currTerriModel = [Select Id from Territory2Model where state = 'Active'];
        List<UserTerritory2Association> usr1 = [Select UserId from UserTerritory2Association where RoleInTerritory2 in ('Health Systems Executive', 'Client Success Executive', 'Sales Consultant', 'Account Owner') and Territory2Id in (Select Territory2Id from ObjectTerritory2Association where objectId = :acc.id and Territory2.Territory2ModelId = :currTerriModel.Id)];
        List<String> usr = new List<String>();
        for (UserTerritory2Association uTA : usr1){
            if(usr != null){// START Abhrjit IBA-1724
                usr.add(uTA.UserId);
            }// END Abhrajitc IBA-1724
        }
        List<user> usrEmail = [select email from user where id in :usr];
        Set <user> usrSet = new Set<user>(); //Remove Duplicate
        usrSet.addAll(usrEmail);
        
        List<String> usrList = new List<String>();
        for (user u : usrSet){
            usrList.add(u.email);
        }
        if(Test.isRunningTest()){
            usrList.add('shuvodev.roy@omnicell.com');
        }        
        message.setPlainTextBody(plainBody);
        message.setToAddresses(usrList);
        message.setSenderDisplayName('Credit info update alert'); 
        message.setReplyTo('no-reply@omnicell.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false);
        message.setSubject(emailTemplate.Subject);
        //System.debug(usrList);
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }
    //IBA-1597 END
    /*============================================================================= 
Account- After Update handler  
Modified By: Subramanyam Gopinath  
Modified Date: 8-Jan-2021  
=============================================================================*/ 
    
    public void DeactivateUser(List<Account> newItems){
        // AFTER UPDATE LOGIC  
        
        //List<Account> newAccount = newItems;
        for(Account AccObject : newItems) {
            if(AccObject.IsDeleted__c == True && AccObject.Account_Role__c == 'ZCSN'){
                AccId.add(AccObject.id);   
            }  
        }  
        if(!AccId.isEmpty())
        {
            List<Contact> conList=[Select id,AccountId from contact where AccountId=:AccId];   
            system.debug('conList-'+conList);  
            for(Contact con:conList){  
                //System.debug('Contact List Loop');
                ConId.add(con.id);
            }  
        }
        
        if(!ConId.isEmpty()){
            List<User> UserObj = [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where u.ContactId in :ConId];
            System.debug('UserList loop');
            if (UserObj.size()>0){
                for(User UserObj1 : UserObj ){
                    UserList.add(UserObj1.id);
                }
                try {  
                    UpdateUser(UserList);  
                }  
                catch(DmlException e) {
                    System.debug('Exception has occurred: ' + e.getMessage());
                } 
            }
        }
        
    }  
    
    // Future method to update the related User record
    
    @future
    public static void UpdateUser(Set<id> newUser){
        List<User> UserList1 = new List<User>();  
        
        List<User> UserObj2 = [Select u.Id, u.IsActive, u.IsPortalEnabled,u.FederationIdentifier from User u where Id in :newUser];   
        if(!UserObj2.isEmpty()){
            for(User UserObj1 : UserObj2 ){
                if(UserObj1.IsActive){
                    UserObj1.IsActive = false;
                    UserObj1.IsPortalEnabled = false;  
                    UserObj1.FederationIdentifier=''; 
                    UserList1.add(UserObj1);               
                }  
            }  
            
            try{   
                if (UserList1.size()>0){   
                    UserTriggerHandler.isFirstRun = false; //IBA-5967 SH
                    update UserList1;   
                }   
            }  
            catch(DmlException e) {
                System.debug('Exception has occurred: ' + e.getMessage());
            }  
        } 
    }
    //IBA-1988
    public void setAccValues(List<Account> accList) {
        for(Account acc : accList) {
            if(acc.Created_from_Lead__c == true) {
                acc.Account_Role__c = 'ZCSN';
                acc.Facility_Type__c = 'Other';
                acc.Company_Status__c = 'Active';
                acc.Account_Status__c = 'Prospect';
            }
            //IBA-1202 Start
            //System.debug('***'+acc.BillingStateCode);
            //System.debug('***'+acc.BillingCountryCode);
            //System.debug('***'+acc.Transport_Zone__c);
            if(acc.Transport_Zone__c == Null){
                if(acc.BillingCountryCode == 'US'){
                    acc.Transportation_Zone_Country__c = 'US';
                    List<Transportation_Zone_Mapping__c> mappingDate = [Select TRANSPORTATION_ZONE__c From Transportation_Zone_Mapping__c Where COUNTRY_CODE__c =:acc.BillingCountryCode AND REGION_CODE__c =:acc.BillingStateCode Limit 1];             
                    if(mappingDate.size()>0){
                        acc.Transport_Zone__c = mappingDate[0].TRANSPORTATION_ZONE__c;
                    }
                }
                else if(acc.BillingCountryCode == 'CA'){
                    acc.Transportation_Zone_Country__c = 'CA';
                    List<Transportation_Zone_Mapping__c> mappingDate = [Select TRANSPORTATION_ZONE__c From Transportation_Zone_Mapping__c Where COUNTRY_CODE__c =:acc.BillingCountryCode AND REGION_CODE__c =:acc.BillingStateCode Limit 1];
                    if(mappingDate.size()>0){
                        acc.Transport_Zone__c = mappingDate[0].TRANSPORTATION_ZONE__c;
                    }
                }
                else{
                    acc.Transportation_Zone_Country__c = acc.BillingCountryCode;
                    List<Transportation_Zone_Mapping__c> mappingDate = [Select TRANSPORTATION_ZONE__c From Transportation_Zone_Mapping__c Where COUNTRY_CODE__c =:acc.BillingCountryCode Limit 1];
                    if(mappingDate.size()>0){
                        acc.Transport_Zone__c = mappingDate[0].TRANSPORTATION_ZONE__c;
                    }
                    else{
                        acc.Transport_Zone__c = 'IN00000002';
                    }
                    
                }
            }
            //IBA-1202 End
        }
    }
    
    //IBA-2186
    private static void updateRefEdgeValues(List<Account> accList) {
        Set<String> setPicklistValues = new Set<String>();
        for(Reference_Edge_Map__mdt edgeMap : Reference_Edge_Map__mdt.getAll().values()) setPicklistValues.add(edgeMap.DHCEmar__c.toUpperCase());
        
        List<Reference_Edge_Map__mdt> setPickValue = Reference_Edge_Map__mdt.getAll().values();
        for (Account objAcc : accList){
            if (objAcc.DHC_eMar__c != null && setPicklistValues.contains(objAcc.DHC_eMar__c.toUpperCase())){
                objAcc.DHC_eMar_Ref__c = objAcc.DHC_eMar__c;
            }
        }
    }
    
    //IBA-1697
    private Account_History__c createUpdateHistory(Schema.DescribeFieldResult field, string oldacc, string newacc, account acc) {
        Account_History__c accHistory = new Account_History__c();
        accHistory.Account__c = acc.Id;
        accHistory.Field__c = field.getLabel();
        if(field.getLabel() == 'GPO Account'){
            accHistory.Field__c = 'GPO Account Name';
        }
        accHistory.User__c = UserInfo.getUserId();
        //accHistory.Edited_Time__c = string.valueOf(Datetime.now());       
        
        if (oldacc != null) accHistory.ORIGINAL_VALUE__c = oldacc;
        if (newacc != null) accHistory.NEW_VALUE__c = newacc;
        
        return accHistory;
    }
    
    //IBA-2889
    @future
    public static void updateContactIsDeleted(set<id> accId, Boolean IsDel){
        
        Map<Id, Contact> ConDetail = new Map<Id, Contact>([SELECT Id, AccountId, FirstName, SAP_Contact_ID__c, SAP_Contact_GUID__c, Account_IsDeleted__c FROM Contact where AccountId IN: accId]);
        List<Contact> ContactListToBeUpdated = new List<Contact>();
        for(Contact c : ConDetail.values()){
            if((c.SAP_Contact_ID__c != null && (c.SAP_Contact_ID__c.length() == 10 || c.SAP_Contact_ID__c.length() == 0)) && c.SAP_Contact_GUID__c != null){
                System.debug('Name '+c.FirstName + ' AccId: ' +c.AccountId + ' newIsDelacc: ' + IsDel + ' IsDelcon: '+ c.Account_IsDeleted__c);
                c.Account_IsDeleted__c = IsDel;
                ContactListToBeUpdated.add(c);
            }
        }
        
        
        ContactTriggerHandler.TriggerDisabled = True;
        if(ContactListToBeUpdated.size()>0 && ContactListToBeUpdated!=null){
            Update ContactListToBeUpdated;
        }
        ContactTriggerHandler.TriggerDisabled = False;
        
    }
     //IBA-2820 Pabitra
    public void parentChangeTiCalculation(Map<Id,Account> mpOldAcc,List<Account> newAccnts, boolean runTer,Set<String> accountIds, boolean isInsert){      
        Set<Id> TIAcct=new Set<Id>();
        Set<Id> curAcctParent=new Set<Id>();  
        Set<Id> topLevelParAcctIds=new Set<Id>();            
        Set<Id> newParentIds = new Set<Id>();    
        Set<Id> oldTopLvlParentIds = new Set<Id>();
        Set<Id> oldParentId = new Set<Id>();    
        boolean processTi = false;   
        boolean isCreate = false;
        Set<Id> imptAcc = new Set<Id>();
        Set<Id> imptAcc2 = new Set<Id>();// IBA-3677
        list<account> accounts = new list<account>(); // IBA-3677
        set<string> paccounts = new set<string>(); // IBA-3677
        boolean topLp = false; // IBA-3677
        boolean runTI = false; // IBA-3677
        
        //IBA-3937 starts
        Boolean RATRisDisabled; 
        Class_Configuration__c cc = Class_Configuration__c.getInstance('RunAccountTerritoryRules');
        if(cc != null) RATRisDisabled = cc.isDisabled__c;
        //IBA-3937 ends
        
        list<Account_Segment_ParentId__c> asegList = new list<Account_Segment_ParentId__c>(); // IBA-3677
        string oldpid;
        string newpid;
        for(Account nAcc : newAccnts){
            if(mpOldAcc!=null){
                Account oldAcc=mpOldAcc.get(nAcc.Id);
                if(oldAcc.ParentId != null){
                    oldpid=oldAcc.ParentId;
                }
                if(nAcc.ParentId != null){
                    newpid=nAcc.ParentId;
                }
                
                //Top level parent IBA-3677
                if(oldAcc.ParentId != nAcc.ParentId){
                    imptAcc2.add(nAcc.id);
                    topLp = true;
                    paccounts.add(oldAcc.Top_level_1__c);
                }
                if(nAcc.ParentId!=oldAcc.ParentId && oldAcc.ParentId!=null){ //old parent removed so need to recalculate TI
                    oldTopLvlParentIds.add(oldAcc.Top_Level_CaseSafeID__c);
                    oldTopLvlParentIds.add(nAcc.Top_Level_CaseSafeID__c);
                    oldParentId.add(oldAcc.ParentId);
                    processTi = true;
                } 
                if(nAcc.ParentId!=oldAcc.ParentId && nAcc.ParentId!=null){ //parent null -> new, old -> new
                    curAcctParent.add(nAcc.ParentId); //commented as low level hierarcy issue
                    topLevelParAcctIds.add(oldAcc.Top_Level_CaseSafeID__c); //old acc hierarchy 
                    system.debug('oldAcc.Top_Level_CaseSafeID__ '+oldAcc.Top_Level_CaseSafeID__c);
                    newParentIds.add(nAcc.ParentId); // for account's newly parent hierarchy
                    processTi = true;
                }
                //parent is removed and null
                if(nAcc.ParentId!=oldAcc.ParentId && nAcc.ParentId==null){
                    curAcctParent.add(nAcc.Id);  
                    topLevelParAcctIds.add(oldAcc.ParentId);
                    processTi = true;
                }       
            }
            else{ //new Account with parent
                if(nAcc.ParentId!=null){
                   imptAcc.add(nAcc.Id); 
                   curAcctParent.add(nAcc.ParentId); 
                   newParentIds.add(nAcc.ParentId); // for account's newly parent hierarchy
                   topLevelParAcctIds.add(nAcc.Id); 
                    processTi = true; 
                    isCreate = true;
                }
            }
        }
        Set<Id> tlpChilds = new Set<Id>();// IBA-3677
        Set<Id> oldTlpChilds = new Set<Id>();// IBA-3677
        boolean isRunOldParent = false;// IBA-3677
        if(processTi && TiUpdate){
            TiUpdate = false;
            if(newParentIds.size()>0){ //when newly parent added ;newly added parent's old hierarchy
                List<Account> accTopLvlList=[SELECT Id,Top_Level_CaseSafeID__c FROM Account 
                                             WHERE Id IN :newParentIds];  
                for (Account act:accTopLvlList){
                    if(act.Top_Level_CaseSafeID__c!=null){
                        topLevelParAcctIds.add(act.Top_Level_CaseSafeID__c);
                        if(!isCreate)
                            curAcctParent.add(act.Top_Level_CaseSafeID__c);
                    }
                }            
            }
            System.debug('Ti curAcctParent '+curAcctParent +' topLevelParAcctIds '+ topLevelParAcctIds); 
            Map<Id,Set<Id>> oldParentChildMap = new Map<Id,Set<Id>>();
            if(topLevelParAcctIds.size()>0)
                    oldParentChildMap = getParentChildMap(topLevelParAcctIds,isCreate,imptAcc);
            System.debug('Ti oldParentMap'+oldParentChildMap);
            //top level parent childs
            tlpChilds = topLevelChilds(curAcctParent,oldParentChildMap);
            tlpChilds.addAll(curAcctParent);
            tlpChilds.addall(imptAcc2);
            System.debug('Ti tlpChilds size'+tlpChilds.size()+' tlpChilds '+tlpChilds);
            
            //Old Parent Cleanup : For Old parent's ti recalculation
            Map<Id,Set<Id>> oldParentChildMap1 = new Map<Id,Set<Id>>();
            
            if(oldTopLvlParentIds.size()>0){
                oldParentChildMap1 = getParentChildMap(oldTopLvlParentIds,isCreate,oldParentId);
                oldTlpChilds = topLevelChilds(oldParentId,oldParentChildMap1);
                oldTlpChilds.addAll(oldParentId);
                if(oldTlpChilds.size()>0){
                    isRunOldParent = true;
                }                       
                System.debug('Old Cleanup: TI tlpChilds size'+oldTlpChilds.size()+' tlpChilds '+oldTlpChilds);          
            }
            runTI = true;//IBA-3677
            //System.enqueueJob(new TIParentSegment(tlpChilds,oldTlpChilds,isRunOldParent));//IBA-3677
            
        }
        
        //IBA-3677
        Account_DataLoad__c aDataload = [select isDisabled__c from Account_DataLoad__c where name = 'Dataload' limit 1];
        if(runTI == true && aDataload.isDisabled__c == true){
            runTI = false;
            if(oldpid != null){
                Account_Segment_ParentId__c asp1 = new Account_Segment_ParentId__c(ParentId__c = oldpid);
                asegList.add(asp1);
            }
            if(newpid != null){
                Account_Segment_ParentId__c asp2 = new Account_Segment_ParentId__c(ParentId__c = newpid);
                asegList.add(asp2);
            }
            if(asegList.size() > 0){
                insert asegList;
            }
        }
        if(topLp == true && isInsert != true){
            accounts = [select id,Top_level_1__c,Top_level_2__c,Top_Level_Parent_CSN_Number__c,ParentId,Top_Level_CaseSafeID__c,name,SAP_Customer_Number__c from account where id =:imptAcc2];
            TopLevelParent_update2 job1 = new TopLevelParent_update2() ;
            job1.accounts = accounts;
            job1.paccounts = paccounts;
            job1.topChilds = tlpChilds;
            job1.oldTopChilds = oldTlpChilds;
            job1.isRunOldParent = isRunOldParent;
            job1.accountIdsT = accountIds;
            job1.runTer = runTer;
            job1.runTI = runTI;
            if(!Test.isRunningTest()){
                System.enqueueJob(job1);
            }            
        }/* IBA-3712 else if(runTI == true){
            if(!Test.isRunningTest()){
            System.enqueueJob(new TIParentSegment(tlpChilds,oldTlpChilds,isRunOldParent,runTer,accountIds));
            }
        }*/else if(runTer == true && !AccountTriggerHandler.isTriggerExecuted && RATRisDisabled == false){ //added RATRisDisabled == false as part of IBA-3937
            AccountTriggerHandler.isTriggerExecuted = true;
            
                RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
                job.accntIds = accountIds; 
                if(!Test.isRunningTest()){
                System.enqueueJob(job);
                }
            
            
        }
        
    }
    //IBA-2820 Pabitra
    Set<Id> topLevelChilds(Set<Id> accSet,Map<Id,Set<Id>> parChildMap){
        Set<Id> finalChildSet = new Set<Id> ();
        finalChildSet.addAll(accSet);
        for(Id acId:accSet){
            if(parChildMap.containsKey(acId)){
                finalChildSet.addAll(parChildMap.get(acId));
            }
            else{
                finalChildSet.add(acId);
            }                    
        }
        if(finalChildSet.size()==accSet.size()){
            return finalChildSet;
        }
        else{
            return topLevelChilds(finalChildSet,parChildMap);
        }
    }//IBA-2820  
    //IBA-2820 Pabitra
    Map<Id,Set<Id>> getParentChildMap(Set<Id> topLevelParAcctIds,boolean isCreate,Set<Id> cngedAcct){
        Map<Id,Set<Id>> oldParentChildMap=new Map<Id,Set<Id>>();
        List<Account> accList=[SELECT Id,ParentId,Top_Level_CaseSafeID__c FROM Account 
                               WHERE Top_Level_CaseSafeID__c IN :topLevelParAcctIds]; 
        if(isCreate){
        List<Account> changedAccList=[SELECT Id,ParentId,Top_Level_CaseSafeID__c FROM Account 
                               WHERE Id IN :cngedAcct];   
            accList.addAll(changedAccList);
        }
        System.debug('Ti getParentChildMap accList size'+accList.size());    
        for(Account ac:accList){
            if(ac.ParentId!=null){
                if(oldParentChildMap.containsKey(ac.ParentId)) {
                    Set<Id> mId = oldParentChildMap.get(ac.ParentId);
                    mId.add(ac.Id);
                    oldParentChildMap.put(ac.ParentId,mId);
                }
                else{
                    Set<Id> al=new Set<Id>(); 
                    al.add(ac.Id);                
                    oldParentChildMap.put(ac.ParentId,al);  
                }
            }
        }
        return oldParentChildMap;
    }

    public static void updateLicensedBedsForOC1Quoting(List<Account> acctList){//logic for IBA-3101
        for(Account acc :acctList){
            if(acc.OC1FieldManualUpdate__c == false){ // Added for IBA-3555
                if(acc.DHC_of_Licensed_Beds_formula__c == 0 || acc.DHC_of_Licensed_Beds_formula__c == null){
                    if(acc.texcellency__DefHC_NumBeds__c == null || acc.texcellency__DefHC_NumBeds__c == 0){
                        acc.Licensed_Beds_for_OC1_Quoting__c = 150;
                    }
                    else{
                        acc.Licensed_Beds_for_OC1_Quoting__c = acc.texcellency__DefHC_NumBeds__c;
                    }
                }
                else{
                    acc.Licensed_Beds_for_OC1_Quoting__c = acc.DHC_of_Licensed_Beds_formula__c;
                }
            }
       }
    }
    public static void updateDHCExternalDataField(List<Account> newAcctList, List<Account> oldAcctList){//logic for IBA-3113 starts
        Set<Integer> defID = new Set<Integer>();
        Map<Integer, Account> AccToBeUpdated = new Map<Integer, Account>();
        Account acc = new Account();
        List<External_Data__c> ExData = new List<External_Data__c>();
        for(integer i=0;i<newAcctList.size();i=i+1){
            if(newAcctList[i].texcellency__DefHC_HospitalID__c == null){
                //System.debug('##1newAcctList[i].DHC_External_Data__c = null');
                newAcctList[i].DHC_External_Data__c = null;
            }else if(newAcctList[i].texcellency__DefHC_HospitalID__c != null && newAcctList[i].texcellency__DefHC_HospitalID__c != oldAcctList[i].texcellency__DefHC_HospitalID__c){
                //System.debug('##2newAcctList[i].texcellency__DefHC_HospitalID__c: ' + newAcctList[i].texcellency__DefHC_HospitalID__c + ' ------##3oldAcctList[i].texcellency__DefHC_HospitalID__c: ' + oldAcctList[i].texcellency__DefHC_HospitalID__c);
                defID.add(Integer.valueOf(newAcctList[i].texcellency__DefHC_HospitalID__c));
                AccToBeUpdated.put(Integer.valueOf(newAcctList[i].texcellency__DefHC_HospitalID__c), newAcctList[i]);
            }
        }
        
        if(defID.size()>0 && defID != null){
            ExData = [Select id, Definitive_ID__c from External_Data__c where Definitive_id__c IN: defID];
        }
        
        for(External_data__c ex: ExData){
            acc = AccToBeUpdated.get(Integer.valueOf(ex.Definitive_ID__c));
            acc.DHC_External_Data__c = ex.Id;
        }        
    }//logic for IBA-3113 ends
    
    //IBA-3292
    public static void automationAccountBeforeInsert(List<Account> acctList, List<id> pid){
        map<id,account> pacc = new map<id,account> ([select id, Expected_Date_of_Conversion__c from account where id =: pid]);
        /*list<IsNACAccount_Rule_False__c> nacf = [select name from IsNACAccount_Rule_False__c];
        list<string> nac = new list<string>();
        for(IsNACAccount_Rule_False__c n : nacf){
            nac.add(n.Name);
        }*/
        for(Account acc :acctList){
            //Update Account RT to Competitor
            if(acc.Account_Type__c == 'Competitor'){
                Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
                acc.RecordTypeId = devRecordTypeId;
            }          
                        
            //Update Account RT to Non Buying   
            if(acc.Account_Type__c == 'Non-buying Account'){
                Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non-buying Account').getRecordTypeId();
                acc.RecordTypeId = devRecordTypeId;
            }
            
            //Update Account RT to US & Canada Account
            if(acc.Account_Type__c == 'US & Canada Customer'){
                Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
                acc.RecordTypeId = devRecordTypeId;
            }
            
            //Top level parent to child update                
            if(acc.ParentId != null){
                account p = pacc.get(acc.ParentId);
                acc.Expected_Date_of_Conversion__c = p.Expected_Date_of_Conversion__c;
            }
              
            /*boolean t2 = false;
            if(nac.contains(acc.Facility_Type__c)){
                t2 = true;
            }
            
            string seg = '';
            if(acc.Segment__c != null){
                seg=acc.Segment__c;
            }
            //IsNACAccount_Rule_False
            if(((t2 == true || acc.Territory_Assignment_Criteria__c == 'Acute' || acc.Territory_Assignment_Criteria__c == 'Under 100 Bed – Sales Development') && 
               (acc.Territory_Assignment_Criteria__c != 'NAC Health System Owned' && acc.Territory_Assignment_Criteria__c != 'NAC Health System' 
                && acc.Territory_Assignment_Criteria__c != 'NAC CSE')) || seg.contains('Top Accounts')){
                
                    acc.Is_NAC_Account__c = 'No';
                    
            }
            
            //IsNACAccount_Rule_True
            if(((t2 == false && acc.Territory_Assignment_Criteria__c != 'Acute' && acc.Territory_Assignment_Criteria__c != 'Under 100 Bed – Sales Development') || 
               (acc.Territory_Assignment_Criteria__c == 'NAC Health System Owned' || acc.Territory_Assignment_Criteria__c == 'NAC Health System' 
                || acc.Territory_Assignment_Criteria__c == 'NAC CSE')) || !seg.contains('Top Accounts')){
                
                    acc.Is_NAC_Account__c = 'Yes';
                    
            }*/
            
                       
        }

        
    }
    
    //IBA-3292
    public static void automationAccountInsertUpdate(List<Account> newAccnts, List<id> uid){
        
        
        list<GDPR_is_Inactive_on_Account__c> gd = [select name from GDPR_is_Inactive_on_Account__c];
        list<string> gdp = new list<string>();
        for(GDPR_is_Inactive_on_Account__c n : gd){
            gdp.add(n.Name);
        }
        
        list<GDPRUpdateonAccount__c> gd1 = [select name from GDPRUpdateonAccount__c];
        list<string> gdp1 = new list<string>();
        for(GDPRUpdateonAccount__c n : gd1){
            gdp1.add(n.Name);
        }
        
        for(Account acc :newAccnts){
            //Update IsValidated
            if(acc.Validation_Status__c == 'Validated'){
                acc.IsValidated__c = true;
            }
            
            //GDPR is Inactive on Account 
            if(!gdp.contains(acc.BillingCountry)){
                acc.GDPR__c = false;
            }
            
            //GDPRUpdateonAccount            
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
            Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId();
            Id devRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Non-buying Account').getRecordTypeId();
            Id devRecordTypeId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            list<id> atid = new list<id>();
            atid.add(devRecordTypeId);
            atid.add(devRecordTypeId1);
            atid.add(devRecordTypeId2);
            atid.add(devRecordTypeId3);
            
            if(gdp1.contains(acc.BillingCountry) && atid.contains(acc.RecordTypeId)){
                acc.GDPR__c = true;
            }
            
            //Update (searchable) Definitive ID
            if(acc.texcellency__DefHC_HospitalID__c != null){
                acc.Definitive_Id__c = string.valueOf(acc.texcellency__DefHC_HospitalID__c);
            }
                        
            
            //Update date field according to checkbox commented as part of IBA-4194
            //if(acc.Youreka_Mobile__c == true){
            //    acc.current_Date_sys__c = system.now();
            //}
            
        }
        
    }
    //IBA-3292
    public void automationAccountUpdate(Map<Id,sObject> mapOldAcc,List<Account> newAccnts, List<id> pid,Map<Id,sObject> newItems,List<id> uid1){
        map<id,user> usr = new map<id,user>([select id, email from user where id =: uid1]);
        list<Messaging.SingleEmailMessage> mail = new list<Messaging.SingleEmailMessage>();
        Map<Id, Account> mpOldAcc = (Map<Id, Account>)mapOldAcc;
        list<account> accounts = new list<account>();
        set<string> paccounts = new set<string>();
        boolean topLp = false;
        list<IsNACAccount_Rule_False__c> nacf = [select name from IsNACAccount_Rule_False__c];
        list<string> nac = new list<string>();
        for(IsNACAccount_Rule_False__c n : nacf){
            nac.add(n.Name);
        }
        id uid = [select id from user where name = 'Admin Integration' limit 1].id ;
        map<id,account> pacc = new map<id,account> ([select id, Expected_Date_of_Conversion__c from account where id =: pid]);
        Set<String> accountIds = new Set<String>();//IBA-3677
        //list<Account_History__c> aHistList = new list<Account_History__c>();
        for(Account nAcc : newAccnts){
            
            if(mpOldAcc!=null){
                Account oldAcc=mpOldAcc.get(nAcc.Id); 
                //If Account isDeleted change owner
                if(nAcc.IsDeleted__c!=oldAcc.IsDeleted__c && oldAcc.IsDeleted__c==true){
                    nAcc.ownerId = uid;
                    /*Account_History__c accHistory = new Account_History__c() ;
                    accHistory.Account__c = nAcc.id;                    
                    accHistory.ORIGINAL_VALUE__c = nAcc.Owner_Full_Name__c;
                    accHistory.User__c = UserInfo.getUserId();
                    accHistory.NEW_VALUE__c = 'Admin Integration';
                    accHistory.Field__c = 'Owner Full Name';
                    aHistList.add(accHistory);*/
                    
                }
                
                
                //Top level parent to child update
                if(nAcc.Expected_Date_of_Conversion__c == oldAcc.Expected_Date_of_Conversion__c){
                    if(nAcc.ParentId != null){
                        account p = pacc.get(nAcc.ParentId);
                        if( p != null && p.Expected_Date_of_Conversion__c != null){ //IBA-3916
                            nAcc.Expected_Date_of_Conversion__c = p.Expected_Date_of_Conversion__c;
                        }
                        
                    }
                }
                
                string seg = '';
                if(nAcc.Segment__c != null){
                    seg=nAcc.Segment__c;
                }
                //IsNACAccount_Rule_False
                if( (nAcc.Facility_Type__c != oldAcc.Facility_Type__c || nAcc.Territory_Assignment_Criteria__c != oldAcc.Territory_Assignment_Criteria__c 
                     || nAcc.Segment__c != oldAcc.Segment__c || nAcc.Test_X__c != oldAcc.Test_X__c || nAcc.Validation_Status__c != oldAcc.Validation_Status__c) && 
                   (((nac.contains(nAcc.Facility_Type__c) || nAcc.Territory_Assignment_Criteria__c == 'Acute' || nAcc.Territory_Assignment_Criteria__c == 'Under 100 Bed – Sales Development') && 
                   (nAcc.Territory_Assignment_Criteria__c != 'NAC Health System Owned' && nAcc.Territory_Assignment_Criteria__c != 'NAC Health System' 
                    && nAcc.Territory_Assignment_Criteria__c != 'NAC CSE')) || seg.contains('Top Accounts'))){
                    
                    nAcc.Is_NAC_Account__c = 'No';
                }
                
                //IsNACAccount_Rule_True                
                if((nAcc.Facility_Type__c != oldAcc.Facility_Type__c || nAcc.Territory_Assignment_Criteria__c != oldAcc.Territory_Assignment_Criteria__c 
                     || nAcc.Segment__c != oldAcc.Segment__c || nAcc.Test_X__c != oldAcc.Test_X__c || nAcc.Validation_Status__c != oldAcc.Validation_Status__c) &&
                    ((!(nac.contains(nAcc.Facility_Type__c)) && nAcc.Territory_Assignment_Criteria__c != 'Acute' && nAcc.Territory_Assignment_Criteria__c != 'Under 100 Bed – Sales Development') || 
                   (nAcc.Territory_Assignment_Criteria__c == 'NAC Health System Owned' || nAcc.Territory_Assignment_Criteria__c == 'NAC Health System' 
                    || nAcc.Territory_Assignment_Criteria__c == 'NAC CSE')) && !seg.contains('Top Accounts')){ //IBA-3888
                    
                        nAcc.Is_NAC_Account__c = 'Yes';
                }
                
                //Top level parent
                /*//IBA-3677 if(oldAcc.ParentId != nAcc.ParentId){
                    accounts.add(nAcc);
                    topLp = true;
                    paccounts.add(oldAcc.Top_level_1__c);
                }*/
                
                //Care Engaged Status Since updation - flow
         /*       if(oldAcc.Care_Engaged__c != nAcc.Care_Engaged__c){
                    nAcc.Care_Engaged_Status_Since__c = system.today();
                }        IBA-4149*/
                 
                //AccountFieldTrack
                /*AccountHistoryTrackFormulaField job = new AccountHistoryTrackFormulaField() ;
                job.nAcc = nAcc;
                job.oldAcc = oldAcc;
                System.enqueueJob(job);  */ 
                
                list<string> mailto = new list<string>();
                user mailid = usr.get(nAcc.CreatedById);
                if(mailid != null)
                mailto.add(mailid.email);
                mailid = usr.get(nAcc.OwnerId);
                if(mailid != null)
                mailto.add(mailid.email);
                //Newly created account marked Invalid
                if(nAcc.Validation_Status__c=='Invalid' && (oldAcc.Validation_Status__c != nAcc.Validation_Status__c)){
                    Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                    
                    mail1.setToAddresses(mailto);
                    mail1.setSubject('Newly created account marked Invalid');
                    String meetingInviteBody = 'Hello,<br>'; 
                    meetingInviteBody += 'The below account you recently created in Salesforce has been marked Invalid.<br><br>';        
                    meetingInviteBody += 'Account Name: '+ nAcc.name + '<br>';
                    meetingInviteBody += 'Account CSN: '+ nAcc.SAP_Customer_Number__c + '<br>';
                    meetingInviteBody += 'Reason of Invalid: '+ nAcc.Reason_for_Invalid__c + '<br>';
                    meetingInviteBody += 'Account Link: '+ URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ nAcc.id + '<br>';
                    mail1.setHtmlBody(meetingInviteBody);
                    mail1.saveAsActivity=false;
                    mail.add(mail1);
                   
                }
                //Newly created account marked Validated
                if(nAcc.Validation_Status__c=='Validated' && (oldAcc.Validation_Status__c != nAcc.Validation_Status__c)){
                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                    
                    mail2.setToAddresses(mailto);
                    mail2.setSubject('Recently Created Account Validated');
                    String meetingInviteBody1 = 'Hello,<br>'; 
                    meetingInviteBody1 += 'The below account you recently created in Salesforce is now validated.<br><br>';        
                    meetingInviteBody1 += 'Account Name: '+ nAcc.name + '<br>';
                    meetingInviteBody1 += 'Account CSN: '+ nAcc.SAP_Customer_Number__c + '<br><br>';                
                    meetingInviteBody1 += 'Account Link: '+ URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ nAcc.id + '<br>';
                    mail2.setHtmlBody(meetingInviteBody1);
                    mail2.saveAsActivity=false;
                    mail.add(mail2);
                }
                
                //Send CVS email
                if(nAcc.Master_Agreement__c != null && (oldAcc.Validation_Status__c != nAcc.Validation_Status__c)){
                if((nAcc.Master_Agreement__c.startsWith('51870') && nAcc.IsDeleted__c == false && nAcc.Validation_Status__c == 'Validated' &&
                  nAcc.SAP_Customer_Number__c != null && nAcc.CreatedDate > date.parse('5/19/2020')) || Test.isRunningTest()){
                    Messaging.SingleEmailMessage mail3 = new Messaging.SingleEmailMessage();
                    list<string> mailto1 = new list<string>();
                    mailto1.add('SomRequests@omnicell.com');
                    mailto1.add('ITHELPDESK@omnicell.com');
                    mailto1.add('stacie.wright@omnicell.com');
                    mail3.setToAddresses(mailto1);
                    mail3.setSubject('New CVS Account Created '+nAcc.SAP_Customer_Number__c+'. Maintain the output ZEDI and perform EDI Partner Profile setup');
                    String meetingInviteBody2 = ''; 
                           
                    meetingInviteBody2 += 'Account Name: '+ nAcc.name + '<br><br>';
                    meetingInviteBody2 += 'Account CSN: '+ nAcc.SAP_Customer_Number__c + '<br><br>';
                    meetingInviteBody2 += 'Created Date: '+ nAcc.CreatedDate + '<br><br>';
                    meetingInviteBody2 += 'Master Agreement: '+ nAcc.Master_Agreement__c + '<br><br>';
                    meetingInviteBody2 += 'Account Owner: '+ nAcc.Owner_Full_Name__c + '<br><br>';
                    meetingInviteBody2 += 'Account Link: '+ URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ nAcc.id + '<br>';
                    mail3.setHtmlBody(meetingInviteBody2);
                    mail3.saveAsActivity=false;
                    mail.add(mail3);
                    
                }
                }
                
            }            
            
        }
        /*if(aHistList.size() > 0){
            insert aHistList;
        }*/
        //IBA-3659
        Account_SendEmail_Off__c accSendOff = [select id,Account_SendEmail_Off__c from Account_SendEmail_Off__c where name = 'Account SendEmail Off'];
        if(mail.size()>0 ){
            if(!Test.isRunningTest()){
            if (accSendOff.Account_SendEmail_Off__c == false)//IBA-3659
                Messaging.sendEmail(mail);
            }
        }
        
        
        /*//IBA-3677 Map<Id, Account> NewAcc = (Map<Id, Account>)newItems;
        Map<Id, Account> OldAcc = (Map<Id, Account>)mapOldAcc;
        AccountTriggerHandler_Top200Customer job = new AccountTriggerHandler_Top200Customer() ;
        job.newAccounts = NewAcc;
        job.oldAccounts = OldAcc;
        job.isInsert = false;
        if(topLp == true){
            job.accounts = accounts;
            job.paccounts = paccounts;
            job.topLp = topLp;            
        }
        if(!Test.isRunningTest()){
        System.enqueueJob(job);
        }*/
    }
    
    @future
    //IBA-3341 starts
    public static void createExDataAfterAccCreation(Set<String> accIds){
        Map<Id, External_Data__c> exdata = new Map<Id, External_Data__c>();
        String NAARecTypeIdExData = SObjectType.External_Data__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(); //IBA-3632
        for(String AccountId: accIds){
            exdata.put(AccountId, new External_Data__c(AccountID__c = AccountId, RecordTypeId = NAARecTypeIdExData)); //IBA-3632 added RecordTypeId
        }
        if(exdata.size() > 0 && exdata != null){
            insert exdata.values();
        }
    }
    //IBA-3341 ends
    
    
    public void insertRelationShipOnGuarantorChange(Map<id, Account> newMap, Map<id, Account> oldMap){
        system.debug('inside insertRelationShipOnGuarantorChange');
        Map<Id, Id> changedAccountList = new Map<Id, Id>();
        List<Id> oldGuarantorList = new List<Id>();
        for(Account acc : newMap.values())
        {
            if(acc.Own_Guarantor__c && acc.Credit_Approved_For__c <> NULL)
            {
                acc.addError('Please remove value from Guarantor field when CSN itsef is Guarantor');
            }
            if(acc.Own_Guarantor__c <> oldMap.get(acc.Id).Own_Guarantor__c)
            {
                changedAccountList.put(acc.id, acc.id);
                
                if(acc.Own_Guarantor__c)
                    oldGuarantorList.add(oldMap.get(acc.id).Credit_Approved_For__c);
            }
            if(acc.Credit_Approved_For__c <> oldMap.get(acc.id).Credit_Approved_For__c)
            {
                if(acc.Own_Guarantor__c == oldMap.get(acc.Id).Own_Guarantor__c)
                    changedAccountList.put(acc.id, acc.Credit_Approved_For__c);
                
                if(oldMap.get(acc.id).Credit_Approved_For__c <> NULL)
                    oldGuarantorList.add(oldMap.get(acc.id).Credit_Approved_For__c);
                
                if(oldMap.get(acc.id).Own_Guarantor__c && !acc.Own_Guarantor__c && oldMap.get(acc.id).Credit_Approved_For__c == NULL)
                    oldGuarantorList.add(acc.id);
            }
        }
        
        system.debug('changedAccountList-->'+changedAccountList);
        if(!changedAccountList.isEmpty()){
            Set<String> bookedStatusSet = new Set<String>();
            bookedStatusSet.add('Non Comissionable Booking');
            bookedStatusSet.add('Fully Booked');
            bookedStatusSet.add('Commissionable - No Service PO');
            bookedStatusSet.add('Non Comm. Book - No Service PO');
              // IBA-4182 Starts   bookedStatusSet.add('Non Comm. Book - No Proj. Plan');
            bookedStatusSet.add('Booked with No PO');
            bookedStatusSet.add('Booked with No Service PO');
            bookedStatusSet.add('Booked with No Product PO');  // IBA-4182 Ends 
            List<String> oppIdList = new List<String>();

            for(Opportunity opp: [SELECT id, accountId, Credit_Approved_For__c,
                                  (Select id from Quotes where status in ('E0013','E0014'))
                                  FROM Opportunity 
                                  WHERE Lock_Guarantor__c = FALSE 
                                  AND accountId IN :changedAccountList.keyset() 
                                  AND OppStatus__c NOT IN :bookedStatusSet])
            {
                if(opp.quotes.size() == 0)
                {
                    oppIdList.add(opp.id);
                }
            }
            
            if(!oppIdList.isEmpty())
            {
                UpdateOppGuarantorBatch batch = new UpdateOppGuarantorBatch(oppIdList);
                Database.executeBatch(batch,1);
            }
            
            List<Relationship__c> relationShipInsertList = new List<Relationship__c>();
            List<Relationship__c> relationShipDeleteList = new List<Relationship__c>();
            Boolean isOM01 = false, isOM31 = false;
            List<Account> accountFullList = [SELECT id,  
                                             (SELECT id, Secondary_Account__c, Primary_Account_Sales_Org__r.Sales_Org__c FROM Relationships__r WHERE Primary_Account_Sales_Org__r.Sales_Org__c in ('OM01','OM31') AND Relationship__c = 'ZU'),
                                             (SELECT id, Sales_Org__c FROM Sales_Orgs__r WHERE Sales_Org__c in ('OM01','OM31'))
                                             FROM Account 
                                             WHERE id IN :changedAccountList.keyset()];
            system.debug('accountFullList-->'+accountFullList);
            for(Account acc : accountFullList){
                if(!acc.Relationships__r.isEmpty())
                {
                    for(Relationship__c rs : acc.Relationships__r)
                    {
                            relationShipDeleteList.add(rs);
                    }
                }
                
                if(!acc.Sales_Orgs__r.isEmpty())
                {
                    for(SAP_Sales_Org__c sso : acc.Sales_Orgs__r)
                    {
                        if((newMap.get(acc.id).Credit_Approved_For__c <> NULL || (newMap.get(acc.id).Credit_Approved_For__c == NULL && newMap.get(acc.id).Own_Guarantor__c))
                           && (sso.Sales_Org__c == 'OM01' || sso.Sales_Org__c == 'OM31'))
                        {
                            Relationship__c rs = new Relationship__c();
                            rs.Primary_Account__c = acc.id;
                            rs.Primary_Account_Sales_Org__c = sso.id;
                            rs.Relationship__c = 'ZU';
                            
                            if(newMap.get(acc.id).Credit_Approved_For__c <> NULL)
                                rs.Secondary_Account__c = newMap.get(acc.id).Credit_Approved_For__c;
                            else if(newMap.get(acc.id).Credit_Approved_For__c == NULL && newMap.get(acc.id).Own_Guarantor__c)
                                rs.Secondary_Account__c = acc.id;
                            
                            relationShipInsertList.add(rs);
                        }
                    }
                }
            }
            
            if(!relationShipDeleteList.isEmpty()){
                GlobalStaticVariable.allowGuarantorRelationShipInsert = true;
                delete relationShipDeleteList;
                GlobalStaticVariable.allowGuarantorRelationShipInsert = false;
            }
            
            if(!relationShipInsertList.isEmpty()){
                GlobalStaticVariable.allowGuarantorRelationShipInsert = true;
                if (!Test.isRunningTest())
                insert relationShipInsertList;
                GlobalStaticVariable.allowGuarantorRelationShipInsert = false;
            }
        }
    }
    
}