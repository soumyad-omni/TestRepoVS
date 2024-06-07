/**********************************************************************
 Name:      RelationshipTriggerHandler
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
public class RelationshipTriggerHandler implements ITriggerHandler { 
    
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){

        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('RelationshipTriggerDisabled');
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
        
        System.Debug('Relationship Before Insert');   
        List<account> accListnew = new List<account>(); // IBA-1276
        if (!RelationshipCreateController.isTriggerExecuting && RelationshipCreateController.isFirstRun){
            
            List<Relationship__c> newRelated= newItems;
            checkDefaultFlagValidation(newItems);//IBA-4266
            if(newRelated != null && newRelated.size() > 0){      
                for (Relationship__c r : newRelated) { 
                    if(!GlobalStaticVariable.allowGuarantorRelationShipInsert && r.Relationship__c == 'ZU' 
                       && profileName <> 'System Administrator' && profileName <> 'Business Administrator'){
                        r.addError('You do not have permission to insert Guarantor relationship manually');
                    }
                   // check for errors - returns non blank if no error
                   string errMessage = ValidateRelationship( r );
                    if(errMessage != '') {
                       r.addError(errMessage);  
                    }
                    else{
                        if(! Test.isRunningTest()){
                            String defaultFlag = '';//IBA-4266-Start
                            if(r.Default_Partner_Flag__c == true){
                                defaultFlag = 'X';
                            }							//IBA-4266-End
                            RelationshipCreateController.CreateNewRelationship(r.Primary_Account__c, r.Primary_Account_Sales_Org__c,
                                                                               r.Secondary_Account__c, r.Distribution_Channel__c,
                                                                               r.Relationship__c, r.SAP_Division__c, r.PARZA__c, defaultFlag);//IBA-4266
                        }
                    }
                    
                   /* make sure both accounts are validated, not archived and sales org selected
                   boolean is_pri_valid = IsAccountValid(r.Primary_Account__c);
                   boolean is_sec_valid = IsAccountValid(r.Secondary_Account__c);
                   boolean has_sales_org = (r.Primary_Account_Sales_Org__c != null) ? true : false;
  
                   if (is_pri_valid && is_sec_valid && has_sales_org ) {
                      RelationshipCreateController.CreateNewRelationship(r.Primary_Account__c, r.Primary_Account_Sales_Org__c, r.Secondary_Account__c, r.Distribution_Channel__c,r.Relationship__c, r.SAP_Division__c, r.PARZA__c);
                   }
                   else {
                       string messages = '';
                       
                       if (!is_pri_valid) {
                           messages += 'Primary Account has not been validated or is archived. ';
                       }

                       if (!is_sec_valid) {
                           messages += 'Secondary Account has not been validated or is archived. ';
                       }                       
              
                       if (!has_sales_org) {
                           messages +='Missing Sales Organization.';
                       }  
                       r.addError(messages);                       
                    }*/
                }
            }
        }
        RelationshipCreateController.isFirstRun = false;
        List<Relationship__c> newRelated= newItems;
        List<GPO_Account__c> secAcc = [select id, Account_Id__c  from GPO_Account__c];
        List<Id> accList = new List<Id>();
        for(Relationship__c r : newRelated){
            if(r.Relationship__c == 'ZG' && !secAcc.isEmpty() && r.secondary_account__c == secAcc[0].Account_Id__c){
                accList.add(r.Primary_Account__c);
            }
            //IBA-1276 Abhrajit
            if(r.Relationship__c == 'ZG' && !secAcc.isEmpty()){
                accListnew.add(updategpo(r.Primary_Account__c, r.secondary_account__c));
            }
            //IBA-1276 Abhrajit
        }
        checkGPORelation(accList); 
        update accListnew;//IBA-1276 Abhrajit
    }
    //IBA-1276 Abhrajit
    public static account updategpo(Id accIds1, Id accIds2){
        Account accList = [select id,GPO_AC__c from Account where id=:accIds1];
        accList.GPO_AC__c = accIds2;
        return accList;
    }
    //IBA-1276 Abhrajit
    public static void checkGPORelation(List<Id> accIds){
        List<Account> accList = [select id,GPOCheck__c from Account where id=:accIds];
        //List<Relationship__c> relgpo = [select id, Name from Relationship__c where primary_account__c =:accIds and relationship__c = 'ZG'];
        //if(relgpo.size()>0){
            for(Account a : accList){
                a.GPOCheck__c = true;
            }
        //}
        update accList;
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        // mark custom isDeleted so doesnot move to salesforce delete 
        //List<Relationship> accnts= oldItems.values();
        //for (Relationship r : accnts) {
        //    r.IsDeleted__c = true;
        //} 
        List<Relationship__c> rel = oldItems.values();
        List<account> accListnew = new List<account>(); //Abhrajit IBA-1276
        List<GPO_Account__c> secAcc = [select id, Account_Id__c  from GPO_Account__c]; 
        List<Id> accIds = new List<Id>();
        for(Relationship__c r : rel){
            if(!GlobalStaticVariable.allowGuarantorRelationShipInsert && r.Relationship__c == 'ZU' 
               && profileName <> 'System Administrator' && profileName <> 'Business Administrator'){
                   r.addError('You do not have permission to delete Guarantor relationship manually');
               }
            if(r.Relationship__c == 'ZG'){
                accIds.add(r.Primary_Account__c);
            }
            //Abhrajit IBA-1276
            if(r.Relationship__c == 'ZG' && !secAcc.isEmpty()){
                accListnew.add(deletegpo(r.Primary_Account__c, r.secondary_account__c));
            }
          }
        
        List<Account> acc = new List<Account>();
        List<Account> accList = [select id,GPOCheck__c from Account where id=:accIds];
       List<Relationship__c> relgpo = [select id from Relationship__c where primary_account__c =:accIds and relationship__c = 'ZG' and secondary_account__c=:secAcc[0].Account_Id__c];
        if(relgpo.size()==1){
            for(Account a : accList){
                a.GPOCheck__c = false;
            }
        }
        AccountTriggerHandler.TriggerDisabled = true; //IBA-3304
        update accList;
        update accListnew;//IBA-1276 Abhrajit
    }
    //IBA-1276 Abhrajit
    public static account deletegpo(Id accIds1, Id accIds2){
        Account accList = [select id,GPO_AC__c from Account where id=:accIds1];
        if(accList.GPO_AC__c == accIds2) //IBA-3660
        accList.GPO_AC__c = null;
        return accList;
    }
    //IBA-1276 Abhrajit

    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){

        System.Debug('Relationship Before Update');   
		List<account> accListnew = new List<account>();//Abhrajit IBA-1276
        List<GPO_Account__c> secAcc = [select id, Account_Id__c  from GPO_Account__c];
        if (!RelationshipCreateController.isTriggerExecuting && RelationshipCreateController.isFirstRun){
            
            List<Relationship__c> newRelated= newItems.values();
            List<Relationship__c> oldRelated= oldItems.values();
            checkDefaultFlagValidation(newRelated);//IBA-4266
            if(newRelated != null && newRelated.size() > 0){      
                for (Relationship__c r : newRelated) { 
                for (Relationship__c r1 : oldRelated) {   
                   // check for errors - returns non blank if no error
                    if(r.id ==r1.id){
                    string errMessage = ValidateRelationship( r );
                    if(errMessage != '') {
                        r.addError(errMessage); 
                    }
                    else{                      
                        if(! Test.isRunningTest()){
                                    RelationshipCreateController.UpdateAccountRelationshipmain(r.Id,r.Primary_Account__c, 
                                                  r.Primary_Account_Sales_Org__c, r.Secondary_Account__c,r1.SAP_Division__c,r1.Relationship__c, 
                                                  r1.PARZA__c, r1.Primary_Account__c, r1.Primary_Account_Sales_Org__c, r1.Secondary_Account__c,
                                                  r.SAP_Division__c,r.PARZA__c, r.Relationship__c,r1,r);//IBA-4266
                        }
                    }
             ////Abhrajit IBA-1276
            if(r.Relationship__c == 'ZG' && !secAcc.isEmpty()){
                accListnew.add(gpoupdate(r.Primary_Account__c, r.secondary_account__c));
            }
            ////Abhrajit IBA-1276

                    }
                }
                }
                update accListnew;
            }
        }
        RelationshipCreateController.isFirstRun = false;
    }
    //Abhrajit IBA-1276
    public static account gpoupdate(Id accIds1, Id accIds2){
        Account accList = [select id,GPO_AC__c from Account where id=:accIds1];
        accList.GPO_AC__c = accIds2;
        return accList;
    }
    //Abhrajit IBA-1276
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        for (Relationship__c r : (List<Relationship__c>)oldItems.values()) {
            if(! Test.isRunningTest()){
                String defaultFlag = '';//IBA-4266-Start
                if(r.Default_Partner_Flag__c == true){
                    defaultFlag = 'X';
                }							//IBA-4266-End
                RelationshipCreateController.deleteAccountRelationship(r.SAP_Division__c,r.Relationship__c, r.PARZA__c, r.Primary_Account__c, 
                                                                       r.Primary_Account_Sales_Org__c, r.Secondary_Account__c,defaultFlag);//IBA-4266
            }                
        }
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
       List<Relationship__c> newRelated= newItems.values();
        If(!Test.isRunningTest()){
            RelationIntegrationWithC4C.sendRelationshipDataToC4C(newRelated);
        }
    } 
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<GPO_Account__c> secAcc = [select id, Account_Id__c  from GPO_Account__c];
        List<Relationship__c> newRelated= newItems.values();
        If(!Test.isRunningTest()){
            RelationIntegrationWithC4C.sendRelationshipDataToC4C(newRelated);
        }
        List<Id> accList = new List<Id>();
        for(Relationship__c r : newRelated){
            if(r.Relationship__c == 'ZG' && r.secondary_account__c == secAcc[0].Account_Id__c){
                accList.add(r.Primary_Account__c);
            }
        }
        checkGPORelation(accList);
        
        
    }
    
    public string ValidateRelationship(Relationship__c r){
        
        string messages = '';
        
        // make sure both accounts are validated, not archived and sales org selected
        boolean is_pri_valid = IsAccountValid(r.Primary_Account__c);
        boolean is_sec_valid = IsAccountValid(r.Secondary_Account__c);
        boolean has_sales_org = (r.Primary_Account_Sales_Org__c != null) ? true : false;
        boolean has_existing_GPO= CheckExistingGPO(r.Primary_Account__c);//IBA-3660
        if (!is_pri_valid) {
            messages += 'Primary Account has not been validated or is archived. ';
        }
        
        if (!is_sec_valid) {
            messages += 'Secondary Account has not been validated or is archived. ';
        }                       
        
        if (!has_sales_org) {
            messages += 'Missing Sales Organization.';
        }
        if(has_existing_GPO == true && r.Relationship__c == 'ZG' ){ //IBA-3360
            messages += 'There can only be one GPO relationship per account. Please delete the existing GPO relattionship before creating a new one';
        }//IBA-3660

        return messages;
    }
    
    // get record types
    public Map<string,id> getRecordTypes(){
        Map<string,id> recordTypeMap = new Map<string,id>();
        List<RecordType> recordTypeList = new List<RecordType>();
        recordTypeList = [SELECT Id, DeveloperName FROM RecordType];
        for (RecordType rec : recordTypeList){
            if (rec.DeveloperName == 'US_Customer' || rec.DeveloperName == 'International_Customer'){
               recordTypeMap.put(rec.DeveloperName,rec.Id); 
            } 
        }
        return recordTypeMap;
    }
    
    public boolean IsAccountValid(Id acctId){
        
        system.debug('Account recv' + acctId);
        boolean is_valid = false;
        if(acctId != null) {
            Account a = [Select Id, Validation_Status__c,Account_Status__c,IsDeleted__c from Account where id =: acctId LIMIT 1]; //IBA-1992 Abhrajitc
            //is_valid = (a.Validation_Status__c == 'Validated' && a.Account_Status__c == 'Active' && !a.IsDeleted__c ) ? true : false;
            //SF-BUG-651 ignore account status
            is_valid = (a.Validation_Status__c == 'Validated' && !a.IsDeleted__c ) ? true : false;
        }
        return is_valid;
    }
    //IBA-3360 Starts
    public boolean CheckExistingGPO(Id acctId)  {
        boolean CheckGPORel = false;
        if(acctId != null){
            List<Relationship__c> rg = [select id, Name, Relationship__c from Relationship__c where primary_account__c =:acctId and Relationship__c = 'ZG'];
            if(rg.size() > 0){
                CheckGPORel = true;
                system.debug('Check GPO Flag: ' + CheckGPORel);
            }
        }
        return CheckGPORel;
    }
    //IBA-3360 Ends
    
    public static void checkDefaultFlagValidation(List<Relationship__c> relList){ //IBA-4266
        Set<String> accIds = new Set<String>();
        for(Relationship__c r:relList){
            accIds.add(r.Primary_Account__c);
        }
        Map<String,Decimal> allRelCountMap = new Map<String,Decimal>();
        List<Relationship__c> allRel = [Select Id,Primary_Account__c,Relationship__c,Default_Partner_Flag__c From Relationship__c 
                                        Where Primary_Account__c IN :accIds AND Default_Partner_Flag__c = True];
        for(Relationship__c r:allRel){
            Decimal count = 1;
            String key = r.Primary_Account__c + r.Relationship__c;
            if(allRelCountMap.get(key) != null){
                count = allRelCountMap.get(key);
                allRelCountMap.put(key,count+1);
            }
            else{
                allRelCountMap.put(key,count);
            }
        }
        for(Relationship__c r:relList){
            if(r.Default_Partner_Flag__c == True){
                if(allRelCountMap.get(r.Primary_Account__c + r.Relationship__c) != null){
                    r.addError('The Default Partner Flag of another '+r.Relationship__c+' Relationship of this Primary Account'+
                               ' is already set to True.');
                }
            }
        }
    }
}