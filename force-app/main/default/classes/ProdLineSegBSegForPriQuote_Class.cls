/***********************************************************************************************************
Name:  ProdLineSegBSegForPriQuote_Class
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Whenever a Quote created or updated, this Class will checks whether it's a Primary Quote or not,
if it is a Primary Quote then deletes all existing records of Product Line, Product Segment, Business Segment and
Quote Line Type objects. And creates new records based on the latest updates of Quote Line items, Product details.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Pabitra Tripathy          08/24/2022     					     INITIAL DEVELOPMENT
0.2          Pabitra Tripathy          10/30/2023     					     Restructured code 
*************************************************************************************************************/
public with sharing class ProdLineSegBSegForPriQuote_Class{
    
    public void initiateProductUpdates(List<Quote> quoteList,List<Quote> oldQuoteList){
        Set<Id> qtOpprSet=new Set<Id>();
        Set<Id> qtIdsSet = new Set<Id>();
        
        for(Quote qt : quoteList){
            //if Primary quote and status - Booked,Completed,Offline build quote,Advanced Services Order,zero value
            if((qt.Primary_Quote__c == true)&&(qt.Status == 'E0013' || qt.Status == 'E0014' || qt.Status == 'E0019' 
                                               || qt.Status == 'E0024'|| qt.Status == 'E0023')){
            	qtOpprSet.add(qt.OpportunityId);    
                qtIdsSet.add(qt.Id);
            }
        }
        
        List<Quote> quoteToUpdate = [SELECT Id,Booking_Date__c,OpportunityId,Order_Type__c,SAP_Expected_Bookings__c,
                                     Product_Line_Error__c,Re_create_Product_Line__c  
                                     FROM Quote WHERE Id IN:qtIdsSet];
        //Quote's Opportunity info
        Map<id,Boolean> oppIdStatusMap = new Map<id,Boolean>();
        Map<id,String> oppIdTypeMap = new Map<id,String>(); //SF-BUG-909
        List<Opportunity> oppList = [SELECT id,oppStatus__c,Opportunity__c FROM Opportunity WHERE id IN:qtOpprSet];
        for(Opportunity opp:oppList){
            if(opp.oppStatus__c == Label.Fully_Booked || opp.oppStatus__c == Label.Non_Comissionable_Booking 
               || opp.oppStatus__c == Label.Commissionable_Book_No_Service_PO
               || opp.oppStatus__c == Label.Non_Comm_Book_No_Service_PO
               // || opp.OppStatus__c == Label.Non_Comm_Book_No_Proj_Plan  IBA-4182 Starts
               ||opp.OppStatus__c==Label.Booked_with_No_PO
               ||opp.OppStatus__c==Label.Booked_with_No_Service_PO
               ||opp.OppStatus__c==Label.Booked_with_No_Product_PO //IBA-4182 Ends
               //|| status == Label.PO_Received_Pending_Paperwork
               //|| status == Label.PO_Received
               //IBA-2010
              ){
                  oppIdStatusMap.put(opp.id,true);  // opportunity status  
              }else{
                  oppIdStatusMap.put(opp.id,false);  // opportunity status
              }
            oppIdTypeMap.put(opp.id,opp.Opportunity__c); //Opportunity Type - SF-BUG-909 opportunity type ie change order credit
        }
        
        //XR2 omnicell service order type: ZQRS, update by SRAVAN - 29 NOV START    
        List<ProductLineServiceOrderTypes__c> plSvcOrderTypes = [select id,service_order_type__c from ProductLineServiceOrderTypes__c];
        
        //Create quote id,QuoteLine Map
        Map<Id,List<Quote_Line__c>> qIdLineItemsMap = new Map<Id,List<Quote_Line__c>>();
        List<Quote_Line__c> quoteLineItems = [SELECT ID,Higher_Level_Item__c,Product__r.Portfolio_Segment__c,Rebate_Buyout_Adjustment__c,
                                              Name,Quote__r.Id,Quote__r.Primary_Quote__c,SAP_NPV__c,SAP_Expected_Bookings__c,Total_Cost__c,
                                              Quantity__c,Product_Code__c,DW_Product_Line__c,Quote_Line_Item_Type__c,Number_of_Units__c,Material_Type__c 
                                              FROM Quote_Line__c WHERE Quote__r.Id IN :qtIdsSet 
                                              AND Line_Status__c!='E0006' AND Product_Code__c!='LEASE BUYOUT'];
        
        for(Quote_Line__c ql : quoteLineItems){
            if(qIdLineItemsMap.containsKey(ql.Quote__c)){
                List<Quote_Line__c> qtLines = qIdLineItemsMap.get(ql.Quote__c);
                qtLines.add(ql);
                qIdLineItemsMap.put(ql.Quote__c,qtLines);
            }else{
                List<Quote_Line__c> qtLines=new List<Quote_Line__c>();
                qtLines.add(ql);
                qIdLineItemsMap.put(ql.Quote__c,qtLines);
            }    
        }
        
        List<Product_Line__c> prodLines=[SELECT Quote__c,Product_Line_Picklist2__c,Amount__c,Opportunity__c,Portfolio_Segment__c 
                                         FROM Product_Line__c WHERE Quote__c IN:qtIdsSet];
        Map<Id,List<Product_Line__c>> proLinesMap = new Map<Id,List<Product_Line__c>>();
        for(Product_Line__c prl:prodLines){
            if(proLinesMap.containsKey(prl.Quote__c)){
                List<Product_Line__c> plLines = proLinesMap.get(prl.Quote__c);
                plLines.add(prl);
                proLinesMap.put(prl.Quote__c,plLines);
            }else{
                List<Product_Line__c> plLines=new List<Product_Line__c>();
                plLines.add(prl);
                proLinesMap.put(prl.Quote__c,plLines);
            }    
        }
        
        for(Quote qt : quoteToUpdate){
            createProductLine(qt,plSvcOrderTypes,oppIdStatusMap,oppIdTypeMap,qIdLineItemsMap,proLinesMap);
        }
    }
    
    //To delete Old Product Line records and Create new Product Line records
    public void createProductLine(Quote qt,List<ProductLineServiceOrderTypes__c> plSvcOrderTypes, Map<Id,Boolean> oppIdStatusMap,
                                  Map<Id,String> oppIdTypeMap,Map<Id,List<Quote_Line__c>> qIdLineItemsMap,Map<Id,List<Product_Line__c>> proLinesMap){
                Id quoteId;       
                try{    
                    Date dateBooked = qt.Booking_Date__c;
                    Id opportunityId = qt.OpportunityId;   
                    String ordertype = qt.Order_Type__c;//XR2 omnicell service order type update by SRAVAN - 29 NOV
                    quoteId = qt.Id;
                                          
                    //Quote's Opportunity info
                    Boolean isOpportunityBooked=false;
                    if(oppIdStatusMap.containsKey(OpportunityId)){
                    	isOpportunityBooked = oppIdStatusMap.get(OpportunityId);
                    }
                                          
                    //XR2 omnicell service order type: ZQRS, update by SRAVAN - 29 NOV START    
                    boolean servordertype = false;
                    for(ProductLineServiceOrderTypes__c plsvc : plSvcOrderTypes){
                    	if(plsvc.service_Order_type__c == ordertype){
                        	servordertype = true;
                        } 
                    }
                                          
                    //Quote's List of Quotelines excluding line status cancelled,Leased buyout 
                    List<Quote_Line__c> qtLineItems = qIdLineItemsMap.get(quoteId);
                    List<Quote_Line__c> quoteLineItems = new List<Quote_Line__c>();
                    for(Quote_Line__c qlitms : qtLineItems){
                    	if(!servordertype){
                        	if(qlitms.Material_Type__c == 'PRODUCT') {
                            	quoteLineItems.add(qlitms);
                            }
                     }else{
                           quoteLineItems.addAll(qtLineItems);
                           break;
                          }
                     }
                     //Create Map of DW Product Line Name and list of assiciated quoteline 
                     String productLineName; 
                     Map<String,List<Quote_Line__c>> proLineNameQuoteLinesMap = new Map<String,List<Quote_Line__c>>(); 
                     if(quoteLineItems.size()>0){
                     	for(Quote_Line__c ql : quoteLineItems){
                        	if(ql.Product_Code__c!=null){
                            	if (!String.isBlank(ql.DW_Product_Line__c)) {
                                	productLineName = ql.DW_Product_Line__c.toLowerCase(); 
                                }else{
                                     	productLineName = 'N/A';
                                }
								//IBA-3263 fix
                                if(ql.Higher_Level_Item__c != 0 && (ql.SAP_Expected_Bookings__c == 0 || ql.SAP_Expected_Bookings__c == NULL)) { 
                                	continue;
                                }else{
                                      if(proLineNameQuoteLinesMap.containsKey(productLineName)){
                                      	List<Quote_Line__c> prLineQtLines = proLineNameQuoteLinesMap.get(productLineName);
                                        prLineQtLines.add(ql);
                                        proLineNameQuoteLinesMap.put(productLineName,prLineQtLines);
                                      }else{
                                            List<Quote_Line__c> prLineQtLine=new List<Quote_Line__c>();
                                            prLineQtLine.add(ql);
                                            proLineNameQuoteLinesMap.put(productLineName,prLineQtLine);
                                      } 
                                }                        
                            }
                        }
                     }
                     
                    //Calculate New Product Lines's diffrent field values
                     Id qId;
                     Id qLId;
                     String portfolio;//Added Portfolio_Segment__c for SF-BUG-643
                     Decimal expectedBooking = 0; //IBA-3578
                     List<productLineWrapper> pLinewrapperList = new List<productLineWrapper>();
                     List<Product_Line__c> newProductLine = new List<Product_Line__c>();
                                          
                   for(String pLine : proLineNameQuoteLinesMap.keySet()){
                        decimal totAmount = 0; //IBA-3578
                        Double totQuantity = 0;
                        Double noOfUnits = 0; //Added by Jay for IBA-1374
                        Double replacementAmount=0;//IBA-1817
                        
                        List<Quote_Line__c> dwProdQuoteLines= proLineNameQuoteLinesMap.get(pLine);
                        for(Quote_Line__c ql : dwProdQuoteLines){
                            //IBA-3263 fix
                            if(ql.Higher_Level_Item__c != 0 && (ql.SAP_Expected_Bookings__c == 0 || ql.SAP_Expected_Bookings__c == NULL)) { 
                                continue;
                            }else {
                                qLId = ql.Id;
                                qId = ql.Quote__r.Id;
                                //IBA-3263 Fix
                                //if(!(ql.Higher_Level_Item__c != 0 && (ql.SAP_Expected_Bookings__c == 0 || ql.SAP_Expected_Bookings__c == NULL))) {
                                portfolio = ql.Product__r.Portfolio_Segment__c;//Added Portfolio_Segment__c for SF-BUG-643   
                                //}
                                if(ql.SAP_Expected_Bookings__c != null){
                                    //Added by Sravan on 16th SEP START SF-BUG-681
                                    if(ql.Rebate_Buyout_Adjustment__c != null)
                                        totAmount = totAmount + (ql.SAP_Expected_Bookings__c + ql.Rebate_Buyout_Adjustment__c);
                                    else
                                        totAmount = totAmount + ql.SAP_Expected_Bookings__c; 
                                    
                                    //IBA-1817 Pabitra
                                    if(ql.Quote_Line_Item_Type__c == 'Replacement'){
                                        replacementAmount+=ql.SAP_Expected_Bookings__c;
                                    }//IBA-1817 Pabitra
                                }
                                else{//Added by sravan for SF-BUG-857 START
                                    if(ql.Rebate_Buyout_Adjustment__c != null)
                                        totAmount = totAmount + (ql.Rebate_Buyout_Adjustment__c);                                
                                }//Added by sravan for SF-BUG-857 END
                                
                                if(ql.Quantity__c != null)
                                    totQuantity = totQuantity + ql.Quantity__c;
                                if(ql.Number_of_Units__c != null)//Added by Jay for IBA-1374
                                    noOfUnits += ql.Number_of_Units__c;//Added by Jay for IBA-1374
                            }
                        }
                        
                        expectedBooking = expectedBooking + totAmount;
                        productLineWrapper pLineWrapper = new productLineWrapper();
                        pLineWrapper.quoteLineItemId = qLId;
                        pLineWrapper.amount = totAmount;
                        pLineWrapper.dateBooked = dateBooked;
                        pLineWrapper.estimate = false;
                        pLineWrapper.opportunity = opportunityId;
                        pLineWrapper.productLine = pLine;
                        pLineWrapper.portfolioseg = portfolio;//Added Portfolio_Segment__c for SF-BUG-643
                        pLineWrapper.quantity = totQuantity;
                        pLineWrapper.noOfUnits = noOfUnits;//Added by Jay for IBA-1374
                        pLineWrapper.quote = qId;        
                        pLineWrapper.replacementAmount = replacementAmount;//IBA-1817 Pabitra
                        
                        pLinewrapperList.add(pLineWrapper);
                    }
                     //if newly calculated expected booking doesn't match with Quote header expected booking then quote isn't synced.
                     Boolean isQlSyncError = false;
                     Boolean isQlSynced = false;
                     if(expectedBooking!=qt.SAP_Expected_Bookings__c) {
                         isQlSyncError = true;
                     }else{
                           if(qt.Product_Line_Error__c!=null && qt.Product_Line_Error__c.length()>0){                               
                           		isQlSynced = true; // need to remove sync error message
                           }
                           // checks existing and newly generated product lines amount same or not
                           // 1. No existing product lines ie just booked quote
                           // 2. Existing no of PLs does not match with newly calculated PLs
                           // 3. Existing PLs amount mismatch with newly calculated PL
                           // 4. Existing PLs key mis-match
                           Boolean isPLsMatch=true;  
                           if(pLinewrapperList != null && !pLinewrapperList.isEmpty()){
                               List<Product_Line__c> prodLines=new List<Product_Line__c>();
                               if(proLinesMap.containsKey(quoteId)){
                               		prodLines=proLinesMap.get(quoteId);
                               }
                               Map<String,Double> existingProdLinesAmt = new Map<String,Double> ();
                               Map<String,String> existingProdLinesPortfolio = new Map<String,String> ();
                               if(prodLines!=null && !prodLines.isEmpty()){
                               		if(prodLines.size()!=pLinewrapperList.size()){
                                    	isPLsMatch = false;
                                    }else if(isOpportunityBooked && (prodLines[0].Opportunity__c!=opportunityId)){ // Opportunity is booked after Quote booking
                                                          isPLsMatch = false;
                                    }else if(isPLsMatch){
                                    	for (Product_Line__c exPline : prodLines){
                                        	existingProdLinesAmt.put((exPline.Product_Line_Picklist2__c).toLowerCase(),math.abs(exPline.amount__c));
                                            existingProdLinesPortfolio.put((exPline.Product_Line_Picklist2__c).toLowerCase(),exPline.Portfolio_Segment__c);
                                        }
                                                          
                                        for(productLineWrapper wrapObj :pLinewrapperList){
                                        	//match productline with newly created pls 
                                           if(existingProdLinesAmt.containsKey(wrapObj.productLine)){
                                            	if(existingProdLinesAmt.get(wrapObj.productLine)!=wrapObj.amount
                                                  ||existingProdLinesPortfolio.get(wrapObj.productLine)!=wrapObj.portfolioseg){
                                                  	isPLsMatch = false;
                                                    break;
                                                  }
                                            }else{
                                                  	isPLsMatch=false;
                                                    break;
                                            }
                                        }	
                                    }
                               }else{
                                    	isPLsMatch = false;
                               }
                           }
                                              
                           //if productline amount mis-match then first delete existing productlines then create new Productlines
                           if(!isPLsMatch){   
                               //Delete Productlines
                               deleteProductLines(quoteId,opportunityId,quoteLineItems,isOpportunityBooked);
                                                  
                               if(pLinewrapperList != null && !pLinewrapperList.isEmpty()){
                               		for(productLineWrapper wrapObj :pLinewrapperList){
                                    	String type = oppIdTypeMap.get(OpportunityId); //SF-BUG-909
                                        Product_Line__c productLine = new Product_Line__c();
                                        
                                        if(type == 'Change Order - Credit') {//SF-BUG-909
                                        	//Double amt = math.abs(wrapObj.amount); //IBA-4756 Pabitra
                                            productLine.Amount__c = (wrapObj.amount)* (-1);
                                        }else{
                                             	productLine.Amount__c = wrapObj.amount;
                                        }
                                        // productLine.Cost__c = wrapObj.cost;//commented for IBA-3299 
                                        productLine.Date_Booked__c = wrapObj.dateBooked;
                                        productLine.Estimate__c = wrapObj.estimate;
                                        if(isOpportunityBooked){
                                        	productLine.Opportunity__c = wrapObj.opportunity;
                                        }
                                        productLine.Product_Line_Picklist2__c = wrapObj.productLine;//design change: product line data type changed from text to picklist...productLine.Product_Line__c = wrapObj.productLine;
                                        productLine.Portfolio_Segment__c = wrapObj.portfolioseg;//Added Portfolio_Segment__c for SF-BUG-643
                                        productLine.Quantity__c = wrapObj.quantity;
                                        productLine.Number_of_Units__c = wrapObj.noOfUnits;//Added by Jay for IBA-1374
                                        productLine.Quote__c = wrapObj.quote;
                                        productLine.Replacement_Amount__c = wrapObj.replacementAmount; //IBA-1817 Pabitra
                                                          
                                        newProductLine.add(productLine);
                                    } 
                               }
                                                  if(newProductLine.size()>0){
                                                      insert newProductLine;
                                                  }
                                              }
                                          }
                           if(qt.Re_create_Product_Line__c==true || isQlSyncError == true || isQlSynced==true ){
                           	if(isQlSyncError){
                            	qt.Product_Line_Error__c = 'Quote is not Synced';
                            }
                            if(isQlSynced){
                            	qt.Product_Line_Error__c = '';
                            }
                            qt.Re_create_Product_Line__c = false;
                            QuoteTriggerHandler.TriggerDisabled = false;
                            update qt;
                           }
                }catch(Exception ex){
                                     ProductLine_Error__c errObj=new ProductLine_Error__c(QuoteId__c=quoteId,Error_Message__c=ex.getMessage(),
                                                                                               Error_Stacktrace__c=ex.getStackTraceString());
                                     insert errObj;
                }
           }
    
    
    
    void deleteProductLines(Id quoteId,Id opportunityId,List<Quote_Line__c> quoteLineItems,Boolean isOpportunityBooked){
        try{
            List<Product_Line__c> oPLine = [SELECT id,name,Quote__c,Quote__r.Primary_Quote__c,Opportunity__c FROM 
                                            Product_Line__c WHERE Quote__c =:quoteId OR Opportunity__c =:opportunityId];//as part of design change
            
            List<Product_Line__c> oldPLinesToDelete = new List<Product_Line__c>();// List to store and delete Product Lines
            Set<Product_Line__c> oldProductLine = new Set<Product_Line__c>();//Set to store old Product Lines associated with this primary Quote or Opportunity, only if primary quote doesn't have any Quote lines
            
            for(Product_Line__c pl: oPLine){
                if(quoteLineItems.size()>0){
                    if(pl.Opportunity__c == opportunityId || pl.Quote__c != null){
                        
                        if(isOpportunityBooked) {//added on 19th JUNE to delete product lines only when opp status is fully booked
                            oldProductLine.add(pl);
                        }else{ // if the Primary Quote changed after booking then Old Primary quote's PL needs to be deleted
                            if(pl.Quote__c != null){
                                oldProductLine.add(pl);
                            }
                        }
                    }                    
                }else if(oPLine.size()>0 && (pl.Opportunity__c == opportunityId || pl.Quote__c != null)){                    
                    if(isOpportunityBooked){ //added on 19th JUNE to delete product lines only when opp status is fully booked
                        oldProductLine.add(pl);
                    }
                }
            }
            
            oldPLinesToDelete.addAll(oldProductLine);
            if(oldPLinesToDelete.size() > 0 ){
                ProductLineTriggerHandler.isFromprodlineclass = true; //Added by sravan on 4 DEC for delete product line error SF-BUG-744
                delete oldPLinesToDelete;
            }
        }catch(Exception ex){
            ProductLine_Error__c errObj=new ProductLine_Error__c(QuoteId__c=quoteId,Error_Message__c=ex.getMessage(),
                                                                 Error_Stacktrace__c=ex.getStackTraceString());
            insert errObj;
        }
    }
    
    public class productLineWrapper{
        public Id quoteLineItemId;
        public Double amount;
        public Date dateBooked;
        public Boolean estimate;
        public Id opportunity;
        public String productLine;
        public String portfolioseg;//Added Portfolio_Segment__c for SF-BUG-643
        public Double quantity;
        public Double noOfUnits;//IBA-1374
        public Id quote;
        public Double replacementAmount;
        
        public productLineWrapper(){
        }
    }
}