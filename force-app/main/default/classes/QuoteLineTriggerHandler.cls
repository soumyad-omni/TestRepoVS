/**********************************************************************
Name:  QuoteLineTriggerHandler 
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for QuoteLineTrigger Events                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          ?                          ?          INITIAL DEVELOPMENT
0.2			Pabitra Tripathy		10/06/2023		Refactoring for UNABLE_TO_LOCK_ROW issue
***********************************************************************/

public class QuoteLineTriggerHandler implements ITriggerHandler{
    
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static Boolean isFirstTime = true;
    public static Boolean isFirst = true;
    public static Boolean isInsert = false;
    public static Boolean isDelete = false;
    public static Boolean calculatecheckinsert = false;
    public static Boolean quant8update = false;
    public static boolean quotelinecheck = false;
    public static boolean fromprint = false;
    public static boolean fromquoteprint = false;
    public static boolean afterUpdateScope = false;
    public static Map<Id, Quote> quoteMap = new Map<Id, Quote>();
    public static boolean updatefromAddProduct = false;  //IBA-1845
    public static Boolean reSendToSap; //IBA-4955 Pabitra
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('QuoteLineTriggerDisabled');
        if(tc != null){ 
            isDisabled= tc.isDisabled__c;
        }
        if(isDisabled == true){
            return true;
        }else{
            return TriggerDisabled;
        }
    }

    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems) {
        isInsert = true;
        List<Quote_Line__c> qlines = newItems;
        if(isFirstTime){
            UpdateQLTPicklist(qlines);
            calculateLineExpectedBookingValue(qlines);//IBA-1813
        }
        
        assignSAPLineNumbersAndKeys(newItems);
        
        //IBA-3929- Sourav - Start
        Set<Id> prodId = new Set<Id>();
        for(Quote_Line__c iql: qlines){
            prodId.add(iql.Product__c);
        }
        Map<String,Product2> allProdMap = new Map<String,Product2>([Select Id,DW_Product_Family__c From Product2 Where Id IN :prodId]);
        for(Quote_Line__c iql: qlines){
            Product2 currProd = allProdMap.get(iql.Product__c);
            if(currProd.DW_Product_Family__c == 'Solution' && iql.Number_of_Units__c != iql.Quantity__c){
                iql.Number_of_Units__c = iql.Quantity__c;
            }
        }
        //IBA-3929- Sourav - End
    }   
    
/**
* Assign SAP Lines Numbers to each Quote Line. 
* Quote lines created in the Configuration tool and synced to Salesforce from SAP will already have SAP Line Numbers  
* IBA 1253 - New logic based on Add to cart - Bharath Mulpuri 02/04/2021
*/
    public void assignSAPLineNumbersAndKeys(List <Quote_Line__c> quoteLines) {
        Decimal sapLineNumber, highestParent, highestSibling = 0;
        set<id> quoteLineIds = new set<id>();
        set<id> sapBlankquoteIds = new set<id>();
        map<string,map<decimal,decimal>> sapMaxLineNumMap = new map<string,map<decimal,decimal>>(); 
        
        for (Quote_Line__c qline : quoteLines) {
            if (qline.SAP_Line_Number__c == null || qline.SAP_Line_Number__c == 0){ 
                quoteLineIds.add(qline.Id);
                sapBlankquoteIds.add(qline.Quote__c);
            }
        }
        
        for(Quote_Line__c qline : [SELECT SAP_Line_Number__c, Higher_Level_Item__c,Quote__c from Quote_Line__c where Quote__c =:sapBlankquoteIds]) {
            if(!sapMaxLineNumMap.containskey(qline.Quote__c)){
                sapMaxLineNumMap.put(qline.Quote__c, new map<decimal,decimal>{0=>0});
            }
            if(qline.Higher_Level_Item__c == null || qline.Higher_Level_Item__c == 0){
                if(!sapMaxLineNumMap.get(qline.Quote__c).containskey(0) || sapMaxLineNumMap.get(qline.Quote__c).get(0)<qline.SAP_Line_Number__c){
                    sapMaxLineNumMap.get(qline.Quote__c).put(0,qline.SAP_Line_Number__c);
                }
            }else{
                if(!sapMaxLineNumMap.get(qline.Quote__c).containskey(qline.Higher_Level_Item__c) || sapMaxLineNumMap.get(qline.Quote__c).get(qline.Higher_Level_Item__c)<qline.SAP_Line_Number__c){
                    sapMaxLineNumMap.get(qline.Quote__c).put(qline.Higher_Level_Item__c,qline.SAP_Line_Number__c);
                }
            }
        }
        
        for (Quote_Line__c qline : quoteLines) {
            if (qline.SAP_Line_Number__c != null && qline.SAP_Line_Number__c != 0) {
                continue; 
            }
            if(!sapMaxLineNumMap.containskey(qline.Quote__c)){
                sapMaxLineNumMap.put(qline.Quote__c, new Map<decimal,decimal>{0=>0});
            }
            if(qline.Higher_Level_Item__c == null || qline.Higher_Level_Item__c == 0){
                if(qline.Add_To_Cart__c==true){
                    if(!sapMaxLineNumMap.containskey(qline.Quote__c) || sapMaxLineNumMap.get(qline.Quote__c).get(0) == null || sapMaxLineNumMap.get(qline.Quote__c).get(0) == 0 ){
                        sapLineNumber = 400;
                    }else{
                        if(sapMaxLineNumMap.get(qline.Quote__c).get(0)== 200){
                            sapLineNumber = sapMaxLineNumMap.get(qline.Quote__c).get(0) + 200;
                        }else{
                            sapLineNumber = sapMaxLineNumMap.get(qline.Quote__c).get(0) + 100;
                        }
                    }
                }else if(sapLineNumber == 0 || sapLineNumber == null ){
                    sapLineNumber = sapMaxLineNumMap.get(qline.Quote__c).get(0) + 200;
                }
                //Update the latest Max Sap Number
                sapMaxLineNumMap.get(qline.Quote__c).put(0,sapLineNumber);
            }else{
                if(sapMaxLineNumMap.get(qline.Quote__c).get(qline.Higher_Level_Item__c) !=NULL){  
                    sapLineNumber = sapMaxLineNumMap.get(qline.Quote__c).get(qline.Higher_Level_Item__c) + 1;
                }else if(qline.Add_To_Cart__c==false){
                    sapLineNumber = qline.Higher_Level_Item__c + 1;
                    }
                
                //Update the latest Max Sap Number
                sapMaxLineNumMap.get(qline.Quote__c).put(qline.Higher_Level_Item__c,sapLineNumber);
            }
            qline.SAP_Line_Number__c = sapLineNumber;
        }
        
        //Get all the Quote Numbers of associated Quotes
        Set<Id> quoteIds = new Set<Id>(); 
        for (Quote_Line__c quoteLine : quoteLines){
            quoteIds.add(quoteLine.Quote__c); 
        }
        
        Map<Id, Quote> quoteMap = new Map<Id, Quote>([select Id, Quote_Number__c from Quote where Id In: quoteIds]); 
        
        for (Quote_Line__c quoteLine : quoteLines) { 
            if (quoteLine.Key__c == null){
                quoteLine.Key__c = quoteMap.get(quoteLine.Quote__c).Quote_Number__c + '-' + quoteLine.SAP_Line_Number__c;  
            }
        }
    } //End - IBA 1253 - New logic based on Add to cart - Bharath Mulpuri 02/04/2021
    
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        List<Quote_Line__c> oldQuoteLineList = oldItems.values();
        List<Quote_Line__c> IntQuoteLineList = new List<Quote_Line__c>();
        isDelete=true;
        if (userinfo.getName() != Label.Integration_admin_user ) {
            for(Quote_Line__c qli:oldQuoteLineList){
                IntQuoteLineList.add(qli);                    
            }
            connectToCastIronDelete(IntQuoteLineList);
        }
    }
    
    //Once Quote_Line__c is deleted,invoke REST api class to connect to CastIron. 
    public void connectToCastIronDelete(List<Quote_Line__c> oldQuoteLineList){
        
        Id SAPRecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('SAP Quote Line').getRecordTypeId();
        Set<Id> qliId = new Set<Id>();
        if(oldQuoteLineList.size()>0){
            for(Quote_Line__c qli : oldQuoteLineList){
                //validation rule - if the recordtype is SAP Quote Line then you cannot delete it in SF, unless you are the integration user
                if (qli.recordtypeid==SAPRecordTypeId && userinfo.getName() != Label.Integration_admin_user){
                    qli.addError('You cannot delete a Quote Line which was created in Cincom or SAP.  You must delete it in Cincom or SAP directly.');
                }
                if(qli.SAP_Line_Item_GUID__c!=null){
                    qliId.add(qli.Id);
                }
            }
        }
        try {
            if(System.IsBatch() == false && System.isFuture() == false && qliId.size()>0 && Userinfo.getName() != Label.Integration_admin_user){ 
                OmnicellQuoteLineToCastIron_Class.callOutMethodDelete(qliId);
            }          
        }catch(Exception e){
            ErrorLogging.Log(e, 'connectToCastIronDelete','App');
        }
    }
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        if(!fromprint){
            List<Quote_line__c> oldlines = oldItems.values();
            List<Quote_Line__c> QuoteLineList = newItems.values();
            
            String profileName = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;            
            
            //IBA-1374 Sahid -Starts 
            List<Quote_Line__c> quoteLineListWithParentData = [Select Product__r.DW_Product_Family__c,Quantity__c,Number_of_Units__c, quote__c from Quote_Line__c where Id in :newItems.keySet()];
            for(Quote_Line__c iql: quoteLineListWithParentData){
                if(iql.Product__r.DW_Product_Family__c == 'Solution' && iql.Number_of_Units__c != 1){
                    iql.Number_of_Units__c = 1;
                }
            }//IBA-1374 Sahid -Ends
            
            for(Quote_Line__c ql: QuoteLineList){
                if(!(QuotePrintController.isQuoteUpdateFrom_QuotePrintController || System.isBatch())){
                    if(Validation_Rules_Exception__c.getOrgDefaults().Run_Validation_Rules__c && ql.External_Config__c && profileName != 'System Administrator'){
                        ql.adderror('You are not allowed to update record as External Config checkbox is checked.');
                    }
                }

                if(isFirst){
                    if (((ql.SAP_Line_Item_GUID__c=='' || ql.SAP_Line_Item_GUID__c==null) && !ql.Resend_to_SAP__c) && ql.Add_to_cart__c!= True){
                        ql.addError('You cannot send an update to a Quote Line until you have received a SAP Quote Line GUID back after creating a Quote Line.  Please try your update again in a few minutes.');
                    }
                }
                
                if (ql.Resend_to_SAP__c){ //IBA-4955 Pabitra
                	   reSendToSap = true;
                 	   ql.Resend_to_SAP__c=false;
                } 

            } //IBA-3929 Pabitra: end            

            if(isFirstTime){
                UpdateQLTPicklist(newItems.values());
                calculateLineExpectedBookingValue(newItems.values()); //IBA-1813
            }
        }
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        List<Quote_Line__c> oldQuoteLineList = oldItems.values();
        updateQuoteStatus(oldQuoteLineList);
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
        List<Quote_Line__c> QuoteLineList = newItems.values();

        //IBA-3929 Pabitra : start
        Map<String,String> asgPrtflSgmntMap = new Map<String,String>();
        for (String prt1 : Label.Portfolio_Segment_OCE.split(',')){asgPrtflSgmntMap.put(prt1,Label.OCE_Product);}
        for (String prt2 : Label.Portfolio_Segment_IVS.split(',')){asgPrtflSgmntMap.put(prt2,Label.IVS_Product);}
        //IBA-3929 Pabitra : end

        Set<Id> asgQtLn = new Set<Id>();//IBA-3858
        Set<id> qlids = newItems.keySet();//IBA-4748: Saptarsha Panthi
        List<Quote_Line__c> quoteLineListWithParentData = [Select Quote__c,SAP_Line_Item_GUID__c,Product__r.Portfolio_Segment__c,Product__r.ProductCode from Quote_Line__c where Id in :qlids];
        for(Quote_Line__c iql: quoteLineListWithParentData){  //IBA-3929 Pabitra  //IBA-4748: Saptarsha Panthi    
            if(iql.SAP_Line_Item_GUID__c != null && asgPrtflSgmntMap.containsKey(iql.Product__r.Portfolio_Segment__c) 
               && iql.Product__r.ProductCode != Label.OCE_Product && iql.Product__r.ProductCode != Label.IVS_Product){
                   asgQtLn.add(iql.Id);
            } //IBA-3858 end
        }
        
        //IBA-3858 start    
        if(asgQtLn.size() > 0){
            System.enqueueJob(new AutoAddQuoteLine(asgQtLn));    
        }
        //IBA-3858 end
        
        isFirst=false; 
        updateQuoteStatus(QuoteLineList);
        connectToCastIronInsert(QuoteLineList);
    }
    
    //Once Quote_Line__c is created,invoke REST api class to connect to CastIron. 
    public void connectToCastIronInsert(List<Quote_Line__c> QuoteLineList){
        
        Set<Id> QuoteID = new Set<Id>();
        Set<Id> newqliId = new Set<Id>();
        Set<Id> qliId = new Set<Id>();
        Set<Id> autoQlId = new Set<Id>(); //IBA-3858
        
        List<Quote_Line__c> updateQliList = new List<Quote_Line__c>();
        List<Quote_Line__c> updateQteList = new List<Quote_Line__c>();
        
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        RecordType qlLeaseBuyoutRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Lease Buyout'];
        RecordType qlLeaseRenewalRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Lease Renewal'];
        if(QuoteLineList.size()>0){
            for (Quote_Line__c ql : QuoteLineList){
                //Bharath Mulpuri: Standard Config lines are only sent during update event for SAP 11/05/2020
                if(ql.Add_to_Cart__c != True){
                    QuoteID.add(ql.Quote__c);
                    newqliId.add(ql.Id);
                }
            }
            //IBA-3858 start
            for (Quote_Line__c autoQl : [Select Quote__c,Product__r.Portfolio_Segment__c,Product__r.ProductCode from Quote_Line__c where Id in :newqliId]){
                if(autoQl.Product__r.ProductCode == Label.OCE_Product || autoQl.Product__r.ProductCode == Label.IVS_Product){ 
                    autoQlId.add(autoQl.Id);
                }
            }//IBA-3858 end
        }   
        try{
            if(System.IsBatch() == false && System.isFuture() == false && newqliId.size()>0 && Userinfo.getName() != Label.Integration_admin_user){
                OmnicellQuoteLineToCastIron_Class.callOutMethodInsert(newqliId);
            }
            //IBA-3858 start
            if(System.IsBatch() == false && System.isFuture() == false && autoQlId.size()>0 && Userinfo.getName() == Label.Integration_admin_user){
                OmnicellQuoteLineToCastIron_Class.callOutMethodInsert(autoQlId);    
            } //IBA-3858 end
            
        }catch(Exception e){
            ErrorLogging.Log(e, 'connectToCastIronInsert','App');
        }
    }   
    
    public static Map<Id, Quote_line__c> convertSobjectToQuoteLineMap(Map<Id, SObject> sObjectMap){
        Map<Id, Quote_line__c> qliMap = new Map<Id, Quote_line__c>();
        for(sObject sobj: sObjectMap.values()){
            Quote_line__c qli = (Quote_line__c) sobj;
            qliMap.put(qli.Id, qli);
        }
        return qliMap;
    }
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){ 
        List<Quote_Line__c> newQuoteLines = newItems.values();
        Map<Id,Quote_line__c> oldQuotemap = convertSobjectToQuoteLineMap(oldItems);
        List<Quote_Line__c> SAP_Quotelines = new List<Quote_Line__c>();
        List<Quote_Line__c> SAP_autoAddQtlns = new List<Quote_Line__c>(); //IBA-3858
        List<Quote_Line__c> SAP_autoCancelQtlns = new List<Quote_Line__c>(); //IBA-5747
        Boolean isUpdate = false;//IBA-2388 Pritha
        Set<Id> qtsids = new Set<Id>();
        Set<Id> asgQtLn = new Set<Id>(); //IBA-3858
        Map<Decimal,Quote_Line__c > newMapCart = new Map<Decimal, Quote_Line__c>();
        for(Quote_Line__c qli : newQuoteLines){
            if(qli.Add_to_cart__c == True && (qli.Higher_Level_Item__c == 0 || qli.Higher_Level_Item__c == null)){
                newMapCart.put(qli.SAP_Line_Number__c, qli);
            }

            //IBA-2388 starts Pritha -- || qli.Unit_of_Measure__c != oldQuotemap.get(qli.Id).Unit_of_Measure__c as part of IBA-3424
            if(qli.Quote__c != oldQuotemap.get(qli.Id).Quote__c
               || qli.Quote__c != oldQuotemap.get(qli.Id).Quote__c
               || qli.Product__c != oldQuotemap.get(qli.Id).Product__c
               || qli.Quantity__c != oldQuotemap.get(qli.Id).Quantity__c               
               || qli.Par_Location__c != oldQuotemap.get(qli.Id).Par_Location__c
               || qli.Requested_Delivery_Date__c != oldQuotemap.get(qli.Id).Requested_Delivery_Date__c 
               || qli.Higher_Level_Item__c != oldQuotemap.get(qli.Id).Higher_Level_Item__c
               || qli.SAP_Line_Number__c != oldQuotemap.get(qli.Id).SAP_Line_Number__c
               || qli.Pricing_Reference_Model__c != oldQuotemap.get(qli.Id).Pricing_Reference_Model__c
               || qli.Pricing__c != oldQuotemap.get(qli.Id).Pricing__c 
               || qli.Pricing_Amount__c != oldQuotemap.get(qli.Id).Pricing_Amount__c
               || qli.SAP_Line_Item_GUID__c != oldQuotemap.get(qli.Id).SAP_Line_Item_GUID__c 
               || qli.Line_Status__c != oldQuotemap.get(qli.Id).Line_Status__c
               || qli.Serial_Number__c != oldQuotemap.get(qli.Id).Serial_Number__c
               || qli.id != oldQuotemap.get(qli.Id).id 
               || qli.Add_to_cart__c == True
               || reSendToSap == true){//IBA-4955 Pabitra
                   isUpdate = True;
               } //IBA-2388 ends Pritha           
        }
        //IBA-3858 start
        for(Quote_Line__c qtLn : newQuoteLines){ //IBA-5959
            if((qtLn.Higher_Level_Item__c != oldQuotemap.get(qtLn.Id).Higher_Level_Item__c && userinfo.getName() == Label.Integration_admin_user 
                && (qtLn.Product__r.ProductCode == Label.OCE_Product || qtLn.Product__r.ProductCode == Label.IVS_Product)) && qtLn.Line_Status__c != Label.Conga_Quote_Line_Status){//IBA-5959
                SAP_autoAddQtlns.add(qtLn);   
            }                                      
        } //IBA-3858 end
        
        for(Quote_Line__c qli : newQuoteLines){
            if((qli.Add_to_cart__c == True && qli.Interim_flag__c==False && qli.Interim_flag__c!= oldQuotemap.get(qli.Id).Interim_flag__c) || 
               (qli.Add_to_cart__c== False && (!newMapCart.containskey(qli.Higher_Level_Item__c)|| newMapCart.isEmpty())) || 
               (qli.Add_to_cart__c== False && !newMapCart.isEmpty() && newMapCart.containskey(qli.Higher_Level_Item__c) && 
                qli.Interim_flag__c==False && qli.Interim_flag__c != oldQuotemap.get(qli.Id).Interim_flag__c)){
                    SAP_Quotelines.add(qli);               
            }
            qtsids.add(qli.quote__c);
        }
        
        //IBA-5747 starts SH
        Boolean ParentProdCancelled = false;
        Integer count = 0;
        Integer OCEcount = 0;
        Boolean cancelQL = false;
        Map<String,String> asgPrtflSgmntMap = new Map<String,String>(); // Pulled this from below as part of IBA-5747 SH
        for (String prt1 : Label.Portfolio_Segment_OCE.split(',')){asgPrtflSgmntMap.put(prt1,Label.OCE_Product);} // Pulled this from below as part of IBA-5747 SH
        Quote_Line__c qlToBeCancelled = new Quote_Line__c();
        
        for(Quote_Line__c qli : newQuoteLines){//IBA-5959
            if(qli.Higher_Level_Item__c != null && qli.Product__r.Portfolio_Segment__c != null){//IBA-5959
                if(asgPrtflSgmntMap.containskey(qli.Product__r.Portfolio_Segment__c) && qli.Product__r.ProductCode != Label.OCE_Product && qli.Higher_Level_Item__c == 0){
                    if(qli.Line_Status__c == Label.Conga_Quote_Line_Status){
                        ParentProdCancelled = true;
                    }else{
                        count = count + 1; //More than one parent with same PS not cancelled
                    }
                }
                if(asgPrtflSgmntMap.containskey(qli.Product__r.Portfolio_Segment__c) && qli.Product__r.ProductCode == Label.OCE_Product && qli.Higher_Level_Item__c == 0 && qli.Line_Status__c != Label.Conga_Quote_Line_Status){
                    if(ParentProdCancelled){
                        qlToBeCancelled = qli; // Label.OCE_Product quote line
                    }else{
                        OCEcount = OCEcount + 1; // No parent but having OCE-LIC-002
                        qlToBeCancelled = qli;
                    }
                }
            }
        } // For loop end SH
        
        if(ParentProdCancelled && count == 0 && qlToBeCancelled.Id != null && qlToBeCancelled.Higher_Level_Item__c != null){ //if all the parents are cancelled
            qlToBeCancelled.Line_Status__c = Label.Conga_Quote_Line_Status;
            AutoAddQuoteLine.CancelOCEProducts(qlToBeCancelled); //Updating the QL in SF
            SAP_autoCancelQtlns.add(qlToBeCancelled); //To send the cancelled QL status to SAP
            cancelQL = true;
        }
        
        if(!ParentProdCancelled && count == 0 && OCEcount > 0 && qlToBeCancelled.id != null && qlToBeCancelled.Higher_Level_Item__c != null){ //if OCE item is there without any parent product
            qlToBeCancelled.Line_Status__c = Label.Conga_Quote_Line_Status;
            AutoAddQuoteLine.CancelOCEProducts(qlToBeCancelled); //Updating the QL in SF
            SAP_autoCancelQtlns.add(qlToBeCancelled); //To send the cancelled QL status to SAP
            cancelQL = true;
        }
        //IBA-5747 ends SH
        
        if(!fromprint){            
            afterUpdateScope = true;
            afterUpdateScope = false;
            isFirst = false;
            if(isFirstTime && !isInsert && !fromprint){
                isFirstTime = false;
                if(userinfo.getName() != Label.Integration_admin_user && isDelete==false){
                    if(isUpdate){ //IBA-2388
                        connectToCastIronUpdate(SAP_Quotelines);
                    }
                }
                //IBA-3858 start
                if(userinfo.getName() == Label.Integration_admin_user && SAP_autoAddQtlns.size() >0){
                    connectToCastIronUpdate(SAP_autoAddQtlns);
                } //IBA-3858 end
                
                //IBA-5747 SH
                if(SAP_autoCancelQtlns.size() > 0 && cancelQL){
                    connectToCastIronUpdate(SAP_autoCancelQtlns);
                }
                //IBA-5747 end SH
            }
            
            if(fromprint == true){
                QuoteTriggerHandler.updatefromquotelines = true;
            }
            
            //IBA-3929 Pabitra : start
            //Map<String,String> asgPrtflSgmntMap = new Map<String,String>(); // Moved this above as part of IBA-5747 SH
            //for (String prt1 : Label.Portfolio_Segment_OCE.split(',')){asgPrtflSgmntMap.put(prt1,Label.OCE_Product);} // Moved this above as part of IBA-5747 SH
            for (String prt2 : Label.Portfolio_Segment_IVS.split(',')){asgPrtflSgmntMap.put(prt2,Label.IVS_Product);}
            //IBA-3929 Pabitra : end
            List <Quote_line__c> qliLinestocheck = [SELECT Id, Quote__c, SAP_Line_Item_GUID__c,Product__r.Portfolio_Segment__c,Product__r.ProductCode FROM Quote_line__c WHERE Id IN : newItems.keySet() and Line_Status__c != :Label.Conga_Quote_Line_Status]; //IBA-4748 Saptarsha, added Line_Status__c != :Label.Conga_Quote_Line_Status as part of IBA-5747 SH
            
            for(Quote_Line__c objQuoteLine : qliLinestocheck){//IBA-3929 - Pabitra //IBA-4748 Saptarsha
                if(oldQuotemap.get(objQuoteLine.Id).SAP_Line_Item_GUID__c == null && objQuoteLine.SAP_Line_Item_GUID__c != oldQuotemap.get(objQuoteLine.Id).SAP_Line_Item_GUID__c
                && asgPrtflSgmntMap.containsKey(objQuoteLine.Product__r.Portfolio_Segment__c) 
                && objQuoteLine.Product__r.ProductCode != Label.OCE_Product && objQuoteLine.Product__r.ProductCode != Label.IVS_Product){
                  asgQtLn.add(objQuoteLine.Id);
               } //IBA-3858 end
           }
        }
        //IBA-3858 start    
        if(asgQtLn.size() > 0){
            System.enqueueJob(new AutoAddQuoteLine(asgQtLn));    
        } //IBA-3858 end          
    }          
    
    //Once Quote_Line__c is updated,invoke REST api class to connect to CastIron. 
    public void connectToCastIronUpdate(List<Quote_Line__c> QuoteLineList){
        Set<Id> QuoteID = new Set<Id>();
        Set<Id> qliId = new Set<Id>();
        Set<Id> qliIdInsert = new Set<Id>();
        //Bharat Add to Cart for Delete Flag check
        Boolean isCartItemDelete = false;
        
        List<Quote_Line__c> updateQliList = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];            
        RecordType qlLeaseBuyoutRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Lease Buyout'];
        RecordType qlLeaseRenewalRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Lease Renewal'];
        
        if(QuoteLineList.size()>0){
            for (Quote_Line__c ql : QuoteLineList){
                QuoteID.add(ql.Quote__c);
            }
        }   
        List<Quote_Line__c> newQuoteLineList = [select id,Quote__c,Quote__r.SAP_Last_Line_Number__c,Product__c,Product__r.ProductCode,SAP_Line_Number__c,Cart_Item_to_Delete__c from Quote_Line__c where Quote__c IN: QuoteID];     
        if(newQuoteLineList.size()>0){
            //Andrew Edit on 1/16/19 - just sending the quote lines that have changed not all lines on all quotes which changed.         
            for(Quote_Line__c qli : QuoteLineList) {
                qliId.add(qli.Id);
                
                if(qli.Cart_Item_to_Delete__c){
                    isCartItemDelete = isCartItemDelete || qli.Cart_Item_to_Delete__c;
                }
            }
            
            try{
                if(System.IsBatch() == false && System.isFuture() == false && qliId.size()>0 && Userinfo.getName() != Label.Integration_admin_user){ 
                    if(isCartItemDelete){
                        OmnicellQuoteLineToCastIron_Class.callOutMethodDeleteUpdate(qliId);
                    }else{
                        OmnicellQuoteLineToCastIron_Class.callOutMethodUpdate(qliId);
                    }
                }
              }catch(Exception e){
                ErrorLogging.Log(e, 'connectToCastIronUpdate','App');
            }
        }
    }
    
    //This method is to update Quote Status on Creation and Deletion of Quote Line item records
    // Author : Venu Kukkapalli
    public  void updateQuoteStatus(List<Quote_line__c> qlList){
        List<Id> qtList=new List<Id>();
        List<Id> lockList=new List<Id>();
        List<Quote> quoteList=new List<Quote>();
        
        for(Quote_line__c ql:qlList){
            if(!qtList.contains(ql.Quote__c)){
                if(approval.isLocked(ql.Quote__c)){
                    lockList.add(ql.Quote__c);
                }
                qtList.add(ql.Quote__c);
            }
        }
        Approval.unlock(lockList);
        for(Quote qt:[Select Id,Status,Update_from_quote_lines__c FROM Quote WHERE Id in: qtList]){
            if (qt.status != 'E0001') { //added to fix UNABLE_TO_LOCK_ROW errors. No need to update the quote if it already was E0001
                qt.status='E0001';
                qt.Update_from_quote_lines__c = true;
                quoteList.add(qt);
            }
        }
        try{
            if(quoteList.size()>0){ //IBA-3929 Pabitra
            	update quoteList;
            }
        }Catch(Exception e){
            ErrorLogging.Log(e, 'updateQuoteStatus','App');
        }
    }
    
    //This method to update Quote Line Type Picklist on Quote Line creation and updation
    //Haripriya
    public void UpdateQLTPicklist(List<Quote_Line__c> qlList){
        Set<Id> qtIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        List<Quote_Line__c> qlRecords = new List<Quote_Line__c>(); //1815
        Map<String,Quote_Line__c> qlMap = new Map<String,Quote_Line__c>(); //1815
        Map<id,String> qlMap3 = new Map<id,String>(); //IBA-2345
        Set<Id> prdIds = new Set<Id>(); //IBA-2345
        
        for(Quote_Line__c ql:qlList){
            qtIds.add(ql.Quote__c);
            prdIds.add(ql.Product__c); //IBA-2345
        }
        //START-IBA-2345
        List<product2> lstPrd = [Select id,DW_Product_Class__c from product2 where id IN :prdIds];
        if(lstPrd != Null && lstPrd.size()>0) {
            for(product2 p: lstPrd) {
                qlMap3.put(p.id,p.DW_Product_Class__c);
            }
        }//END-IBA-2345
        
        //START-1815
        qlRecords = [Select id,Product__r.DW_Product_Class__c,Quote_Line_Item_Type__c,SAP_Line_Number__c,higher_level_item__c,Quote__c from Quote_Line__C where Quote__c in :qtIds]; //1815
        for(Quote_Line__c ql: qlRecords) {
            Integer sln = Integer.valueOf(ql.SAP_Line_Number__c);
            String keyValue = String.valueOf(ql.Quote__c) + String.valueOf(sln);
            qlMap.put(keyValue,ql);
        } //END-1815
        Map<Id,Quote> QtRecords = new Map<Id,Quote>([Select Opportunityid from Quote where id in :qtIds]);
        
        for(Quote q: QtRecords.values()){
            oppIds.add(q.OpportunityId);
        }        
        Map<Id,Opportunity> oppRecords = new Map<Id,Opportunity>([Select id,CustomerType__c,Competitor__c,Competitor__r.Name from Opportunity where id in : oppIds]);
        
        for(Quote_Line__c ql:qlList){
            String dwClassValue = qlMap3.get(ql.Product__c); //IBA-2345
            //1815
            if(ql.Quote_Line_Item_Type__c == 'Replacement') {
                ql.Quote_Line_Item_Type__c='Replacement';
            }else {
                for(Opportunity o: oppRecords.Values()){
                    //IBA-2345
                    if(dwClassValue == 'De-installation') {
                        ql.Quote_Line_Item_Type__c='Decommission';                        
                    }else {
                        if(o.CustomerType__c == System.Label.Existing_Customer && ql.Serial_Number__c == null){
                            ql.Quote_Line_Item_Type__c='Add-on';
                        }else if(o.CustomerType__c == System.Label.New_Customer && o.Competitor__r.Name != System.Label.Greenfield && ql.Serial_Number__c == null){
                            ql.Quote_Line_Item_Type__c='Competitive Conversion';
                        }else if(o.CustomerType__c == System.Label.New_Customer && o.Competitor__r.Name == System.Label.Greenfield && ql.Serial_Number__c == null){
                            ql.Quote_Line_Item_Type__c='New';
                        }else if(ql.Serial_Number__c != null){
                            ql.Quote_Line_Item_Type__c='Replacement';                
                        }
                    }  
                }
                //1815
                Integer hli = Integer.valueOf(ql.Higher_Level_Item__c);
                String keyval = String.valueOf(ql.Quote__c) + String.valueOf(hli);
                Quote_Line__c qlRecord = qlMap.get(keyval);
                if(qlRecord != Null && qlRecord.Quote_Line_Item_Type__c == 'Replacement') {
                    ql.Quote_Line_Item_Type__c='Replacement';
                }
                //IBA-2345
                if(qlRecord != Null && qlRecord.Quote_Line_Item_Type__c == 'Decommission') {
                    ql.Quote_Line_Item_Type__c='Decommission';
                }
            }
        }
    }
    
    //IBA-1813
    public void calculateLineExpectedBookingValue(List<Quote_Line__c> qlList){ 
        Set<Id> qtIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> OppMapping = new Map<Id,Id>();
        for(Quote_Line__c ql:qlList){
            qtIds.add(ql.Quote__c);
        }
        Map<Id,Quote> QtRecords = new Map<Id,Quote>([Select id,Order_Type__c,OpportunityId from Quote where id in :qtIds]);
        for(Quote q: QtRecords.values()){
            oppIds.add(q.OpportunityId);
            OppMapping.put(q.id,q.OpportunityId);
        } 
        Map<Id,Opportunity> oppRecords = new Map<Id,Opportunity>([Select id,Opportunity__c from Opportunity where id in : oppIds]);
        for(Quote_Line__C ql: qlList) {
            if(ql.Line_Status__c == 'E0006') {  //IBA-2240
                ql.Line_Expected_Booking__c = 0;
            }else {  //IBA-2240
                Id oppId = OppMapping.get(ql.Quote__c);
                Opportunity oppRecord = oppRecords.get(oppId);
                Quote q = QtRecords.get(ql.Quote__c);
                Decimal rebate;
                if(ql.Rebate_Buyout_Adjustment__c != Null) {
                    if(ql.Rebate_Buyout_Adjustment__c < 0) {
                        rebate = ql.Rebate_Buyout_Adjustment__c * (-1);
                    }else {
                        rebate = ql.Rebate_Buyout_Adjustment__c;
                    }    
                }else {
                    rebate = 0;
                }
                if(ql.Product_Code__c == 'LEASE BUYOUT') {
                    ql.Line_Expected_Booking__c = 0;
                }
                if(ql.Material_Type__c == 'PRODUCT' && q.Order_Type__c != 'ZQRS' && ql.Product_Code__c != 'LEASE BUYOUT') {
                    if(ql.SAP_Line_Expected_Booking__c != Null && rebate != Null) {
                        ql.Line_Expected_Booking__c = ql.SAP_Line_Expected_Booking__c - rebate ;
                    }
                }
                if((ql.Material_Type__c == 'PRODUCT' || ql.Material_Type__c == 'SERVICE') && q.Order_Type__c == 'ZQRS' && ql.Product_Code__c != 'LEASE BUYOUT') {
                    if(ql.SAP_Line_Expected_Booking__c != Null && rebate != Null) {
                        ql.Line_Expected_Booking__c = ql.SAP_Line_Expected_Booking__c - rebate ;
                    }
                }
                if(oppRecord.Opportunity__c == 'Change Order - Credit' && ql.Line_Expected_Booking__c != Null && ql.Line_Expected_Booking__c != 0) {
                    ql.Line_Expected_Booking__c = ql.Line_Expected_Booking__c * (-1);
                }
            }                
        }
    }
    
}