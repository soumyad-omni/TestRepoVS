/***********************************************************************************************************
Name:  AccountQuoteLineItemType_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will go through all records of Quote_Line_Type__c object, deletes exisitng records
of Account_Quote_Line_Item_Type__c and roll up the values from Quote_Line_Type__c and create new records in Account_Quote_Line_Item_Type__c 
for an Account.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          7/08/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountQuoteLineItemType_Batch implements DataBase.Batchable<sObject>{
    global Date lastProductSoldDate;
    global AccountQuoteLineItemType_Batch(){        
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Amount__c,Cost__c,Date_Booked__c,Estimate__c,Opportunity__c,Opportunity__r.AccountId,Quote_Line_Item_Type__c,Quantity__c,Quote__c FROM Quote_Line_Type__c';
        List<Quote_Line_Type__c> quoteLineType = [select id, Date_Booked__c from Quote_Line_Type__c ORDER BY Date_Booked__c DESC limit 1];
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Quote_Line_Type__c> quoteLineTypeList){
        try{
            //Delete all existing records in Account_Quote_Line_Item_Type__c
            System.Debug('quoteLineTypeList Size:  '+quoteLineTypeList.size());
            System.Debug('quoteLineTypeList :  '+quoteLineTypeList);
            List<Account_Quote_Line_Item_Type__c> delAcctQuoteLineItemType = new List<Account_Quote_Line_Item_Type__c>();
            delAcctQuoteLineItemType = [select id,name from Account_Quote_Line_Item_Type__c where CreatedDate != TODAY];
            if(delAcctQuoteLineItemType.size()>0){
                delete delAcctQuoteLineItemType;
            }
            
            //Set<String> qLineTypeSet = new Set<String>();
            Map<Id,Set<String>> acctQLTypeSetMap = new Map<Id,Set<String>>();
            Map<Id,String> qltQLTypeMap = new Map<Id,String>();
            List<Account_Quote_Line_Item_Type__c> actQuoteLineItemTypeList = new List<Account_Quote_Line_Item_Type__c>();
            Set<ID> accountIds = new Set<ID>();
            Map<Id,List<Quote_Line_Type__c>> accountQtLineTypeMap = new Map<Id,List<Quote_Line_Type__c>>();
            
            Map<String,List<Quote_Line_Type__c>> qltQlineTypesMap = new Map<String,List<Quote_Line_Type__c>>();
            
            if(quoteLineTypeList.size()>0){
                for(Quote_Line_Type__c qlt : quoteLineTypeList){
                    lastProductSoldDate = qlt.Date_Booked__c;
                        //qLineTypeSet.add(qlt.Quote_Line_Item_Type__c);
                    
                    accountIds.add(qlt.Opportunity__r.AccountId);
                    
                    if(accountQtLineTypeMap.containsKey(qlt.Opportunity__r.AccountId)){
                        accountQtLineTypeMap.get(qlt.Opportunity__r.AccountId).add(qlt);
                    }else{
                        accountQtLineTypeMap.put(qlt.Opportunity__r.AccountId, new  List <Quote_Line_Type__c> { qlt });
                    }
                    
                    if(qltQlineTypesMap.containsKey(qlt.Quote_Line_Item_Type__c)){
                        qltQlineTypesMap.get(qlt.Quote_Line_Item_Type__c).add(qlt);
                    }else{
                        qltQlineTypesMap.put(qlt.Quote_Line_Item_Type__c, new List<Quote_Line_Type__c> {qlt});                                
                    }
                    
                    qltQLTypeMap.put(qlt.id,qlt.Quote_Line_Item_Type__c);
                    
                }
            }
            
            System.Debug('qltQlineTypesMap :- '+qltQlineTypesMap);
            if(accountIds.size()>0){
                for(Id acct : accountIds){
                    for(Quote_Line_Type__c qlt : accountQtLineTypeMap.get(acct)){
                        if(acctQLTypeSetMap.containsKey(acct)){
                            acctQLTypeSetMap.get(acct).add(qlt.Quote_Line_Item_Type__c);
                        }else{
                            acctQLTypeSetMap.put(acct, new Set<String> {qlt.Quote_Line_Item_Type__c});
                        }
                    }
                }
            }
            
            if(accountIds.size()>0){
                for(Id acctId : accountIds){
                        for(String qLineTy : acctQLTypeSetMap.get(acctId)){
                            ID account;
                            double amountBooked = 0;
                            double amountEstimated = 0;
                            String quoteLineType;
                            Date recentSoldDate; 
                            for(Quote_Line_Type__c qlt : accountQtLineTypeMap.get(acctId)){
                                System.Debug('Actual list === '+accountQtLineTypeMap.get(qlt.Opportunity__r.AccountId));
                                if(qltQlineTypesMap.containsKey(qlt.Quote_Line_Item_Type__c) && qlt.Quote_Line_Item_Type__c == qLineTy){
                                    System.Debug('qLineTy : '+qLineTy);
                                    if(qlt.Amount__c != null){
                                        System.Debug('ps.Amount__c : '+qlt.Amount__c);
                                        amountBooked = amountBooked + qlt.Amount__c;
                                    }
                                    
                                    if(qlt.Estimate__c && qlt.Amount__c != null){
                                        amountEstimated = amountEstimated + qlt.Amount__c;
                                    }
                                    quoteLineType = qltQLTypeMap.get(qlt.Id);//qLineTy;
                                    account = qlt.Opportunity__r.AccountId;
                                    System.Debug('account : '+account);
                                    
                                }
                                System.Debug('Rollup amount : '+amountBooked);                                
                            }
                            Account_Quote_Line_Item_Type__c actQuoteLineItemType = new Account_Quote_Line_Item_Type__c();
                            actQuoteLineItemType.Account__c = account;
                            actQuoteLineItemType.Amount_Booked__c = amountBooked;
                            actQuoteLineItemType.Amount_Estimated__c = amountEstimated;
                            System.Debug('lastProductSoldDate : '+lastProductSoldDate);
                            actQuoteLineItemType.Last_Product_Sold_Date__c = lastProductSoldDate;
                            actQuoteLineItemType.Quote_Line_Type__c = quoteLineType;
                            
                            actQuoteLineItemTypeList.add(actQuoteLineItemType);                                           
                        }
                }
            }
            System.debug('actQuoteLineItemTypeList size : '+actQuoteLineItemTypeList.size());
            System.debug('actQuoteLineItemTypeList : '+actQuoteLineItemTypeList);
            if(actQuoteLineItemTypeList.size()>0){
                insert actQuoteLineItemTypeList;
            }
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'AccountQuoteLineItemType_Batch','App');
        }
    }
    global void finish(DataBase.BatchableContext BC){
        //TO DO
    }
}