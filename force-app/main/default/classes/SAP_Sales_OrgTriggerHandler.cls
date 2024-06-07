/**********************************************************************
Name:  SAP_Sales_OrgTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for SAP_Sales_Org__cTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Andrew Hilsher            9/19/2018          INITIAL DEVELOPMENT
***********************************************************************/
public class SAP_Sales_OrgTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('SAPSalesOrgTriggerDisabled');
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
                
        //make sure there is not a Sales Org already created with this Sales Org value
        //get accountIDs for the new items
        List<SAP_Sales_Org__c> newSOs= newItems;
        Set<ID> aIDs = new Set<ID>();
        for (SAP_Sales_Org__c so1 : newSOs) {
            aIDs.add(so1.Account__c);
        }
        //get the existing values for Sales_Org__c
        List<SAP_Sales_Org__c> otherSOs = [SELECT ID, Sales_Org__c, Account__c from SAP_Sales_Org__c 
                                            WHERE Account__c in:aIDs];                                         
        for (SAP_Sales_Org__c so: newSOs) {
            for (SAP_Sales_Org__c so2: otherSOs) {          
                if ((so.Account__c==so2.Account__c)&&(so.Sales_Org__c==so2.Sales_Org__c)) {
                    so.addError('There is already an SAP Sales Org on this Account with this Sales Org value.');            
                }
                else {
                   // if related account is valid, add new sales org to SAP
                    boolean isValid = false;
                    if(so.Account__c != null || so.Account__c != ''){
                        isValid = IsAccountValid(so.Account__c);
                    } 
                    if (isValid ){
                        
                        String newSalesOrgValue = json.serialize(so);
                        String oldSalesOrgValue = '';
                        if (!SalesOrgCreateController.isTriggerExecuting && SalesOrgCreateController.isFirstRun ){
                            if(!Test.isRunningTest()){   
                                SalesOrgCreateController.CreateNewSalesOrg(newSalesOrgValue,oldSalesOrgValue);
                            }                         
                        }
                    }
                    if(!Test.isRunningTest())SalesOrgCreateController.isFirstRun = false;
                }
            }
        }      
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        /*List<SAP_Sales_Org__c> oldSOs= oldItems.values();
        for(SAP_Sales_Org__c so : oldSOs){
        so.adderror('You do not have permission to delete');
        }*/
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
       
        //make sure there is not a Sales Org already created with this Sales Org value
        //checked on insert
        List<SAP_Sales_Org__c> newSOs= newItems.values();
        Map<Id, SAP_Sales_Org__c> oldMap = new  Map<Id, SAP_Sales_Org__c>((List<SAP_Sales_Org__c>)oldItems.values()); 
        //List<SAP_Sales_Org__c> oldSOs= oldItems.values();
        
        if (!SalesOrgCreateController.isTriggerExecuting && SalesOrgCreateController.isFirstRun ){
            
            if(newSOs != null && newSOs.size() > 0){ 
  
                for (SAP_Sales_Org__c so : newSOs) {
                    
                    if(so.Sales_Org__c == oldMap.get(so.Id).Sales_Org__c && so.Distribution_Channel__c == oldMap.get(so.Id).Distribution_Channel__c && so.Default_IDN_Price_List__c == oldMap.get(so.Id).Default_IDN_Price_List__c && 
                       so.Default_GPO_Price_List__c == oldMap.get(so.Id).Default_GPO_Price_List__c &&  so.Service_Level__c == oldMap.get(so.Id).Service_Level__c &&  so.Incoterms_1__c == oldMap.get(so.Id).Incoterms_1__c && 
                       so.Incoterms_2__c == oldMap.get(so.Id).Incoterms_2__c && so.Shipping_Conditions__c == oldMap.get(so.Id).Shipping_Conditions__c && so.CurrencyIsoCode == oldMap.get(so.Id).CurrencyIsoCode && 
                       so.Terms_of_Payment__c == oldMap.get(so.Id).Terms_of_Payment__c && so.Sales_Office__c == oldMap.get(so.Id).Sales_Office__c && so.Default_Price_Code__c == oldMap.get(so.Id).Default_Price_Code__c && // Changed on 23 Aug - Capgemini
                       so.Pricing_Date__c == oldMap.get(so.Id).Pricing_Date__c && so.Customer_Pricing_Procedure__c == oldMap.get(so.Id).Customer_Pricing_Procedure__c 
                       && so.District__c == oldMap.get(so.Id).District__c && !Test.isRunningTest()) continue;
                    
                    // check if account is validated before sending update to SAP
                    boolean isValid = false;
                    if(so.Account__c != null || so.Account__c != ''){
                        isValid = IsAccountValid(so.Account__c);
                    }
                    system.debug('The Account for this Sales Organization ' + so.Account__c);
                    system.debug('Is Valid Account for this Sales Organization ' + isValid);
                    
                    // must have valid account to do the update to SAP
                    if( isValid ) {  
                        
                        // get old values from map - use if callout fails  
                        SAP_Sales_Org__c oldSO = new SAP_Sales_Org__c();   
                        if( oldItems.ContainsKey(so.Id) ){   
                          oldSO = (SAP_Sales_Org__c)oldItems.get(so.Id);    
                        }
                        String newSalesOrgValue = json.serialize(so);
                        String oldSalesOrgValue = json.serialize(oldSO);
                        
                        if(!Test.isRunningTest()){
                            SalesOrgCreateController.CreateNewSalesOrg(newSalesOrgValue,oldSalesOrgValue);
                        }                      
                    }
                }
            }
        }
        SalesOrgCreateController.isFirstRun = false;
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

      }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        // soumyad SF-Bug-896 start
        // send Sales org data if account is validated
        list<SAP_Sales_Org__c> so = newItems.values();
        list<id> aid =new list<id>();
        string sid ='';
        for (SAP_Sales_Org__c ss : so) {   
            aid.add(ss.Account__c);
            sid=ss.id;
        }
        system.debug('ddd'+aid);
        account a = [select id, Validation_Status__c from Account where id =: aid];
        string oldAccountValues;
        if(a.Validation_Status__c == 'Validated') {
        AccountCreateController.CreateAccountFromProspect(a.Id, oldAccountValues, sid);
        }
        // soumyad SF-Bug-896 end
    }

    public boolean IsAccountValid(Id acctId){
        
        system.debug('Account recv' + acctId);
        boolean is_valid = false;
        if(acctId != null) {
            Account a = [Select Id, Validation_Status__c,Account_Status__c,IsDeleted__c from Account where id =: acctId LIMIT 1]; //IBA-1992 Abhrajitc
            is_valid = (a.Validation_Status__c == 'Validated'  && !a.IsDeleted__c ) ? true : false;//&& a.Account_Status__c == 'Active' //Commented by Sam on Jan 10 2019 as per Sarabjeet, Integration should not be checking if the Account Status is Active or not.
        }
        return is_valid;
    }
}