/***********************************************************************************************************
Name:  AccountProductLine_Batch_NEW
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will go through all records of Product_Line__c object, deletes exisitng records
of Account_Product_Line__c and roll up the values from Product_Line__c and create new records in Account_Product_Line__c
for an Account.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Sravan          17/09/2019                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountProductLine_Batch_NEW implements DataBase.Batchable<sObject>{
    global Date lastProductSoldDate;
    private String jobStatus = 'Successful';
	private Job_execution__c jobExec;
    
    global AccountProductLine_Batch_NEW(){        
    }
    
    global AccountProductLine_Batch_NEW(Job_execution__c j) {
        jobExec = j;
        
        JobMonitor.logMessage(jobExec, 'AccountProductLine_Batch :: This Batch was scheduled at 12:00 AM, '
			+ 'this Batch will go through all records of Product_Line__c object, deletes exisitng records '
			+ 'of Account_Product_Line__c and roll up the values from Product_Line__c and create new records '
			+ 'in Account_Product_Line__c for an Account.. ', 's');
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){       
        String query = 'SELECT Id,Name,Amount__c,Date_Booked__c,Estimate__c,Opportunity__c,Opportunity__r.AccountId,Product_Line_Picklist2__c,Quantity__c,Quote__c FROM Product_Line__c where Opportunity__r.AccountId != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Product_Line__c> prodLineList){
        try{
            System.debug('prodLineList size : '+prodLineList.size());
            System.debug('Product Lines : '+prodLineList);
            Map<Id,Set<String>> acctPLineSetMap = new Map<Id,Set<String>>();
            Map<Id,String> prodLinePLMap= new Map<Id,String>();
            Map<String,List<Product_Line__c>> pLineProductLinesMap = new Map<String,List<Product_Line__c>>();
            
            Set<ID> accountIds = new Set<ID>();
            Map<Id,List<Product_Line__c>> accountProdLineMap = new Map<Id,List<Product_Line__c>>();
            
            List<Account_Product_Line__c> actProdLineList = new List<Account_Product_Line__c>();
            
            try{
                if(prodLineList.size()>0){
                    for(Product_Line__c pl : prodLineList){
                        lastProductSoldDate = pl.Date_Booked__c;
                        
                        accountIds.add(pl.Opportunity__r.AccountId);
                        
                        if(accountProdLineMap.containsKey(pl.Opportunity__r.AccountId)){
                            accountProdLineMap.get(pl.Opportunity__r.AccountId).add(pl);
                        }else{
                            accountProdLineMap.put(pl.Opportunity__r.AccountId, new  List <Product_Line__c> { pl });
                        }
                        
                        if(pLineProductLinesMap.containsKey((pl.Product_Line_Picklist2__c).toLowerCase())){
                            pLineProductLinesMap.get((pl.Product_Line_Picklist2__c).toLowerCase()).add(pl);
                        }else{
                            pLineProductLinesMap.put((pl.Product_Line_Picklist2__c).toLowerCase(), new List<Product_Line__c> {pl});                                
                        }
                        
                        prodLinePLMap.put(pl.Id, pl.Product_Line_Picklist2__c);
                    }
                }
             //   System.Debug('pLineProductLinesMap :- '+pLineProductLinesMap);
            } catch(Exception eplm){
                JobMonitor.logMessage(jobExec, 'AccountProductLine_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : ProductLine Map Exception: ' + eplm.getMessage() + ' Line : ' + eplm.getLineNumber(), 'e');    
            }
            
            try{
                if(accountIds.size()>0){
                    for(Id acct : accountIds){
                        for(Product_Line__c pl : accountProdLineMap.get(acct)){
                            if(acctPLineSetMap.containsKey(acct)){
                                acctPLineSetMap.get(acct).add((pl.Product_Line_Picklist2__c).toLowerCase());
                            }else{
                                acctPLineSetMap.put(acct, new Set<String> {(pl.Product_Line_Picklist2__c).toLowerCase()});
                            }
                        }
                    }
                }
            
                System.debug('accountProdLineMap : '+accountProdLineMap);
                System.Debug('acctPLineSetMap : '+acctPLineSetMap);
                
                System.Debug('prodLineList : '+prodLineList);
            } catch(Exception eaplm){
                JobMonitor.logMessage(jobExec, 'AccountProductLine_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : Account ProductLine Map Exception: ' + eaplm.getMessage() + ' Line : ' 
							+ eaplm.getLineNumber(), 'e');    
            } 
            
            try{            
                if(accountIds.size()>0){
                    for(Id acctId : accountIds){
                        for(String pLine : acctPLineSetMap.get(acctId)){
                            ID account;
                            double amountBooked = 0;
                            double amountEstimated = 0;
                            String productLine;
                            Date recentSoldDate;
                            for(Product_Line__c pl : accountProdLineMap.get(acctId)){
                                if(pLineProductLinesMap.containsKey((pl.Product_Line_Picklist2__c).toLowerCase()) && (pl.Product_Line_Picklist2__c).toLowerCase() == pLine){
                                 //   System.Debug('pLine : '+pLine);
                                //    System.Debug('pl.Opportunity__r.AccountId : '+pl.Opportunity__r.AccountId);
                                    if(pl.Amount__c != null){
                                  //      System.Debug('pl.Amount__c : '+pl.Amount__c);
                                        amountBooked = amountBooked + pl.Amount__c;
                                    }
                                    if(pl.Estimate__c && pl.Amount__c != null){
                                        amountEstimated = amountEstimated + pl.Amount__c;
                                    }
                                    productLine = prodLinePLMap.get(pl.Id);
                                    account = pl.Opportunity__r.AccountId;
                                    System.Debug('account : '+account);
                                }
                            }
                            Account_Product_Line__c actProdLine = new Account_Product_Line__c();
                            actProdLine.Account__c = account;
                            actProdLine.Amount_Booked__c = amountBooked;
                            actProdLine.Amount_Estimated__c = amountEstimated;
                      //      System.Debug('lastProductSoldDate : '+lastProductSoldDate);
                            actProdLine.Last_Product_Sold_Date__c = lastProductSoldDate;
                            actProdLine.Product_Line__c = productLine;
                            
                            actProdLineList.add(actProdLine); 
                        //    System.Debug('look at actProdLineList : '+actProdLineList);
                        }
                    }
                }
                
             //   System.debug('actProdLineList size : '+actProdLineList.size());
             //   System.debug('actProdLineList : '+actProdLineList);
            
            } Catch(Exception eapll){
                JobMonitor.logMessage(jobExec, 'AccountProductLine_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : actProdLineList Exception: ' + eapll.getMessage() + ' Line : ' + eapll.getLineNumber(), 'e');  
            }
                
            try{
                if(actProdLineList.size()>0){
                	insert actProdLineList;
            	}
            } catch(Exception exInsert){
                JobMonitor.logMessage(jobExec, 'AccountProductLine_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
                                      + ' : Insert Exception: ' + exInsert.getMessage() + ' Line : ' 
                                      + exInsert.getLineNumber(), 'e');
            }
            
            
        }catch(Exception exAll){
        //    System.debug('Exception : '+exAll.getMessage()+' Line no. : '+exAll.getLineNumber());
            JobMonitor.logMessage(jobExec, 'AccountProductLine_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : Exception: ' + exAll.getMessage() + ' Line : ' + exAll.getLineNumber(), 'e');
            ErrorLogging.Log(exAll, 'AccountProductLine_Batch_NEW','App');
        }
    }
    global void finish(DataBase.BatchableContext BC){
        AccountProductSegment_DELETE_Bacth schedule = new AccountProductSegment_DELETE_Bacth(jobExec);
        database.executeBatch(schedule, 200); 
    }
}