/***********************************************************************************************************
Name:  AccountProductSegment_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will go through all records of Product_Segment__c object, deletes exisitng records
of Account_Product_Segment__c and roll up the values from Product_Segment__c and create new records in Account_Product_Segment__c
for an Account

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          7/08/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountProductSegment_Batch implements DataBase.Batchable<sObject>{
    global Date lastProductSoldDate;
    global AccountProductSegment_Batch(){        
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Amount__c,Cost__c,Date_Booked__c,Estimate__c,Opportunity__c,Opportunity__r.AccountId,Product_Segment__c,Quantity__c,Quote__c FROM Product_Segment__c';
        List<Product_Segment__c> prodSeg = [select id, Date_Booked__c from Product_Segment__c ORDER BY Date_Booked__c DESC limit 1];
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Product_Segment__c> prodSegmentList){
        try{
            //Delete all existing records in Account_Product_Segment__c
            System.debug('prodSegmentList size : '+prodSegmentList.size());
            System.Debug('prodSegmentList ==== '+prodSegmentList);
            List<Account_Product_Segment__c> delAcctProdSegment = new List<Account_Product_Segment__c>();
            delAcctProdSegment = [select id,name from Account_Product_Segment__c where CreatedDate != TODAY];
            System.Debug('delAcctProdSegment size : '+delAcctProdSegment.size());
            if(delAcctProdSegment.size()>0){
                delete delAcctProdSegment;
            }
            
            //List<String> pSegList = new List<String>();
            Map<Id,Set<String>> acctPSegSetMap = new Map<Id,Set<String>>();
            Map<Id,String> prodSegPSMap= new Map<Id,String>();
            Map<String,List<Product_Segment__c>> pSegProductSegmentsMap = new Map<String,List<Product_Segment__c>>();
               
            Set<ID> accountIds = new Set<ID>();
            Map<Id,List<Product_Segment__c>> accountProdSegMap = new Map<Id,List<Product_Segment__c>>();
            
            List<Account_Product_Segment__c> actProdSgmtList = new List<Account_Product_Segment__c>();
            
            if(prodSegmentList.size()>0){
                for(Product_Segment__c ps : prodSegmentList){
                    lastProductSoldDate = ps.Date_Booked__c;
                    
                    accountIds.add(ps.Opportunity__r.AccountId);
                    
                    if(accountProdSegMap.containsKey(ps.Opportunity__r.AccountId)){
                        accountProdSegMap.get(ps.Opportunity__r.AccountId).add(ps);
                    }else{
                        accountProdSegMap.put(ps.Opportunity__r.AccountId, new  List <Product_Segment__c> { ps });
                    }
                    
                    if(pSegProductSegmentsMap.containsKey((ps.Product_Segment__c).toLowerCase())){
                        pSegProductSegmentsMap.get((ps.Product_Segment__c).toLowerCase()).add(ps);
                    }else{
                        pSegProductSegmentsMap.put((ps.Product_Segment__c).toLowerCase(), new List<Product_Segment__c> {ps});                                
                    }
                    
                    prodSegPSMap.put(ps.Id, ps.Product_Segment__c);
                }
            }

            System.Debug('pSegProductSegmentsMap :- '+pSegProductSegmentsMap);
            if(accountIds.size()>0){
                for(Id acct : accountIds){
                    for(Product_Segment__c ps : accountProdSegMap.get(acct)){
                        if(acctPSegSetMap.containsKey(acct)){
                            acctPSegSetMap.get(acct).add((ps.Product_Segment__c).toLowerCase());
                        }else{
                            acctPSegSetMap.put(acct, new Set<String> {(ps.Product_Segment__c).toLowerCase()});
                        }
                    }
                }
            }
            
            if(accountIds.size()>0){
                for(Id acctId : accountIds){
                        for(String pSeg : acctPSegSetMap.get(acctId)){
                            ID account;
                            double amountBooked = 0;
                            double amountEstimated = 0;
                            String productSgmt;
                            Date recentSoldDate;
                            for(Product_Segment__c ps : accountProdSegMap.get(acctId)){
                                if(pSegProductSegmentsMap.containsKey((ps.Product_Segment__c).toLowerCase()) && (ps.Product_Segment__c).toLowerCase() == pSeg){
                                    System.Debug('pSeg : '+pSeg);
                                    if(ps.Amount__c != null){
                                        System.Debug('ps.Amount__c : '+ps.Amount__c);
                                        amountBooked = amountBooked + ps.Amount__c;
                                    }
                                    
                                    if(ps.Estimate__c && ps.Amount__c != null){
                                        amountEstimated = amountEstimated + ps.Amount__c;
                                    }
                                    productSgmt = prodSegPSMap.get(ps.Id);
                                    account = ps.Opportunity__r.AccountId;
                                    System.Debug('account : '+account);
                                }
                            }
                            Account_Product_Segment__c actProdSeg = new Account_Product_Segment__c();
                            actProdSeg.Account__c = account;
                            actProdSeg.Amount_Booked__c = amountBooked;
                            actProdSeg.Amount_Estimated__c = amountEstimated;
                            System.Debug('lastProductSoldDate : '+lastProductSoldDate);
                            actProdSeg.Last_Product_Sold_Date__c = lastProductSoldDate;
                            actProdSeg.Product_Segment__c = productSgmt;
                            
                            actProdSgmtList.add(actProdSeg);                                            
                        }
                }
            }
                    System.Debug('actProdSgmtList :- '+actProdSgmtList);
                    if(actProdSgmtList.size()>0){
                        insert actProdSgmtList;
                    }
                }catch(Exception e){
                    System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                    ErrorLogging.Log(e, 'AccountProductSegment_Batch','App');
                }
            }
            global void finish(DataBase.BatchableContext BC){
                AccountBusinessSegment_Batch schedule = new AccountBusinessSegment_Batch();
                database.executeBatch(schedule, 100);
            }
        }