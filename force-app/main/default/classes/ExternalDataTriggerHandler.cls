/**********************************************************************
Name:  ExternalDataTriggerHandler
======================================================
======================================================                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain            1/03/2022       INITIAL DEVELOPMENT
***********************************************************************/
public class ExternalDataTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('ExternalDataTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
        
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems) {        
        List<External_Data__c> newExternalData = newItems;
        updateRefEdgeValues(newExternalData); //IBA-2181        
        //IBA-4057
        for(External_data__C n:newExternalData){
            n.isTiSegmentChanged__c = true;
        }
    }
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<External_Data__c> newValues = newItems.values();
        List<External_Data__c> oldValues = oldItems.values();
        Set<String> accId = new Set<String>();
        Set<String> oppId = new Set<String>(); //IBA-2706
        Set<Integer> defID = new Set<Integer>(); //IBA-2181
        Map<Id, Account> accUpdate = new Map<Id, Account>();
        List<Opportunity> oppUpdate = new List<Opportunity>(); //IBA-2706
        //list<Account_History__c> accHistoryL = new list<Account_History__c>();
        for(integer i=0;i<newValues.size();i=i+1){
            if(newValues[i].Account_Segment__c != oldValues[i].Account_Segment__c || newValues[i].Account_Market_Segment__c != oldValues[i].Account_Market_Segment__c){//IBA-4621
                newValues[i].isTiSegmentChanged__c = true;
            }//IBA-4057
            
            if(newValues[i].Definitive_ID__c != oldValues[i].Definitive_ID__c){
                if(newValues[i].Definitive_ID__c != null){
                    defID.add(Integer.valueOf(newValues[i].Definitive_ID__c));
                }                
            }
            if(newValues[i].Opportunity_ID__c != oldValues[i].Opportunity_ID__c){
                if(newValues[i].Opportunity_ID__c != null){
                    oppId.add(newValues[i].Opportunity_ID__c);
                }
            }
                        
            if(newValues[i].AccountID__c != oldValues[i].AccountID__c){
                if(newValues[i].AccountID__c != null){
                    accId.add(newValues[i].AccountID__c);
                }
            }
            
            //IBA-3292
            /*if(newValues[i].Alteryx_TLP_Recency__c != oldValues[i].Alteryx_TLP_Recency__c){
                Account_History__c accHistory = new Account_History__c();
                accHistory.Account__c = newValues[i].AccountID__c;
                accHistory.Field__c = 'Top Level Parent Recency';
                
                accHistory.User__c = UserInfo.getUserId();
                        
                
                if (oldValues[i].Alteryx_TLP_Recency__c != null) accHistory.ORIGINAL_VALUE__c = oldValues[i].Alteryx_TLP_Recency__c;
                if (newValues[i].Alteryx_TLP_Recency__c != null) accHistory.NEW_VALUE__c = newValues[i].Alteryx_TLP_Recency__c;    
                accHistoryL.add(accHistory);
            }
            if(newValues[i].Alteryx_TLP_Frequency__c != oldValues[i].Alteryx_TLP_Frequency__c){
                Account_History__c accHistory = new Account_History__c();
                accHistory.Account__c = newValues[i].AccountID__c;
                accHistory.Field__c = 'Top Level Parent Frequency';
                
                accHistory.User__c = UserInfo.getUserId();
                        
                
                if (oldValues[i].Alteryx_TLP_Frequency__c != null) accHistory.ORIGINAL_VALUE__c = oldValues[i].Alteryx_TLP_Frequency__c;
                if (newValues[i].Alteryx_TLP_Frequency__c != null) accHistory.NEW_VALUE__c = newValues[i].Alteryx_TLP_Frequency__c;    
                accHistoryL.add(accHistory);
            }
            if(newValues[i].Alteryx_TLP_Monetary__c != oldValues[i].Alteryx_TLP_Monetary__c){
                Account_History__c accHistory = new Account_History__c();
                accHistory.Account__c = newValues[i].AccountID__c;
                accHistory.Field__c = 'Top Level Parent Monetary';
                
                accHistory.User__c = UserInfo.getUserId();
                        
                
                if (oldValues[i].Alteryx_TLP_Monetary__c != null) accHistory.ORIGINAL_VALUE__c = oldValues[i].Alteryx_TLP_Monetary__c;
                if (newValues[i].Alteryx_TLP_Monetary__c != null) accHistory.NEW_VALUE__c = newValues[i].Alteryx_TLP_Monetary__c;    
                accHistoryL.add(accHistory);
            }
            if(newValues[i].Alteryx_TLP_RFM_Score__c != oldValues[i].Alteryx_TLP_RFM_Score__c){
                Account_History__c accHistory = new Account_History__c();
                accHistory.Account__c = newValues[i].AccountID__c;
                accHistory.Field__c = 'Top Level RFM Score';
                
                accHistory.User__c = UserInfo.getUserId();
                        
                
                if (oldValues[i].Alteryx_TLP_RFM_Score__c != null) accHistory.ORIGINAL_VALUE__c = oldValues[i].Alteryx_TLP_RFM_Score__c;
                if (newValues[i].Alteryx_TLP_RFM_Score__c != null) accHistory.NEW_VALUE__c = newValues[i].Alteryx_TLP_RFM_Score__c;    
                accHistoryL.add(accHistory);
            }
            if(newValues[i].Alteryx_TLP_RFM_Segment__c != oldValues[i].Alteryx_TLP_RFM_Segment__c){
                Account_History__c accHistory = new Account_History__c();
                accHistory.Account__c = newValues[i].AccountID__c;
                accHistory.Field__c = 'Top Level RFM Segment';
                
                accHistory.User__c = UserInfo.getUserId();
                        
                
                if (oldValues[i].Alteryx_TLP_RFM_Segment__c != null) accHistory.ORIGINAL_VALUE__c = oldValues[i].Alteryx_TLP_RFM_Segment__c;
                if (newValues[i].Alteryx_TLP_RFM_Segment__c != null) accHistory.NEW_VALUE__c = newValues[i].Alteryx_TLP_RFM_Segment__c;    
                accHistoryL.add(accHistory);
            }*/
        }
        /*if(accHistoryL.size()>0){
            insert accHistoryL;
        }*/
        
        Map<Id, Account> acc;
        if(accId.size()>0 && accId!=null){
            acc = new Map<Id, Account>([Select id, External_Data__c from account where id IN: accId]);
        }
        
        Map<Id, Opportunity> opp;
        if(oppId.size()>0 && oppId!=null){
            opp = new Map<Id, Opportunity>([Select id, External_Data__c from Opportunity where id IN: oppId]);
        }
        
        Map<Integer, List<Account>> DHC_acc = new Map<Integer, List<Account>>();
        if(defID.size()>0 && defID!=null){
            //DHC_acc = new Map<Id, Account>([Select id, External_Data__c, texcellency__DefHC_HospitalID__c from account where texcellency__DefHC_HospitalID__c IN: defID]); 
            List<Account> ListAcc = [Select id, External_Data__c, texcellency__DefHC_HospitalID__c from account where texcellency__DefHC_HospitalID__c IN: defID];
            //Map<Integer, Account> DHC_acc = new Map<Integer, Account>();
            for(Account ac : ListAcc){
                List<Account> Lacc = DHC_acc.get(Integer.valueOf(ac.texcellency__DefHC_HospitalID__c));
                if(Lacc != null){
                    List<Account> Lacc2 = new List<Account>();
                    Lacc2.addAll(Lacc);
                    Lacc2.add(ac);
                    DHC_acc.put(Integer.valueOf(ac.texcellency__DefHC_HospitalID__c), Lacc2);
                }else{
                    List<Account> Lacc2 = new List<Account>();
                    Lacc2.add(ac);
                    DHC_acc.put(Integer.valueOf(ac.texcellency__DefHC_HospitalID__c), Lacc2);
                }
            }           
        }
        for(External_Data__c ex : newValues){
            Account a; 
            if(ex.AccountID__c != null && acc != null){
                a = acc.get(ex.AccountID__c);
                a.External_Data__c = ex.Id;
                //System.debug('ex.Id: ' + ex.Id);
                //System.debug('a.External_Data__c: ' + a.External_Data__c);
                accUpdate.put(a.Id,a);
            }
            
            //IBA-2706
            Opportunity op;
            if(ex.Opportunity_ID__c != null && opp != null){
                op = opp.get(ex.Opportunity_ID__c);
                op.External_Data__c = ex.Id;
                //System.debug('ex.Id: ' + ex.Id);
                //System.debug('op.External_Data__c: ' + op.External_Data__c);
                oppUpdate.add(op);
            }
            //IBA-2706 
            
            //IBA-2181
            //system.debug('Calling DHC_acc');
            List<Account> DHC_a = DHC_acc.get(Integer.valueOf(ex.Definitive_ID__c));
            if(DHC_a != null){
                for(Account la: DHC_a){
                    if(la != null){
                        la.DHC_External_Data__c = ex.Id;
                        //System.debug('ex.Id: ' + ex.Id);
                        //System.debug('la.DHC_External_Data__c: ' + la.DHC_External_Data__c + ' ex.Id: ' + ex.Id);
                        accUpdate.put(la.Id,la);
                    }
                }
            }
            
            //IBA-2181
        }
        
        
        
        Try{
            if(accUpdate.size()>0){
                AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
                AccountTriggerHandler.TriggerDisabled = true;
                update accUpdate.values();
            }
            if(oppUpdate.size()>0){
                OpportunityTriggerHandler.TriggerDisabled = true;
                update oppUpdate;
            }    
        }catch(Exception e){
            system.debug('##The following exception has occurred: '+ e.getMessage());
        }
        
        updateRefEdgeValues(newValues); //IBA-2181
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        List<External_data__c> ExNewData = newItems.values();
        Set<String> accId = new Set<String>();
        Set<Integer> defID = new Set<Integer>(); //IBA-2181
        Set<String> oppId = new Set<String>(); //IBA-2706
        Map<Id, Account> accUpdate = new Map<Id, Account>();
        List<Opportunity> oppUpdate = new List<Opportunity>(); //IBA-2706
        
        for(External_Data__c ex : ExNewData){
            //System.debug('ex.AccountID__c: ' + ex.AccountID__c);
            //System.debug('ex.Opportunity_ID__c: ' + ex.Opportunity_ID__c);
            if(ex.AccountID__c != null){
                accId.add(ex.AccountID__c);
            }
            
            //IBA-2706 - starts
            if(ex.Opportunity_ID__c != null){
                oppId.add(ex.Opportunity_ID__c);
            }
            //IBA-2706 - ends
            
            //IBA-2181 starts
            if(ex.Definitive_ID__c != null){
                defID.add(Integer.valueOf(ex.Definitive_ID__c));
            }
            //IBA-2181 ends
        }
        Map<Id, Account> acc = new Map<Id, Account>([Select id, External_Data__c from account where id IN: accId]);     
        
        Map<Id, Opportunity> opp = new Map<Id, Opportunity>([Select id, External_Data__c from Opportunity where id IN: oppId]); //IBA-2706       
        
        //Map<Id, Account> DHC_acc = new Map<Id, Account>([Select id, External_Data__c, texcellency__DefHC_HospitalID__c from account where texcellency__DefHC_HospitalID__c IN: defID]); // IBA-2181
        //System.debug('DHC_acc: '+ DHC_acc.size());
        Map<Integer, List<Account>> DHC_acc = new Map<Integer, List<Account>>();
        List<Account> ListAcc = [Select id, External_Data__c, texcellency__DefHC_HospitalID__c from account where texcellency__DefHC_HospitalID__c IN: defID];        
        for(Account ac : ListAcc){
            List<Account> Lacc = DHC_acc.get(Integer.valueOf(ac.texcellency__DefHC_HospitalID__c));
            if(Lacc != null){
                List<Account> Lacc2 = new List<Account>();
                Lacc2.addAll(Lacc);
                Lacc2.add(ac);
                DHC_acc.put(Integer.valueOf(ac.texcellency__DefHC_HospitalID__c), Lacc2);
            }else{
                List<Account> Lacc2 = new List<Account>();
                Lacc2.add(ac);
                DHC_acc.put(Integer.valueOf(ac.texcellency__DefHC_HospitalID__c), Lacc2);
            }
        }
        
        for(External_Data__c ex : ExNewData){
            Account a = acc.get(ex.AccountID__c);
            if(a != null){
                a.External_Data__c = ex.Id;
                //System.debug('ex.Id: ' + ex.Id);
                //System.debug('a.External_Data__c: ' + a.External_Data__c);
                accUpdate.put(a.Id,a);
            }
            
            //IBA-2706   
            Opportunity op = opp.get(ex.Opportunity_ID__c);
            if(op != null){
                op.External_Data__c = ex.Id;
                //System.debug('ex.Id: ' + ex.Id);
                //System.debug('op.External_Data__c: ' + op.External_Data__c);
                oppUpdate.add(op);
            }
            //IBA-2706 
            
            
            //IBA-2181
            //for(Account la: DHC_acc.values()){
            List<Account> DHC_a = DHC_acc.get(Integer.valueOf(ex.Definitive_ID__c));
            if(DHC_a != null){
                for(Account la: DHC_a){
                    if(la != null){
                        la.DHC_External_Data__c = ex.Id;
                        //System.debug('ex.Id: ' + ex.Id);
                        //System.debug('la.DHC_External_Data__c: ' + la.DHC_External_Data__c + ' ex.Id: ' + ex.Id);
                        accUpdate.put(la.Id,la);
                    }
                } 
            }
            
            //}
            //IBA-2181
        }
        System.debug('accUpdate: ' + accUpdate.size());
        
        
        
        
        Try{
            if(accUpdate.size()>0){
                AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
                AccountTriggerHandler.TriggerDisabled = true;
                update accUpdate.values();
            }
            if(oppUpdate.size()>0){
                OpportunityTriggerHandler.TriggerDisabled = true;
                update oppUpdate;
            }    
        }catch(Exception e){
            system.debug('##The following exception has occurred: '+ e.getMessage());
        }
    }
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        Set<Decimal> defId = new Set<Decimal>();//IBA-3101 Start
        Set<Id> extId = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<External_Data__c> newExtData= newItems.values(); 
        List<External_Data__c> oldExtData= oldItems.values(); 
        Set<Decimal> definitiveId = new Set<Decimal>(); // IBA-3414
        for(Integer i=0;i<newExtData.size();i++){
            if(oldExtData[i].DHC_of_licensed_beds__c != newExtData[i].DHC_of_licensed_beds__c){
                //defId.add(newExtData[0].Definitive_ID__c);
               extId.add(newExtData[0].Id);
            }    
            if(oldExtData[i].DHC_340B_Eligible__c != newExtData[i].DHC_340B_Eligible__c){
                definitiveId.add(newExtData[i].Definitive_ID__c);
            }
        }
        List<Account> acctListToUpdateOCIBeds = [Select Id,Licensed_Beds_for_OC1_Quoting__c,OC1FieldManualUpdate__c,DHC_of_Licensed_Beds_formula__c,texcellency__DefHC_NumBeds__c
                                                 From Account Where DHC_External_Data__c IN : extId];// Added OC1FieldManualUpdate__c for IBA-3335
        system.debug('******acctListToUpdateOCIBeds.size()>0');
        if(acctListToUpdateOCIBeds.size()>0){
            system.debug('******OC1FieldManualUpdate__c == false');
                AccountTriggerHandler.updateLicensedBedsForOC1Quoting(acctListToUpdateOCIBeds);
                /*AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
                AccountTriggerHandler.TriggerDisabled = true;*/
                AccountTriggerHandler.updateFromExternalTrigger = true;
                update acctListToUpdateOCIBeds;
        }
        for(Account ac :acctListToUpdateOCIBeds){
            accIds.add(ac.Id);
        }
        /*List<Quote> quoteListToUpdateOCIBeds = [Select Id,of_beds__c,Account.Licensed_Beds_for_OC1_Quoting__c From Quote Where AccountId IN:accIds AND (Status = 'E0001' OR Status = null)];
        for(Quote qt:quoteListToUpdateOCIBeds){
            qt.of_beds__c = qt.Account.Licensed_Beds_for_OC1_Quoting__c;
        }
        if(quoteListToUpdateOCIBeds.size()>0){
                QuoteTriggerHandler.TriggerDisabled = true;
                update quoteListToUpdateOCIBeds;
        }   */                                      //IBA-3101 End
        
        Map<Id, Account> acctListToUpdate340BEligible = new Map<Id, Account>([Select Id, DHC_340B_Eligible__c ,X340B_Eligible__c 
                                                      From Account Where texcellency__DefHC_HospitalID__c IN:definitiveId]); // IBA-3414
        
        Try{ //IBA-3414 starts
            if(acctListToUpdate340BEligible.size()>0){  
                    update340Beligible(acctListToUpdate340BEligible);
                    AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
                    AccountTriggerHandler.TriggerDisabled = true;
                    update acctListToUpdate340BEligible.values();
            } 
        }catch(Exception e){
            system.debug('##The following exception has occurred: '+ e.getMessage());
        } //IBA-3414 ends
    }
    
    
    //IBA-2181
    private static void updateRefEdgeValues(List<External_Data__c> exList) {
        Set<String> setPicklistValues = new Set<String>();
        for(Reference_Edge_Map__mdt edgeMap : Reference_Edge_Map__mdt.getAll().values()) setPicklistValues.add(edgeMap.DHCEmar__c.toUpperCase());
            
        //List<Reference_Edge_Map__mdt> setPickValue = Reference_Edge_Map__mdt.getAll().values();
        for (External_Data__c objEx : exList){
            if (objEx.DHC_eMAR__c != null && setPicklistValues.contains(objEx.DHC_eMAR__c.toUpperCase())){
                objEx.DHC_eMar_Ref__c = objEx.DHC_eMAR__c;
            }
            //IBA-2181 starts
            if (objEx.DHC_340B_ID__c != null && objEx.DHC_340B_ID__c != ''){
                objEx.DHC_340B_Eligible__c = 'Yes';
            }else{
                objEx.DHC_340B_Eligible__c = 'No';
            }
            //IBA-2181 ends            
        }
    }
    
    // IBA-3414 starts
    Public void update340Beligible(Map<Id, Account> ListAcc){
        for(Account acc : ListAcc.values()){
            if(acc.X340B_Eligible__c != acc.DHC_340B_Eligible__c && acc.DHC_340B_Eligible__c != ''){
                acc.X340B_Eligible__c = acc.DHC_340B_Eligible__c;
            }
        }
    }    
    // IBA-3414 ends
}