/***********************************************************************************************************
Name:  AccountProductSegment_Batch_NEW
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
0.1          Sravan          17/09/2019                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountProductSegment_Batch_NEW implements DataBase.Batchable<sObject>{
    global Date lastProductSoldDate;
    
    private String jobStatus = 'Successful';
	private Job_execution__c jobExec;
    
    global AccountProductSegment_Batch_NEW(){        
    }
    
    global AccountProductSegment_Batch_NEW(Job_execution__c j) {
        jobExec = j;
    } 
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Amount__c,Cost__c,Date_Booked__c,Estimate__c,Opportunity__c,Opportunity__r.AccountId,Product_Segment__c,Quantity__c,Quote__c FROM Product_Segment__c where Opportunity__r.AccountId != null';
        //List<Product_Segment__c> prodSeg = [select id, Date_Booked__c from Product_Segment__c ORDER BY Date_Booked__c DESC limit 1];
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Product_Segment__c> prodSegmentList){
        try{
            //Delete all existing records in Account_Product_Segment__c
            System.debug('prodSegmentList size : '+prodSegmentList.size());
            System.Debug('prodSegmentList ==== '+prodSegmentList);
            //List<String> pSegList = new List<String>();
            Map<Id,Set<String>> acctPSegSetMap = new Map<Id,Set<String>>();
            Map<Id,String> prodSegPSMap= new Map<Id,String>();
            Map<String,List<Product_Segment__c>> pSegProductSegmentsMap = new Map<String,List<Product_Segment__c>>();
               
            Set<ID> accountIds = new Set<ID>();
            Map<Id,List<Product_Segment__c>> accountProdSegMap = new Map<Id,List<Product_Segment__c>>();
            
            List<Account_Product_Segment__c> actProdSgmtList = new List<Account_Product_Segment__c>();
            
            try{
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
    
                System.Debug('pSegProductSegmentsMap :- '+pSegProductSegmentsMap+'account ids :  '+accountIds);
            } catch (Exception e) {
                JobMonitor.logMessage(jobExec, 'AccountProductSegment_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : prodSegPSMap create Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e'); 
            }

            try{
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
            } catch (Exception e){
                JobMonitor.logMessage(jobExec, 'AccountProductSegment_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : acctPSegSetMap create Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e'); 
            }
            
            try{
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
            } catch (Exception e){
                JobMonitor.logMessage(jobExec, 'AccountProductSegment_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : actProdSgmtList create Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e'); 
                
            }
            
            try{
                if(actProdSgmtList.size()>0){
                    insert actProdSgmtList;
                }
            } catch (Exception e){
                JobMonitor.logMessage(jobExec, 'AccountProductSegment_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
					+ ' : insert Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e');   
            }  
                    
        }catch(Exception exAll){
            System.debug('Exception : '+exAll.getMessage()+' Line no. : '+exAll.getLineNumber());
            JobMonitor.logMessage(jobExec, 'AccountProductSegment_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
					+ ' Insert EXCEPTION : ' + exAll.getMessage() + ' Line : ' + exAll.getLineNumber(), 'e');
            
            ErrorLogging.Log(exAll, 'AccountProductSegment_Batch_NEW','App');
        }
    }
    
    global void finish(DataBase.BatchableContext BC){
        AccountBusinessSegment_DELETE_Bacth schedule = new AccountBusinessSegment_DELETE_Bacth(jobExec);
        database.executeBatch(schedule, 200);
    }
}