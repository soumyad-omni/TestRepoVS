/***********************************************************************************************************
Name:  AccountBusinessSegment_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will go through all records of Business_Segment__c object, deletes exisitng records
of Account_Business_Segment__c and roll up the values from Business_Segment__c and create new records in Account_Business_Segment__c 
for an Account

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          7/08/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountBusinessSegment_Batch implements DataBase.Batchable<sObject>{
    global Date lastProductSoldDate;
    global AccountBusinessSegment_Batch(){        
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Amount__c,Cost__c,Date_Booked__c,Estimate__c,Opportunity__c,Opportunity__r.AccountId,Business_Segment__c,Quantity__c,Quote__c FROM Business_Segment__c';
        List<Business_Segment__c> businessSeg = [select id, Date_Booked__c from Business_Segment__c ORDER BY Date_Booked__c DESC limit 1];
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Business_Segment__c> businessSegmentList){
        try{
            //Delete all existing records in Account_Business_Segment__c
            List<Account_Business_Segment__c> delAcctBusinessSegment = new List<Account_Business_Segment__c>();
            delAcctBusinessSegment = [select id,name from Account_Business_Segment__c where CreatedDate != TODAY ];
            if(delAcctBusinessSegment.size()>0){
                delete delAcctBusinessSegment;
            }
            
            //List<String> bSegList = new List<String>();
            Map<Id,Set<String>> acctBSegSetMap = new Map<Id,Set<String>>();
            Map<Id,String> busiSegBSMap = new Map<Id,String>();
            Map<String,List<Business_Segment__c>> bSegBusiSegmentsMap = new Map<String,List<Business_Segment__c>>();
            
            Set<ID> accountIds = new Set<ID>();
            Map<Id,List<Business_Segment__c>> accountBusiSegMap = new Map<Id,List<Business_Segment__c>>();
            
            List<Account_Business_Segment__c> actBusinessSgmtList = new List<Account_Business_Segment__c>();
            
            
            if(businessSegmentList.size()>0){
                for(Business_Segment__c bs : businessSegmentList){
                    lastProductSoldDate = bs.Date_Booked__c;
                    
                    accountIds.add(bs.Opportunity__r.AccountId);
                    
                    if(accountBusiSegMap.containsKey(bs.Opportunity__r.AccountId)){
                        accountBusiSegMap.get(bs.Opportunity__r.AccountId).add(bs);
                    }else{
                        accountBusiSegMap.put(bs.Opportunity__r.AccountId, new  List <Business_Segment__c> { bs });
                    }
                    
                    if(bSegBusiSegmentsMap.containsKey((bs.Business_Segment__c).toLowerCase())){
                        bSegBusiSegmentsMap.get((bs.Business_Segment__c).toLowerCase()).add(bs);
                    }else{
                        bSegBusiSegmentsMap.put((bs.Business_Segment__c).toLowerCase(), new List<Business_Segment__c> {bs});                                
                    }
                    
                    busiSegBSMap.put(bs.Id, bs.Business_Segment__c);
                    
                }
            }
            
            System.Debug('bSegBusiSegmentsMap :- '+bSegBusiSegmentsMap);
            if(accountIds.size()>0){
                for(Id acct : accountIds){
                    for(Business_Segment__c bs : accountBusiSegMap.get(acct)){
                        if(acctBSegSetMap.containsKey(acct)){
                            acctBSegSetMap.get(acct).add((bs.Business_Segment__c).toLowerCase());
                        }else{
                            acctBSegSetMap.put(acct, new Set<String> {(bs.Business_Segment__c).toLowerCase()});
                        }
                    }
                }
            }
            
            if(accountIds.size()>0){
                for(Id acctId : accountIds){
                    for(String bSeg : acctBSegSetMap.get(acctId)){
                        ID account;
                        double amountBooked = 0;
                        double amountEstimated = 0;
                        String businessSgmt;
                        Date recentSoldDate; 
                        for(Business_Segment__c bs : accountBusiSegMap.get(acctId)){
                            if(bSegBusiSegmentsMap.containsKey((bs.Business_Segment__c).toLowerCase()) && (bs.Business_Segment__c).toLowerCase() == bSeg){
                                System.Debug('bSeg : '+bSeg);
                                if(bs.Amount__c != null){
                                    System.Debug('ps.Amount__c : '+bs.Amount__c);
                                    amountBooked = amountBooked + bs.Amount__c;
                                }
                                
                                if(bs.Estimate__c && bs.Amount__c != null){
                                    amountEstimated = amountEstimated + bs.Amount__c;
                                }
                                businessSgmt = busiSegBSMap.get(bs.Id);
                                account = bs.Opportunity__r.AccountId;
                                System.Debug('account : '+account);
                            }
                        }
                        Account_Business_Segment__c actBussSeg = new Account_Business_Segment__c();
                        actBussSeg.Account__c = account;
                        actBussSeg.Amount_Booked__c = amountBooked;
                        actBussSeg.Amount_Estimated__c = amountEstimated;
                        System.Debug('lastProductSoldDate : '+lastProductSoldDate);
                        actBussSeg.Last_Product_Sold_Date__c = lastProductSoldDate;
                        actBussSeg.Business_Segment__c = businessSgmt;
                        
                        actBusinessSgmtList.add(actBussSeg);                                            
                    } 
                }
            }
            System.Debug('actBusinessSgmtList : '+actBusinessSgmtList);
            if(actBusinessSgmtList.size()>0){
                System.Debug('yes list has more records');
                insert actBusinessSgmtList;
            }
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'AccountBusinessSegment_Batch','App');
        }
    }
    global void finish(DataBase.BatchableContext BC){
        AccountQuoteLineItemType_Batch schedule = new AccountQuoteLineItemType_Batch();
        database.executeBatch(schedule, 100);
    }
}