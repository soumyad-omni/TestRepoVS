/***********************************************************************************************************
Name:  IdentifyOutdatedProducts_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch will get all Open Quotes to verify their Product Codes With 
"Old Product Number" of Product Changes object where Admins defines a product Code with an error message and an effective date.
If any Product Code reaches the effective date, then that Quote will get updated with "Has Critical Errors" checkbox as checked,
and respective record will get created in "Quote Error" object.
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          21/07/2018     Developed by CG team     INITIAL DEVELOPMENT
*************************************************************************************************************/
global class IdentifyOutdatedProducts_Batch implements DataBase.Batchable<sObject>, DataBase.Stateful{
    Map<String,List<ErrorsEmailWrapper>> ownerErrorsMap = new Map<String,List<ErrorsEmailWrapper>>();
    Map<String,String> ownerSAPNumber = new Map<String,String>();
    Map<String,String> ownerFNameMap = new Map<String,String>();
    Set<String> ownerEmailSet = new Set<String>();
    List<ErrorsEmailWrapper> erEmailWrapperList = new List<ErrorsEmailWrapper>();
    
    string td1='"border:1px solid gray; width=200px; padding:5px;"';
    //string td2='"width=200px; border:1px solid gray; background-color:red; color:white; font-weight:bold;"';
    string tdHead='"border:0px solid gray; width=200px; color:white; background-color:gray; font-weight:bold;"';
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String stat = System.Label.Quote_Status_Open;
        String acctValidStatus = System.Label.Account_Validation_Status_Validated;
        String Query = 'Select id,name,Quote__r.Id,Product_Code__c,Product__r.Id,Product__r.ProductCode from Quote_Line__c where Quote__r.Shipping_Contact__c !=null and Quote__r.Bill_to_Account__c != null and toLabel(Quote__r.Account.Validation_Status__c)=:acctValidStatus and toLabel(Quote__r.Status)=:stat and Product_Code__c != null';
        return Database.getQueryLocator(Query);
    }
    global void execute(DataBase.BatchableContext BC, List<Quote_Line__c> quoteLineList){        
        List<Product_Changes__c> prodChangeList = new List<Product_Changes__c>();
        prodChangeList = [Select id,Active__c,Effective_Date__c,Error_Message__c,Old_Product_Number__c from Product_Changes__c where Active__c = true];
        System.Debug('quoteLineList : '+quoteLineList);
        System.Debug(' prodChangeList : '+prodChangeList);
        Boolean quoteHasCriticalErrors = false;
        Set<Id> quoteIDSet = new Set<Id>();
        if(quoteLineList.size()>0){
            for(Quote_Line__c ql: quoteLineList){
                quoteIDSet.add(ql.Quote__r.Id);
            }
        }
        
        List<Quote> quoteList = [Select id,name,QuoteNumber,Owner.Firstname,ProductChangeError__c,Owner.email,Quote_Number__c,Status,Has_Critical_Errors__c,Locked__c from Quote where Id in:quoteIDSet FOR UPDATE];
        System.Debug('quoteList : '+quoteList);
        List<Quote> updateQuoteList = new List<Quote>();
        Quote qtObj = new Quote();
        Quote_Error__c qErrObj;
        List<Quote_Error__c> areQuoteErrorsExists = new List<Quote_Error__c>();
        List<Quote_Error__c> quoteErrorList = new List<Quote_Error__c>();
        
        
        Map<String, String> productErrorMap = new Map<String, String>();
        
        List<ErrorsEmailWrapper> erEmailWrapperList = new List<ErrorsEmailWrapper>();        
        
        areQuoteErrorsExists = [select id,Quote__c,Error_Message__c from Quote_Error__c where Quote__r.Id in:quoteIdSet];
        
        if(areQuoteErrorsExists.size()>0){
            for(Product_Changes__c p: prodChangeList){
                for(Quote_Error__c qe: areQuoteErrorsExists){
                    for(Quote_Line__c ql: quoteLineList){
                        if(p.Old_Product_Number__c==ql.Product__r.Id && p.Error_Message__c==qe.Error_Message__c)
                        productErrorMap.put(p.Old_Product_Number__c, qe.Error_Message__c);
                    }
                }
            }
        }
        System.Debug('productErrorMap : '+productErrorMap);
        if(quoteList != null && !quoteList.isEmpty()){
            for(Quote q: quoteList){
                if(prodChangeList != null && !prodChangeList.isEmpty()){
                    for(Product_Changes__c pc: prodChangeList){
                        if(quoteLineList != null && !quoteLineList.isEMpty()){
                            for(Quote_Line__c ql: quoteLineList){
                                System.Debug('ql.Product_Code__c :-'+ql.Product_Code__c);
                                if(!productErrorMap.containsKey(ql.Product__r.Id)/* && productErrorMap.get(ql.Product_Code__c)!=pc.Error_Message__c*/){                                
                                    if(ql.Product__r.Id==pc.Old_Product_Number__c && pc.Effective_Date__c<System.today()){
                                        if(!(q.Locked__c) && q.id == ql.Quote__c){
                                            System.Debug('Quote......'+q.name);
                                            q.id=q.id;
                                            q.Has_Critical_Errors__c = true;
                                            if(q.ProductChangeError__c != '' && q.ProductChangeError__c != null){
                                              q.ProductChangeError__c = q.ProductChangeError__c + pc.Error_Message__c + '\n';
                                            }else{
                                                q.ProductChangeError__c = pc.Error_Message__c + '\n';
                                            }
                                            
                                            qErrObj = new Quote_Error__c();
                                            qErrObj.Product_Change_Error__c=true;
                                            qErrObj.Product__c=ql.Product__r.Id;     
                                            qErrObj.Quote__c = q.id;
                                            System.debug('pc.Error_Message__c : '+pc.Error_Message__c);
                                            qErrObj.Error_Message__c = pc.Error_Message__c;
                                            quoteErrorList.add(qErrObj);
                                            System.debug('Inside for...'+quoteErrorList);
                                            
                                            ownerEmailSet.add(q.owner.email);
                                            
                                            ErrorsEmailWrapper wrapObj = new ErrorsEmailWrapper();
                                            wrapObj.recId = q.id;
                                            wrapObj.SAPQtNumber = q.Quote_Number__c;
                                            wrapObj.qNumber = q.QuoteNumber;
                                            wrapObj.qName = q.Name;
                                            wrapObj.qlNumber = ql.Name;
                                            wrapObj.productCode = ql.Product_Code__c;
                                            wrapObj.errorMsg = pc.Error_Message__c;
                                            wrapObj.ownerFName = q.owner.FirstName;
                                            wrapObj.ownerEmail = q.owner.email;
                                            
                                            erEmailWrapperList.add(wrapObj);
                                            system.debug('erEmailWrapperList :- '+erEmailWrapperList);
                                            
                                        }
                                    }
                                }                                 
                            }
                            
                        }                        
                    }
                }
                updateQuoteList.add(q);                
            }
        }
        System.Debug(' updateQuoteList : '+updateQuoteList);
        System.Debug('quoteErrorList : '+quoteErrorList);

        for(ErrorsEmailWrapper wr : erEmailWrapperList){
            ownerSAPNumber.put(wr.ownerEmail,wr.SAPQtNumber);
            ownerFNameMap.put(wr.ownerEmail,wr.ownerFName);
            
            System.Debug('wr.ownerEmail :- '+ wr.ownerEmail);
            if(ownerErrorsMap.containsKey(wr.ownerEmail)){                                                    
                ownerErrorsMap.get(wr.ownerEmail).add(wr);
                
            } else{
                ownerErrorsMap.put(wr.ownerEmail, new List<ErrorsEmailWrapper>{wr});                
            }             
        }
        if(updateQuoteList.size()>0){
            update updateQuoteList;
        }
        if(quoteErrorList.size()>0){
            insert quoteErrorList;
        }
        
        
    }
    global void finish(DataBase.BatchableContext BC){
        System.debug('ownerErrorsMap : '+ ownerErrorsMap);
        if(!ownerErrorsMap.isempty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            System.debug('ownerEmailSet :: '+ownerEmailSet);
            for(String owner: ownerEmailSet){
                String[] toAddresses = new String[] {owner};
                    mail.setToAddresses(toAddresses);
                mail.setSubject('Product Change for Quote: '+ownerSAPNumber.get(owner));
                string htmlBody = '<div style="border:0px solid gray;"><p>Dear '+ownerFNameMap.get(owner)+',</p><p>The following products have changed. Please update your quote accordingly using the link below.</p>'
                    +'<center><table style="border:0px solid gray; border-collapse:collapse;">'
                    +'<tr><td style='+tdHead+'>Quote</td><td style='+tdHead+'>Quote Line Reference</td><td style='+tdHead+'>Product Code</td><td style='+tdHead+'>Error</td></tr>';
                System.Debug('ownerErrorsMap.get(owner) :- '+ownerErrorsMap.get(owner));
                for(ErrorsEmailWrapper wr : ownerErrorsMap.get(owner)){
                    String qtRecLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+wr.recId;
                    qtRecLink = qtRecLink.removeEnd('/');
                    htmlBody = htmlBody + '<tr><td style='+td1+'><a href='+qtRecLink+'>'+wr.qNumber+'</a></td><td style='+td1+'>'+wr.qlNumber+'</td><td style='+td1+'>'+wr.productCode+'</td><td style='+td1+'>'+wr.errorMsg+'</td></tr>';
                }
                htmlBody = htmlBody +'</table></center>';   
                htmlBody = htmlBody +'<p><br>Thank you,<br>Omnicell IT</p>';
                mail.setHtmlBody(htmlBody);
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
    global class ErrorsEmailWrapper{
        String recId;
        String SAPQtNumber;
        String qNumber;
        String qName;
        String qlNumber;
        String productCode;
        String errorMsg;
        String ownerFName;
        String ownerEmail;
        
        global ErrorsEmailWrapper(){            
        }
    }
}