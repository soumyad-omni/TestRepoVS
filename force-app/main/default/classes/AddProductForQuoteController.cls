/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-10-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class AddProductForQuoteController {
    @AuraEnabled
    public Static ShipToWrapper getShipToPicklist(string quoteId){
        ShipToWrapper stw = new ShipToWrapper();
        List<String> pickList = new List<String>();
        List<List<String>> allPickList = new List<List<String>>();
        Quote q = [SELECT Id, AccountId,Account_CSN__c,Account.Name, Order_Type__c FROM Quote where Id =: quoteId limit 1];
        list<Relationship__c> rel = [Select Id,Secondary_Account__r.Name from Relationship__c where Primary_Account__c =: q.AccountId];
        for(Relationship__c r : rel){
            pickList.add(r.Secondary_Account__r.Name);
        }
        for(integer i = 0 ; i < rel.size() ; i++){
            allPickList.add(pickList);
        }
        stw.allPickList = allPickList;
        stw.firstPickList = q.Account_CSN__c+'-'+q.Account.Name;
        return stw;
    }
    @AuraEnabled
    public static ProductWrapper getProductInfo(string quoteId) {
        Set<Id> productIds = new Set<Id>();
        for(Quote_Line__c q : getQuoteLinesCtrls(quoteId)){
            productIds.add(q.Product__c);
        }
        Quote quote = [SELECT Id,GPO_Price_Lists__c	,IDN_Price_List__c from Quote where Id =: quoteId];
        Map<Id,Decimal> productProceMap = new Map<Id,Decimal>();
        if(quote.GPO_Price_Lists__c != null && quote.IDN_Price_List__c == null){
            for(Catalog_GPO_Price__c c : [SELECT Id,Distribution_Channel__c,GPO_Price__c,Product__c from Catalog_GPO_Price__c]){
                productProceMap.put(c.Product__c,c.GPO_Price__c);
            }
        }
        else if(quote.IDN_Price_List__c != null && quote.GPO_Price_Lists__c == null){
            for(Catalog_IDN_Price__c c : [SELECT Id,Distribution_Channel__c,IDN_Price__c,Products__c from Catalog_IDN_Price__c]){
                productProceMap.put(c.Products__c,c.IDN_Price__c);
            }
        }
        else if(quote.IDN_Price_List__c != null && quote.GPO_Price_Lists__c != null){
            for(Catalog_IDN_Price__c c : [SELECT Id,Distribution_Channel__c,IDN_Price__c,Products__c from Catalog_IDN_Price__c]){
                productProceMap.put(c.Products__c,c.IDN_Price__c);
            }
        }
        else{
            for(Catalog_USA_Price__c c : [SELECT Id,Distribution_Channel__c,USA_List_price__c,Product__c from Catalog_USA_Price__c]){
                productProceMap.put(c.Product__c,c.USA_List_price__c);
            }
        }
        Decimal prodPrice ;
        ProductWrapper pw = new ProductWrapper();
        pw.lstPrd = new List<ProductLineItemWrapper>();
        pw.allLstPrd = new List<ProductLineItemWrapper>();
        for(Product2 productItem : [SELECT id,ProductCode,Description,sales_text__c,DW_Product_Line__c,Product_Type__c FROM Product2 WHERE Product_Type__c != null AND (NOT ProductCode LIKE '%-SV')])
        {
            if(productItem.Product_Type__c == 'Option'){
                prodPrice = productProceMap.get(productItem.Id) != null ? productProceMap.get(productItem.Id) : 0.0;
                pw.lstPrd.add(new ProductLineItemWrapper(productItem,prodPrice));
            }
            if(productItem.Product_Type__c == 'Option' || 
               productItem.Product_Type__c == 'Std Config Self Install' || 
               productItem.Product_Type__c == 'Std Config Omnicell Install'){
                   prodPrice = productProceMap.get(productItem.Id) != null ? productProceMap.get(productItem.Id) : 0.0;
                   pw.allLstPrd.add(new ProductLineItemWrapper(productItem,prodPrice)) ;
               }
        }
        
        List<Product2> mpr = new List<Product2>();
        List<ProductLineItemWrapper> mproductLineItemList = new List<ProductLineItemWrapper>();
        Map<String,List<ProductLineItemWrapper>> mproductLineItemMap = new Map<String,List<ProductLineItemWrapper>>();
        
        mpr = [Select id,ProductCode,Description,sales_text__c,DW_Product_Line__c,Product_Type__c,DW_Product_Type__c FROM Product2 WHERE Product_Type__c != null  AND (NOT ProductCode LIKE '%-SV') ORDER BY DW_Product_Line__c ASC  /*AND DW_Product_Line__c IN:pLineSet*/];
        system.debug('mpr-- '+mpr.size());
        for(Product2 productItem : mpr)
        {
            prodPrice = productProceMap.get(productItem.Id) != null ? productProceMap.get(productItem.Id) : 0.0;
            
            if(productItem.DW_Product_Line__c!=null){
                
                if(!mproductLineItemMap.containskey(productItem.DW_Product_Line__c)){
                    
                    if(productItem.DW_Product_Line__c == 'Automated Dispensing Cabinets'  )
                    {
                        if(productItem.DW_Product_Type__c == 'Frame' &&( productItem.ProductCode.containsIgnoreCase('MED') ||  productItem.ProductCode.containsIgnoreCase('ANT')) && productItem.Product_Type__c == 'Std Config Omnicell Install')
                        {
                            mproductLineItemMap.put(productItem.DW_Product_Line__c, new list<ProductLineItemWrapper>());
                        }
                        else
                        {
                            //Nothing
                        }
                    }else
                    {
                        mproductLineItemMap.put(productItem.DW_Product_Line__c, new list<ProductLineItemWrapper>());
                    }
                }
                
                if(productItem.DW_Product_Line__c == 'Automated Dispensing Cabinets'  )
                {
                    if(productItem.DW_Product_Type__c == 'Frame' && ( productItem.ProductCode.containsIgnoreCase('MED') ||  productItem.ProductCode.containsIgnoreCase('ANT'))&& productItem.Product_Type__c == 'Std Config Omnicell Install')
                    {
                        system.debug('Product1   '+productItem.Productcode+'    '+productItem.DW_Product_Type__c);
                        
                        mproductLineItemMap.get(productItem.DW_Product_Line__c).add(new ProductLineItemWrapper(productItem,prodPrice));
                    }
                    else
                    {
                        //Nothing
                    }
                }else{
                    mproductLineItemMap.get(productItem.DW_Product_Line__c).add(new ProductLineItemWrapper(productItem,prodPrice));
                }
            }
        }
        pw.medPrd = mproductLineItemMap;
        //system.debug('pw-- '+JSON.serialize(pw));
        return pw;
    }
	
    @AuraEnabled
    public static ProductWrapper searchProducts(string quoteId , string searchText) {
        Set<Id> productIds = new Set<Id>();
        for(Quote_Line__c q : getQuoteLinesCtrls(quoteId)){
            productIds.add(q.Product__c);
        }
        Quote quote = [SELECT Id,GPO_Price_Lists__c	,IDN_Price_List__c from Quote where Id =: quoteId];
        Map<Id,Decimal> productProceMap = new Map<Id,Decimal>();
        if(quote.GPO_Price_Lists__c != null && quote.IDN_Price_List__c == null){
            for(Catalog_GPO_Price__c c : [SELECT Id,Distribution_Channel__c,GPO_Price__c,Product__c from Catalog_GPO_Price__c]){
                productProceMap.put(c.Product__c,c.GPO_Price__c);
            }
        }
        else if(quote.IDN_Price_List__c != null && quote.GPO_Price_Lists__c == null){
            for(Catalog_IDN_Price__c c : [SELECT Id,Distribution_Channel__c,IDN_Price__c,Products__c from Catalog_IDN_Price__c]){
                productProceMap.put(c.Products__c,c.IDN_Price__c);
            }
        }
        else if(quote.IDN_Price_List__c != null && quote.GPO_Price_Lists__c != null){
            for(Catalog_IDN_Price__c c : [SELECT Id,Distribution_Channel__c,IDN_Price__c,Products__c from Catalog_IDN_Price__c]){
                productProceMap.put(c.Products__c,c.IDN_Price__c);
            }
        }
        else{
            for(Catalog_USA_Price__c c : [SELECT Id,Distribution_Channel__c,USA_List_price__c,Product__c from Catalog_USA_Price__c]){
                productProceMap.put(c.Product__c,c.USA_List_price__c);
            }
        }
        Decimal prodPrice ;
        List<ProductLineItemWrapper> sproductLineItemList = new List<ProductLineItemWrapper>();
        ProductWrapper pw = new ProductWrapper();
        pw.lstPrd = new List<ProductLineItemWrapper>();
        pw.allLstPrd = new List<ProductLineItemWrapper>();
        if(searchText != null)
        {
            String pCode = '%'+searchText + '%';
            //searchpr = [Select id,ProductCode,Description,sales_text__c,DW_Product_Line__c  from Product2 where ProductCode LIKE : pCode AND Product_Type__c != null];
            for(Product2 productItem : [Select id,ProductCode,Description,sales_text__c,DW_Product_Line__c  from Product2 where (ProductCode LIKE : pCode OR Description LIKE : pCode) AND Product_Type__c != null AND (NOT ProductCode LIKE '%-SV')])
            {
                prodPrice = productProceMap.get(productItem.Id) != null ? productProceMap.get(productItem.Id) : 0.0;
                sproductLineItemList.add(new ProductLineItemWrapper(productItem,prodPrice)) ;
            }
            pw.searchLstPrd = sproductLineItemList;
        }
        return pw;
    }
    
    public class ProductLineItemWrapper {
        @AuraEnabled public Product2 productItem;
        @AuraEnabled public Integer quantity;
        @AuraEnabled public String parLocation;
        @AuraEnabled public Boolean isSelected = false;
        @AuraEnabled public String salesText = '';
        @AuraEnabled public Decimal priceList;
        public ProductLineItemWrapper(Product2 productItemAttribute, Decimal prodPrice)
        {
            productItem = productItemAttribute;
            if(productItem.ProductCode != 'MED-FRM-101-1')
            { 
              salesText = 'Solution Includes:<br>'+
                                                    '* XT MED 1-CELL CABINET<br>'+
                                                    '* XT MED 27-BIN METAL LOCKING LID DRW (2)<br>'+
                                                    '* XT MED 18-BIN METAL LOCKING LID DRW (2)<br>'+
                                                    '* XT MED 10-BIN METAL LOCKING LID DRW (1)<br>'+
                                                    '* XT MED 15-BIN DBL DEEP METAL LOCKING DRW (1)<br>'+
                                                    '* XT SCANNER, WIRED (1,2,3 CELL)<br>'+
                                                    '* SW LICENSE-SCHEDULED MEDS<br>'+
                                                    '* SW LICENSE-PROFILE OPTION<br>'+
                                                    '* XT CONSOLE-BIOID, MED LBL  RCPT PRNTR<br>'+
                                                    '* PREMIUM WIN10 PACKAGE ';
            }
            else
            {
             salesText = 'Solution Includes:<br>'+
                                                     '* XT MED 1-CELL CABINET<br>'+
                                                    '* XT MED 27-BIN METAL LOCKING LID DRW (1)<br>'+
                                                    '* XT MED 18-BIN METAL LOCKING LID DRW (1)<br>'+
                                                    '* XT MED 10-BIN METAL LOCKING LID DRW (1)<br>'+
                                                    '* XT MED 15-BIN DBL DEEP METAL LOCKING DRW (1)<br>'+
                                                    '* XT SCANNER, WIRED (1,2,3 CELL)<br>'+
                                                    '* SW LICENSE-SCHEDULED MEDS<br>'+
                                                    '* SW LICENSE-PROFILE OPTION<br>'+
                                                    '* XT CONSOLE-BIOID, MED LBL  RCPT PRNTR<br>'+
                                                    '* PREMIUM WIN10 PACKAGE ';
            }
            quantity = 1;
            priceList = prodPrice;
        }
    }
   
    public class ProductWrapper {        
        @AuraEnabled public List<ProductLineItemWrapper> lstPrd;
        @AuraEnabled public List<ProductLineItemWrapper> allLstPrd;
        @AuraEnabled public List<ProductLineItemWrapper> searchLstPrd;
        @AuraEnabled public Map<String,List<ProductLineItemWrapper>> medPrd;
    }
    
    public class QuoteLineWrapper {
        @AuraEnabled public Quote_Line__c quoteline;
        @AuraEnabled public Boolean isSelectedQuote = false;
    } 
    public class QuoteLineWrapperClass {        
        @AuraEnabled public List<QuoteLineWrapper> lstQuoteLine;
    }
    public static QuoteLineWrapperClass quoteDetails(List<Quote_Line__c> ql){
        List<QuoteLineWrapper> qlList = new List<QuoteLineWrapper>();
        for(Quote_Line__c q : ql){
            QuoteLineWrapper qlw = new QuoteLineWrapper();
            qlw.quoteline = q;
            qlw.isSelectedQuote = false;
            qlList.add(qlw);
        }
        QuoteLineWrapperClass wc = new QuoteLineWrapperClass();
        wc.lstQuoteLine = qlList;
        return wc;
    }    
    @AuraEnabled
    public static QuoteLineWrapperClass updateQuoteLinesCtrl(string quoteId , String quoteLineWrapperList){
        system.debug('quoteLineWrapperList-- '+quoteLineWrapperList);
        QuoteLineWrapperClass obj = (QuoteLineWrapperClass)JSON.deserialize(quoteLineWrapperList, QuoteLineWrapperClass.class);  
        List<Quote_Line__c> quoteLineList = new List<Quote_Line__c>();
        for(QuoteLineWrapper q : obj.lstQuoteLine){
            system.debug('quote-- '+JSON.serialize(q));
            if(q.isSelectedQuote == true){
                q.quoteline.Interim_Flag__c = true;
                quoteLineList.add(q.quoteline);
            }
        }
        system.debug('quoteLineList-- '+quoteLineList.size());
        if(quoteLineList.size() > 0)
        	Database.update(quoteLineList);
        return quoteDetails([SELECT Id, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c,Serial_Number__c  FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]);
    }
    @AuraEnabled
    public static QuoteLineWrapperClass getQuoteLinesCtrl(string quoteId){
        return quoteDetails([SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]);
    }
    public static List<Quote_Line__c> getQuoteLinesCtrls(string quoteId){
        return [SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId /*AND Higher_Level_Item__c = 0*/];
    }
    @AuraEnabled 
    public static List<String> getParLocationCtrl(string quoteId){
        List<String> parList = new List<String>();
        Set<String> parSet = new Set<String>();
        for(Quote_Line__c q : [SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId AND Par_Location__c != null]){
            parSet.add(q.Par_Location__c);
        }
        if(parSet.size() > 0)
            parList.addAll(parSet);
        return parList;
    }
    @AuraEnabled 
    public static List<String> getProductPicklistCtrl(string quoteId){
        List<String> parList = new List<String>();
        Set<String> parSet = new Set<String>();
        for(Quote_Line__c q : [SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product_Code__c != null AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]){
            parSet.add(q.Product_Code__c);
        }
        if(parSet.size() > 0)
            parList.addAll(parSet);
        return parList;
    }
	@AuraEnabled
    public static QuoteLineWrapperClass getQuoteLinesCtrlPar(string quoteId,String par){
        List<Quote_Line__c> qLineList = [SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId  AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Par_Location__c =: par AND Add_to_cart__c =true];
        if(qLineList.size() == 0){
            qLineList = [SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c  FROM Quote_Line__c WHERE Quote__c =: quoteId  AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true];
        }
        return quoteDetails(qLineList);
    }
    @AuraEnabled
    public static QuoteLineWrapperClass getQuoteLinesCtrlProd(string quoteId,String prod){
        return quoteDetails([SELECT Id,Product__c, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Product_Code__c =: prod AND Add_to_cart__c =true]);
    }
    @AuraEnabled
    public static QuoteLineWrapperClass deleteQuoteLinesCtrl(string quoteId , String quoteLineWrapperList){
        system.debug('quoteLineWrapperList-- '+quoteLineWrapperList);
        QuoteLineWrapperClass obj = (QuoteLineWrapperClass)JSON.deserialize(quoteLineWrapperList, QuoteLineWrapperClass.class);  
        List<Quote_Line__c> quoteLineList = new List<Quote_Line__c>();
        for(QuoteLineWrapper q : obj.lstQuoteLine){
            system.debug('quote-- '+JSON.serialize(q));
            if(q.isSelectedQuote == true){
                System.debug('***'+q.quoteline);
                quoteLineList.add(q.quoteline);
            }
        }
        system.debug('quoteLineList-- '+quoteLineList.size());
        if(quoteLineList.size() > 0)
        	Database.delete(quoteLineList);
        return quoteDetails([SELECT Id, Quantity__c, Name,Product_Code__c,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c,Serial_Number__c  FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]);
    }
	@AuraEnabled
    public static QuoteLineWrapperClass copyQuoteLines(String copyQuoteId , string quoteId){
        List<Quote_Line__c> newQuoteLines = new List<Quote_Line__c>();
        for(Quote_Line__c q : [SELECT Id, Quantity__c, Name,Product_Code__c,Quote__c,Product__r.Id,Par_Location__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: copyQuoteId]){
            newQuoteLines.add(createQuoteLineRecord(quoteId,q.Product__r.Id,Integer.valueOf(q.Quantity__c),q.Par_Location__c));
        }
        return quoteDetails([SELECT Id, Quantity__c, Name,Product_Code__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c,Serial_Number__c  FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]);
    }
    @AuraEnabled
    public static QuoteLineWrapperClass createQuoteLinesLookup(String product,string quoteId, String parName) {
        createQuoteLineRecord(quoteId,product,1,parName);
        return quoteDetails([SELECT Id, Quantity__c, Name,Product_Code__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c  FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]);
    }
    
    
    @AuraEnabled
    public static QuoteLineWrapperClass createQuoteLinesForAllParA(List<Quote_Line__c> selectedProducts, string quoteId) {
        list<String> parList = new list<String>();
        for(QuoteParMap__c q : [SELECT Id,Name,Par__c,Quote__c,Quote__r.Quote_Number__c FROM QuoteParMap__c WHERE Quote__c = :quoteId]){
            parList.add(q.Par__c);
        }
        List<Quote_Line__c> quoteLinesToUpdate = new List<Quote_Line__c>();
        List<Quote_Line__c> quoteLinesToAdd = new List<Quote_Line__c>();
        List<Quote_Line__c> freightQuoteLines = [Select id,Product__r.productcode,Serial_Number__c from Quote_Line__c 
                                                 where Quote__c =: quoteId and Product__r.productcode = 'FREIGHT'];
        Map<string,Quote_Line__c> quoteLineMap = new Map<string,Quote_Line__c>();
        if (freightQuoteLines.size() == 0) 
        {
            quoteLinesToAdd.add(createFreightLineRecord(quoteId));
        }
        for(Quote_Line__c q : [SELECT Id, Quantity__c, Name,Product_Code__c,Conga_Unit_Price__c,Conga_Extended_Price__c,
                               Product__c, Par_Location__c,Serial_Number__c  FROM Quote_Line__c WHERE Quote__c =: quoteId]){
                                   quoteLineMap.put(q.Par_Location__c + q.Product__c, q);
                               }
        for(Quote_Line__c qline : selectedProducts)
        {
            system.debug('product Id-- '+qline.Product__c);
            for(String parName : parlist){
                if(quoteLineMap.get(parName + qline.Product__c) != null){
                    Quote_Line__c q  = quoteLineMap.get(parName + qline.Product__c);
                    Decimal qty = qline.Quantity__c + q.Quantity__c;
                    Quote_Line__c quoteLineForUpdate = createQuoteLineRecord(quoteId, qline.Product__c, qty, parName);
                    quoteLineForUpdate.Id = q.Id;
                    quoteLinesToUpdate.add(quoteLineForUpdate);
                }
                else{
                    Quote_Line__c quoteLineForInsert = createQuoteLineRecord(quoteId, qline.Product__c, qline.Quantity__c, parName);
                    quoteLinesToAdd.add(quoteLineForInsert);
                }
            }
        }     
        system.debug('quoteLinesToAdd.size()--- '+quoteLinesToAdd.size());   
        system.debug('quoteLinesToUpdate.size()--- '+quoteLinesToUpdate.size()); 
        try{
            if(quoteLinesToAdd.size() > 0)
                insert quoteLinesToAdd;
            if(quoteLinesToUpdate.size() > 0)
                update quoteLinesToUpdate;
        }catch(DMLException ex){
            system.debug('Exception--'+ex.getDmlMessage(0));
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return quoteDetails([SELECT Id, Quantity__c, Name,Product_Code__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c  FROM Quote_Line__c WHERE Quote__c =: quoteId AND Product__r.ProductCode != 'FREIGHT' AND (Higher_Level_Item__c = null OR Higher_Level_Item__c = 0) AND Add_to_cart__c =true]);
    }
    @AuraEnabled
    public static QuoteLineWrapperClass createQuoteLinesA(List<Quote_Line__c> selectedProducts, string quoteId,String parName) {
       system.debug('selectedProducts-- '+selectedProducts);
       List<Quote_Line__c> quoteLinesToUpdate = new List<Quote_Line__c>();
       List<Quote_Line__c> quoteLinesToAdd = new List<Quote_Line__c>();
       Map<string,Quote_Line__c> quoteLineMap = new Map<string,Quote_Line__c>();
       List<Quote_Line__c> freightQuoteLines = [Select id,Product__r.productcode,Serial_Number__c from Quote_Line__c 
                                                where Quote__c =: quoteId and Product__r.productcode = 'FREIGHT'];
       if (freightQuoteLines.size() == 0) 
       {
           quoteLinesToAdd.add(createFreightLineRecord(quoteId));
       }
        for(Quote_Line__c q : [SELECT Id, Quantity__c, Name,Product_Code__c,Conga_Unit_Price__c,Conga_Extended_Price__c,
                               Product__c, Par_Location__c,Serial_Number__c FROM Quote_Line__c WHERE Quote__c =: quoteId]){
            quoteLineMap.put(q.Par_Location__c + q.Product__c, q);
        }
        system.debug('selectedProducts---size--'+selectedProducts.size());
       //for(ProductLineItemWrapper productLineWrapper : productLineItemList)
        for(Quote_Line__c qline : selectedProducts)
        {
            system.debug('selected qline--'+qline);
            
            if(quoteLineMap.get(parName + qline.Product__c) != null){
                Quote_Line__c q  = quoteLineMap.get(parName + qline.Product__c);
                Decimal qty = qline.Quantity__c + q.Quantity__c;
                Quote_Line__c quoteLineForUpdate = createQuoteLineRecord(quoteId,qline.Product__c,qty,parName);
                quoteLineForUpdate.Id = q.Id;
                quoteLinesToUpdate.add(quoteLineForUpdate);
            }
            else{
                quoteLinesToAdd.add(createQuoteLineRecord(quoteId,qline.Product__c,qline.Quantity__c,parName));
            }
        }    
        system.debug('quoteLinesToAdd--'+quoteLinesToAdd);
        system.debug('quoteLinesToUpdate--'+quoteLinesToUpdate);
        try{
            if(quoteLinesToAdd.size() > 0)
                insert quoteLinesToAdd;
            if(quoteLinesToUpdate.size() > 0)
                update quoteLinesToUpdate;
        }catch(DMLException ex){
            system.debug('Exception--'+ex.getDmlMessage(0));
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        return quoteDetails([SELECT Id, Quantity__c, Name,Product_Code__c,Conga_Unit_Price__c,Conga_Extended_Price__c,Product__c,Serial_Number__c  FROM Quote_Line__c WHERE Quote__c =: quoteId /*AND Higher_Level_Item__c = 0*/]);
    }
     @AuraEnabled
    public static Quote_Line__c createQuoteLineRecord(String qid, String productId, Decimal Quantity, String parLocation) {
        //IBA-2614
        Product2 pr = [Select id,DW_Product_Line__c,Product_Type__c,ProductCode, DW_Product_Type__c,QuantityUnitOfMeasure from Product2 where Id =: productId];
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = '0121N000001M5AGQA0';
        ql.Quote__c = qid;
        ql.Product__c = productId;
        ql.Quantity__c = Quantity;
       	//IBA-2614
        /*if((pr.DW_Product_Line__c =='XR2 System' && pr.Product_Type__c =='Option') || (pr.DW_Product_Type__c == 'Subscription' && pr.product_type__c == 'Option'))
            ql.Unit_of_Measure__c = 'AU';
        else
        	ql.Unit_of_Measure__c = 'EA';*/
        //end IBA-2614
        ql.Unit_of_Measure__c = pr.QuantityUnitOfMeasure; //IBA-2814
        ql.Par_Location__c = parLocation;
        ql.Add_to_cart__c = true;
        ql.Interim_flag__c = true;
        //ql.SAP_Line_Item_GUID__c = generateRamdonNumber();
        //insert ql;
        return ql;
    }
    
    @AuraEnabled
    public static Quote_Line__c createFreightLineRecord(String qid) {
        Quote_Line__c quoteLine = new Quote_Line__c();
        Product2 pr1 = [Select id,ProductCode,Description,QuantityUnitOfMeasure from Product2 where ProductCode = 'FREIGHT'];
        //quoteLine.RecordTypeId = '0121N000001M5AGQA0';
        quoteLine.RecordTypeId = '0121N000001M5AGQA0';
        quoteLine.Quote__c = qid;
        quoteLine.Product__c = pr1.id;
        quoteLine.Quantity__c = 1;
        quoteLine.Unit_of_Measure__c = pr1.QuantityUnitOfMeasure; //IBA-2814
        //quoteLine.SAP_Line_Number__c = 100;
        quoteLine.SAP_Line_Number__c = 300;
        quoteLine.Line_Status__c='E0001';
        //quoteLine.External_Config__c=true;
        quoteline.Add_to_cart__c = True;
        quoteline.Interim_flag__c = True;
        //quoteLine.SAP_Line_Item_GUID__c = generateRamdonNumber();
        return quoteLine;
    }
     
    @AuraEnabled
    public static void createQuoteLine(string qid, String prd, String qty) {
        Product2 pr = [Select id,DW_Product_Line__c,Product_Type__c,ProductCode,Description, DW_Product_Type__c,QuantityUnitOfMeasure from Product2 where ProductCode =: prd];
        Product2 pr1 = [Select id,ProductCode,Description from Product2 where ProductCode = 'FREIGHT'];
        String quan = qty;
        Integer Quantity = Integer.ValueOf(quan);
        
        System.debug('rj.......' +qid +prd +qty);
        Quote_Line__C ql = new Quote_Line__c();
        ql.RecordTypeId = '0121N000001M5AGQA0';
        ql.Quote__c = qid;
        ql.Product__c = pr.id;
        ql.Quantity__c = 1;
        //IBA-2614
        /*if((pr.DW_Product_Line__c =='XR2 System' && pr.Product_Type__c =='Option') || (pr.DW_Product_Type__c == 'Subscription' && pr.product_type__c == 'Option'))
            ql.Unit_of_Measure__c = 'AU';
        else
        	ql.Unit_of_Measure__c = 'EA';*/
        //end IBA-2614
        //ql.SAP_Line_Item_GUID__c = generateRamdonNumber();
        ql.Unit_of_Measure__c = pr.QuantityUnitOfMeasure; //IBA-2814
        System.debug('ql....' +ql);
        insert ql;           
    }
    
    @AuraEnabled
    public static Assetwrapper getAssetsInfo(String quoteId)
    {
        Quote qte = new Quote();
        List<C4C_Assets__c> c4cassets = new List<C4C_Assets__c>();
        if(!String.isEmpty(quoteId))
        {
        	qte = [SELECT Id, AccountId, Order_Type__c FROM Quote where Id =: quoteId  ];
        }
        Set<Id> productIds = new Set<Id>();
        for(Quote_Line__c q : getQuoteLinesCtrls(quoteId)){
            productIds.add(q.Product__c);
        }
        c4cassets = [SELECT  Id, Name , Ship_To_Name__c , Product_ID__c , Description__c , Status__c , Serial_ID__c,Product__c  FROM C4C_Assets__c 
                     where Account__c  = :qte.AccountId AND Product__c NOT IN :productIds];
        system.debug('c4cassets---'+c4cassets);
        return new Assetwrapper(qte, c4cassets);
    }
    @AuraEnabled
    public static list<Quote_Line__c> createQLineForc4c(list<Quote_Line__c> newQuoteLines)
    {
        system.debug('newQuoteLines--'+newQuoteLines);
        if(!newQuoteLines.isEmpty())
        {
            insert newQuoteLines;
        }
        return newQuoteLines;
    }
    public class ShipToWrapper{
        @AuraEnabled public List<List<String>> allPickList;
        @AuraEnabled public String firstPickList;
    }
    public class Assetwrapper{
        @AuraEnabled public quote qte;
        @AuraEnabled public List<C4C_Assets__c> c4cAsset;
        public Assetwrapper(Quote qte, List<C4C_Assets__c> c4cAsset){
            this.qte = qte;
            this.c4cAsset = c4cAsset;
        }
    }
    
    @AuraEnabled
    public static boolean getQuoteDetails(String quoteId){
        Quote q = [SELECT Id,Order_Type__c,Quote_Number__c,SAP_Quote_Number_Truncated__c from Quote where Id =: quoteId];
        //if(q.Order_Type__c != 'ZQRS'){
        if(String.isNotBlank(q.SAP_Quote_Number_Truncated__c)){
            return true;
        }
        else{
            return false;
        }
    }
    
    //IBA-1768 New Logic Added
    @AuraEnabled
    public static Boolean checkErrorMesssage(List<Quote_Line__c> selectedProducts, string quoteId) {
        Quote q = [Select id,Order_Type__c from Quote where id =: quoteId];
        List<String> prdIds = new List<String>();
        Boolean showErrorMsg = false;
        //IBA-2614
        if(q.Order_Type__c == 'ZQRL' || q.Order_Type__c == 'ZQLI' || q.Order_Type__c == 'ZQR3' || q.Order_Type__c == 'ZQL3' || q.Order_Type__c == 'ZQRS' ) {
            for(Quote_Line__C ql: selectedProducts) {
                prdIds.add(ql.Product__c);
            }
            //IBA-2614	
            List<Product2> prdList = [Select id,Product_Type__c,ProductCode from Product2 where id IN: prdIds];
            if(prdIds.size()>0) {
                for(Product2 prd: prdList) {
                    //IBA-2614
                    if(q.Order_Type__c!='ZQR' && q.Order_Type__c!='ZQRS' && (prd.Product_Type__c == 'Std Config Omnicell Install' || prd.Product_Type__c == 'Option')) {//IBA-3242
                        showErrorMsg = true;
                    	break;
                    }
                }
            }
        }else {
            showErrorMsg = false;
        }
        return showErrorMsg;
    }
   	//IBA-2126 Start
    @AuraEnabled
    public static List<string> pullImageDetails (List<Quote_Line__c> selectedProducts, string quoteId) {
        Quote q = [Select id,Order_Type__c from Quote where id =: quoteId];
        List<String> PrdIds = New List<String>();
        List<string> PrdName = New List<String>();
        List<string> imgIds = New List<String>();
        for(Quote_line__c ql: selectedProducts) {
            prdIds.add(ql.Product__c);
            System.debug('Products:' +prdIds);
        }
        List<Product2> prdList = [Select id,Name,DisplayUrl from Product2 where id IN: prdIds];
        for(Product2 p: prdList) {
            PrdName.add(p.DisplayUrl);
            System.debug('Product Name:' +PrdName);
        }
        return PrdName;
    }
	@AuraEnabled
    public static Integer previewImageError (List<Quote_Line__c> selectedProducts, string quoteId) {
        Quote q = [Select id,Order_Type__c from Quote where id =: quoteId];
        List<String> PrdIds = New List<String>();
        List<string> PrdUrl = New List<String>();
        List<string> PrdType = New List<String>();
        Integer ShowErrMsg = 0;
        for(Quote_line__c ql: selectedProducts) {
            prdIds.add(ql.Product__c);
            System.debug('Products:' +prdIds);
        }
        if(PrdIds.size()!= 1){
            ShowErrMsg = 1;
            return showErrMsg;
        }
        List<Product2> prdList = [Select id,Name,DisplayUrl, Product_Type__c from Product2 where id IN: prdIds];
        for(product2 p: prdList) {
            if(p.DisplayUrl != null && p.Product_Type__c == 'Std Config Omnicell Install'){
                ShowErrMsg = 0;
            }else{
                ShowErrMsg = 2;
                
            }
        }
        //system.debug('showErrMsg:' +showErrMsg);
        return showErrMsg;
    }
    //IBA-2126 End
    /*
    @AuraEnabled
    Public static Boolean validateQuoteSync(String quoteId){
        String message = '';
        try{
            Quote quot = [select id, name, Quote_Number__c from Quote where ID =:quoteId];
            
            string quotenumber = quot.Quote_Number__c;
            Map<String, Object> jsondata = new Map<String, Object> {'Quote_Number__c' => quotenumber};
            String jsonstrinsert = JSON.serialize(jsondata);
            final string comp_creds = 'CastIronIntegration';
            
            CastIronIntegration__c compCreds = CastIronIntegration__c.getInstance(comp_creds);
            //Compare_Integration_Creds__c compCreds = Compare_Integration_Creds__c.getInstance(comp_creds);
            system.debug(comp_creds+'@@@comp_creds'+compCreds +'@@@Compare_Integration_Creds__c');
            
            String EndPoint1 = compCreds.Print_Compare_End_Point__c;
            //Integer timeout = Integer.valueOf(compCreds.Timeout__c);
            Integer timeout = 120000;
            Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT id,Interim_flag__c FROM Quote_Line__c WHERE Quote__r.Id =: quoteId]);
            Boolean isInterimed = false;
            for(Quote_Line__c ql: qline.values()){
                isInterimed = ql.Interim_flag__c || isInterimed;
            }
            double sfdcQuotelinecount = qline.size();
            if(sfdcQuotelinecount > 0){
                Http h2= new Http();
                HttpRequest req2= new HttpRequest();
                req2.setHeader('Content-Type','application/json');
                req2.setHeader('accept','application/json');
                system.debug('sending json for creating quote line: ' + jsonstrinsert); 
                req2.setBody(jsonstrinsert);
                req2.setMethod('POST');
                req2.setEndpoint(EndPoint1);
                req2.setTimeout(timeout); 
                HttpResponse res2=h2.send(req2);
                System.debug(res2+'###123createresp');
                system.debug('res2.getBody()..'+res2.getBody().replace('[',''));
                String resbody = res2.getBody().replace('[','');
                QuotePrintCompare.QuotePrintCompareJsonDes frmjson = new QuotePrintCompare.QuotePrintCompareJsonDes();
                frmjson = (QuotePrintCompare.QuotePrintCompareJsonDes)System.JSON.deserialize(resbody.replace(']',''), QuotePrintCompare.QuotePrintCompareJsonDes.class);
                Double sapcount = frmjson.ItemCount;
                String sapRevNum;
                if(frmjson.RevisionNo != null){
                    sapRevNum = (frmjson.RevisionNo).replace(' ','');
                }
                
                System.debug('sapcount : '+sapcount);
                System.debug('sapRevnum : '+sapRevNum);
                System.debug('Sfdccount : '+sfdcQuotelinecount);
                
                Integer sapQuoteLinecount = 0;
				Quote qu = [select id, name, Quote_Number__c,Quote_Revision__c  from Quote where ID =:quoteId];
                
                System.debug('sfdc Quote rev num : '+qu.Quote_Revision__c);
                //System.debug('Revision num SAP : '+level1.get('RevisionNo')+'SFDC  :'+qu.Quote_Revision__c);
                if(qu.Quote_Revision__c == sapRevnum){
                    if(double.valueOf(sfdcQuotelinecount)==double.valueOf(sapcount)){
                        //No Action when Quote & Quote lines are sync
                        return true;
                    }
                    else if(sfdcQuotelinecount!=double.valueOf(sapcount)){
                        //message = 'Quote lines are not in sync from SAP, please wait';
                    }
                }
                else{
                   // message = 'Quote is being synced from SAP. Refresh the page to try "Add Products" after a few minutes.';
                }
            }
        }
        catch(Exception e){
            system.debug('Exception '+e.getStackTraceString());
            system.debug('Exception '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        if(String.isNotBlank(message)){
            throw new AuraHandledException(message);
        }
        return true;
    }
	*/
   /*public static String generateRamdonNumber(){
        Integer len = 5;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        return randomNumber;
    }*/
    //IBA-1845 Added new logic
    @AuraEnabled
    public static boolean compareRevisionNumber(String quoteId){ 
        Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT id FROM Quote_Line__c WHERE Quote__r.Id =: quoteId]);
        Quote q1 = [Select id,Quote_Revision__c from Quote where id =:quoteId ];
        double sfdcQuotelinecount = qline.size();
        Boolean isTrue = false;
        Quote_Print_Compare__c qpc = Quote_Print_Compare__c.getInstance('Do Revision Check');
        if(qpc.turn_off_revision_check__c == false && sfdcQuotelinecount > 0 && String.IsNotBlank(q1.Quote_Revision__c)){ 
            QuotePrintCompare.comparewrapper cmw = QuotePrintCompare.compareQuoteLine(quoteId);
            Quote q = [Select id, Quote_Number__c,Quote_Revision__c from Quote where id =:quoteId ];
            if(q.Quote_Revision__c == cmw.sapRev) {
                isTrue = true;   
            }
            else {
                isTrue = false;
            }
            
        } else {
             isTrue = true;   
        }
        return isTrue;
    }
 
}