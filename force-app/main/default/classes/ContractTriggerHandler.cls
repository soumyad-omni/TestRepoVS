/**********************************************************************
Name:  ContractTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for ContractTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Haripriya Maturi         7/26/2018        INITIAL DEVELOPMENT
***********************************************************************/
public class ContractTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('ContractTriggerDisabled');
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
        List<Contracts__c> cList = newItems;
        for(Contracts__c c : cList){
            c.Conga_Agreement_Number__c = 1;
        }
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
       List<Contracts__c> contractList = newItems.values();
        ContractApprovalProcessFields_Class obj = new ContractApprovalProcessFields_Class();
        obj.updateContractsFields(contractList);
        updateTimestamp(contractList);
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
               
            updateCmaCpa(newItems.keySet());
    } 
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        updateCmaCpa(newItems.keySet());
    }
    public void updateCmaCpa(Set<Id> con){
        List<Contracts__c> exp = [select expiration_date__c,Account__c from contracts__c where id =:con ];
        List<Id> accntids = new List<Id>();
        for(Contracts__c contracts:exp){
            accntids.add(contracts.account__c);
        }
        Id accId = exp[0].account__c;
        List<Contracts__c> contr = [select type__c,conga_agreement_number__c,CreatedDate,Start_Date__c,Type_of_Master_Agreement__c,expiration_date__c,Account__c from contracts__c where account__c =:accId order by expiration_date__c asc];
        Map<Id,Date> accids = new Map<Id,Date>();
        
        Boolean redlinecheck = false;

        
        for(Contracts__c c : contr){
            System.debug('Contr : '+contr);
            if(c.Expiration_Date__c != null && (c.Type__c == 'Redline CMA' || c.Type__c == 'Redline CPA' || c.Type__c == 'Redline Master')){
                accids.put(c.account__c,c.Expiration_Date__c);
                redlinecheck = true;
            }
            if(redlinecheck != true){   
            System.debug('Acc : '+accids);
                if((c.Type_of_Master_Agreement__c != null && c.Expiration_Date__c == null) || (c.Type__c == 'Boilerplate Master' || c.Type__c == 'Boilerplate CMA without schedules' || c.Type__c == 'Boilerplate CPA without schedules' || c.Type__c == 'Boilerplate CMA with schedules' || c.Type__c == 'Boilerplate CMA with schedules' 
               // added by Sarabjeet Singh
                || c.Type__c == 'Boilerplate CPA binding without schedule' || c.Type__c == 'Boilerplate CPA binding with schedule' 
                || c.Type__c == 'Boilerplate CPA non-binding without schedule' || c.Type__c == 'Boilerplate CPA non-binding with schedule' 
                || c.Type__c == 'Boilerplate CMA end user NAC only without schedule' || c.Type__c == '  Boilerplate CMA end user NAC only with schedule' || c.Type__c == 'Boilerplate Master Agreement - End User NAC only' || c.Type__c == 'Boilerplate Master Agreement - Non-Software NAC only' 
                || c.Type__c == 'Boilerplate CMA - NAA without schedule' || c.Type__c == 'Boilerplate CMA - NAA with schedule' 
                || c.Type__c == 'Boilerplate Master Agreement') ){
                // end of addition
               // Datetime dt = (Datetime) c.CreatedDate;
                //date myDate = DATEVALUE(c.CreatedDate);
                 //= c.Expiration_Date__c.addYears(9999);
                     DateTime dT = System.now()+99999;
                //dT.addYears(9999);
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    accids.put(c.account__c,myDate);
                }
            }
        }
           
        System.debug('Accounts : '+accids);
        if(accids.size()>0){
        Set<Id> accountIds = accids.keyset();
        List<Account> acc = [select id,CMA_CPA_Expiration_Date__c from Account where id=:accountIds];
        for(Account a:acc){
            a.CMA_CPA_Expiration_Date__c = accids.get(a.id);
        }
            try{
                accountInvoc.fromotherupdate= true;
        update acc;
            }catch(Exception e){
                
            }
        }
        //AggregateResult[] cont = [select Max(expiration_date__c) exp,Account__c from contracts__c where id=:con group by account__c];
        
    }
    
    
    
    public void updateTimestamp(List<Contracts__c> ctsList){
        for(Contracts__c cts:ctsList){
            Boolean bd=false;
            if(cts.status__c=='Approved' || cts.Status__c=='Pending'){
                if(cts.Status__c=='Pending'){
                    cts.Booking_Started__c=datetime.now();
                }
                for(ProcessInstanceStep PIS:[SELECT Actorid,Actor.userRole.Name,createdDate, OriginalActor.Name, OriginalActor.Title, StepStatus, comments,ProcessInstance.CreatedDate,
                                         ProcessInstance.CompletedDate,ProcessInstance.lastActorId
                                             FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:cts.id and stepStatus='Approved' order by createdDate desc]){
                    if(PIS.OriginalActor.name=='Booking Team Queue' && bd==false)  
                    {
                        cts.Booking_Completed__c=pis.CreatedDate;
                        cts.Booking_Signed_Off_By__c=Pis.ActorId;
                        cts.Booking_Sign_Off_Comment__c=pis.Comments;
                        bd=true;
                    }                             
                }
            }
        }
    }
}