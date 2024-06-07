/***********************************************************************************************************
Name:  SCP_AG_PL_Webservice
Copyright © 2019
============================================================================================================
============================================================================================================
Purpose: 
This class is exposed as a REST service so Mulesoft can use to send AGPL informatio about for Accounts.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                      DATE                   Description
1.0        Karthik Raj Golakaram        01/27/2021             INITIAL DEVELOPMENT
*************************************************************************************************************/
@RestResource(urlMapping='/accountgroup/*')
global with sharing Class SCP_AG_PL_Webservice{
    
    @HttpPost
    global Static void post(){
    
        RestRequest request= RestContext.request;
        RestResponse response= RestContext.response;
        
        List<ccrz__E_AccountGroup__c> accountGroupToUpsertList= new List<ccrz__E_AccountGroup__c>();//List to store Account groups getting from Mule
        List<ccrz__E_AccountGroupPriceList__c> agplsToUpsertList= new List<ccrz__E_AccountGroupPriceList__c>();//List to Store Account Group Price Lists from Mule.
        List<ccrz__E_PriceList__c> pricelistToUpsertList= new List<ccrz__E_PriceList__c>();//Price list to Update
        List<Account> accntsToUpdateForAGList= new List<Account>();// List to update the Account to associate Account Groups.
        
        Map<String,ccrz__E_AccountGroup__c> agToUpsertMap = new Map<String,ccrz__E_AccountGroup__c>();
        Map<String,ccrz__E_AccountGroupPriceList__c> agplUpsertMap = new Map<String,ccrz__E_AccountGroupPriceList__c>();
        Map<String,ccrz__E_AccountGroupPriceList__c> agplFinalListToUpdateMap= new Map<String,ccrz__E_AccountGroupPriceList__c>(); // MAp to Store the final list of records to Upsert.
        Map<String,ccrz__E_PriceList__c> priceListUpsertMap=new Map<String,ccrz__E_PriceList__c>();// Map To Store Pricelist from JSON.
        
        
        Map<String,String> sapIdAgIdMap= new Map<String,String>();//Map to Store Account SAP ID and Account Group SAP ID -since account will have single ID
        Map<String,String> priceListIDtoPriceListNameMap=new Map<String,String>(); //Map to Store PricelistId to PriceList Name.
        Map<String,String> agplIdToAccountGroupIdMap=new Map<String,String>();//Map To Store AGPL ID to Account Group Id;
        Map<String,String> agplIdToPriceListIdMap= new Map<String,String>();// Map To Store AGPL Id to Price List Id;
        
        List<string> failedAGPLId; //Variable to Store failed AGPL Upsert record Id
        List<String> failedAccountId;//Variable to Store failed Acoount Upsert record Id
        List<String> failedGroupsId;//Variable to Store failed Account Group Upsert record Id
        List<String> failedPriceListId;//Variable to Store failed Price List Upsert record Id.
        
        
        String requestBody= request.requestBody.toString().trim();
        System.debug('Printing the request body'+requestBody);
        Map<string,object> requestMainNode=(Map<String,Object>)JSON.deserializeUntyped(requestBody);
        
        Map<string,Object> ag= (Map<String,object>)requestMainNode.get('AGPLS');
        
        List<Object> accountGroupsFromReq=(List<object>)ag.get('ccrz__E_AccountGroup__c');
        
        try{
                for(Object accountgrp: accountGroupsFromReq){
                // place where we will get Account Group information.
                ccrz__E_AccountGroup__c agpToAdd = new ccrz__E_AccountGroup__c();
                   Map<String,Object> acntGroupsReq= (Map<String,Object>)accountgrp;
                       for(string acntGrpNode:acntGroupsReq.keySet()){
                           //System.debug('Printing value for Account group Field Name'+v);
                           //System.debug('Printing Account Group Strings'+aGroups.get(v));
                           //Assigning values to the Account Group.
                           if(acntGrpNode=='ccrz__AccountGroupID__c'){
                               agpToAdd.ccrz__AccountGroupID__c=(String)acntGroupsReq.get(acntGrpNode);
                           }
                           if(acntGrpNode=='Name'){
                               agpToAdd.Name=(String)acntGroupsReq.get(acntGrpNode);
                           }
                           if(acntGrpNode=='ccrz__PriceListSelectionMethod__c'){
                               agpToAdd.ccrz__PriceListSelectionMethod__c=(String)acntGroupsReq.get(acntGrpNode);
                           }
                           if(acntGrpNode=='CurrencyIsoCode'){
                               agpToAdd.CurrencyIsoCode=(String)acntGroupsReq.get(acntGrpNode);
                           }
                           if(acntGrpNode=='accountid'){
                              // agpToAdd.AccountCSN=(String)aGroups.get(v);
                              //Account sapAcnt= new Account(SAP_Account_ID__c=(String)acntGroupsReq.get(acntGrpNode),ccrz__E_AccountGroup__r=agpToAdd);
                              //System.debug('Printing sapAcnt'+sapAcnt);
                              //sapAcnt.ccrz__E_AccountGroup__r=agpToAdd;
                              //accntsToUpdateForAGList.add(sapAcnt);
                              sapIdAgIdMap.put((String)acntGroupsReq.get(acntGrpNode),agpToAdd.ccrz__AccountGroupID__c);
                           }
                           
                           if(acntGrpNode=='CHILD'){
                               Map<String,Object> childNodeFromReq= (Map<string,Object>)acntGroupsReq.get('CHILD');
                               List<Object> agplsFromReqList=(List<Object>)childNodeFromReq.get('ccrz__E_AccountGroupPriceList__c');  
                               if(!agplsFromReqList.isEmpty()){
                                   for(Object p: agplsFromReqList){
                                   Map<string,Object> agplFromReq= (Map<string,Object>)p;
                                   //Place where we can capture account group price list values.
                                   ccrz__E_AccountGroupPriceList__c agplsToAdd=new ccrz__E_AccountGroupPriceList__c();
                                   ccrz__E_PriceList__c pcl = new ccrz__E_PriceList__c();
                                   String agplIdToAccountGroupIdString='';
                                   String agplIdToPriceListIdString='';
                                   string priceListNameString='';
                                   String accountGroupPriceListId='';
                                       for(String agplNode:agplFromReq.KeySet()){
                                           //System.debug('Printing Account Group Pricelist Field Value===='+sp);
                                           //System.debug('Prnting value of eaxh pricelist'+agplFromReq.get(sp));
                                           System.debug('Printing agpl Node that is looping'+agplNode);
                                           if(agplNode=='ccrz__AccountGroup__c'){
                                               //agplsToAdd.ccrz__AccountGroup__r.ccrz__AccountGroupID__c=(String)agplFromReq.get(sp);
                                              agplIdToAccountGroupIdString=(String)agplFromReq.get(agplNode);
                                           }
                                           if(agplNode=='ccrz__Pricelist__c'){
                                                pcl.ccrz__PricelistId__c= (String)agplFromReq.get(agplNode);//Hoping Price lists is present
                                                agplIdToPriceListIdString=(String)agplFromReq.get(agplNode);
                                                System.debug('Printing the value of the price list Id'+agplIdToPriceListIdString);
                                                System.debug('Printing the agplNode for pricelist'+(String)agplFromReq.get(agplNode));
                                                      
                                           }
                                           if(agplNode=='PLNAME'){
                                           System.debug('Printing PCL value'+pcl);
                                               
                                                pcl.Name=(string)agplFromReq.get(agplNode);
                                                priceListNameString=(string)agplFromReq.get(agplNode);
                                                System.debug('Printintg price list name'+(string)agplFromReq.get(agplNode));
                                           }
                                           if(agplNode=='ccrz__AccountGroupPriceListID__c'){
                                               agplsToAdd.ccrz__AccountGroupPriceListID__c=(String)agplFromReq.get(agplNode);
                                               accountGroupPriceListId=(String)agplFromReq.get(agplNode);
                                               //agplIdToAccountGroupIdMap.put((String)agplFromReq.get(agplNode),agplIdToAccountGroupIdString);
                                               //agplIdToPriceListIdMap.put((String)agplFromReq.get(agplNode),agplIdToPriceListIdString);
                                           }
                                           if(agplNode=='ccrz__Sequence__c'){
                                               agplsToAdd.ccrz__Sequence__c=Decimal.valueOf((String)agplFromReq.get(agplNode));
                                           }
                                           if(agplNode=='ccrz__Enable__c'){
                                               agplsToAdd.ccrz__Enable__c=Boolean.valueOf((String)agplFromReq.get(agplNode));
                                           }
                                           if(agplNode=='ccrz__StartDate__c'){
                                               agplsToAdd.ccrz__StartDate__c=Date.ValueOf((String)agplFromReq.get(agplNode));
                                           }
                                           if(agplNode=='ccrz__EndDate__c'){
                                               agplsToAdd.ccrz__EndDate__c=Date.ValueOf((String)agplFromReq.get(agplNode));
                                           }
                                           
                                           if(!priceListIDtoPriceListNameMap.ContainsKey(agplIdToPriceListIdString)&&String.isNotEmpty(agplIdToPriceListIdString)&&String.isNotEmpty(priceListNameString)){
                                                System.debug('Printing the price list id and Map'+agplIdToPriceListIdString+' And the name is'+(string)agplFromReq.get(agplNode));
                                                priceListIDtoPriceListNameMap.put(agplIdToPriceListIdString,priceListNameString);
                                            }
                                            
                                            if(!agplIdToAccountGroupIdMap.containsKey(accountGroupPriceListId)&&String.isNotEmpty(accountGroupPriceListId)&&String.isNotBlank(agplIdToAccountGroupIdString)){
                                                agplIdToAccountGroupIdMap.put(accountGroupPriceListId,agplIdToAccountGroupIdString);
                                            }
                                            
                                            if(!agplIdToPriceListIdMap.ContainsKey(accountGroupPriceListId)&&String.isNotEmpty(accountGroupPriceListId)&&String.isNotEmpty(agplIdToPriceListIdString)){
                                                agplIdToPriceListIdMap.put(accountGroupPriceListId,agplIdToPriceListIdString);
                                            }
                                       }
                                       priceListUpsertMap.put(pcl.ccrz__PricelistId__c,pcl);
                                       agplUpsertMap.put(agplsToAdd.ccrz__AccountGroupPriceListID__c,agplsToAdd);
                                   }    
                               }     
                           }
                        } 
                      //Insert Account Group into List of Account Groups.
                           
                           agToUpsertMap.put(agpToAdd.ccrz__AccountGroupID__c,agpToAdd);
                }
                
                
                
                Map<string,ccrz__E_AccountGroup__c> agSuccesfulUpsertMap=new Map<String,ccrz__E_AccountGroup__c>();
                
               //Need to Check With Ravi.
               if(!agToUpsertMap.isEmpty()){
                   failedGroupsId= new List<String>();
                   Set<id> successAGIds= new Set<id>();
                   accountGroupToUpsertList=agToUpsertMap.Values();
                  Database.upsertResult[] srList=Database.Upsert(accountGroupToUpsertList,ccrz__E_AccountGroup__c.ccrz__AccountGroupID__c.getDescribe().getSObjectField(),false);
                   for(Database.upsertResult sg: srList){
                       if(!sg.isSuccess()){
                           //Insert a record into error log
                           failedGroupsId.add(sg.getId());
                       }
                   }
                     if(!failedGroupsId.isEmpty()){
                         new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_AG_PL_Webservice','post','Account Group Upsert failed','{\n"message":"captured Partial Account Group Information",\n"statusCode:"200"\n"Status":"Success",\n"Data":null\n}',requestBody,'200',new MyException(string.join(failedGroupsId,';'))));
                     }
                }
                
                //Updating the Accounts with Account Groups.
               /* if(!sapIdAgIdMap.isEmpty()){
                    //Update Account with Account GRoup.
                    for(String sapId : sapIdAgIdMap.keySet()){
                        Account acnt= new Account(SAP_Account_ID__c=sapId);
                        acnt.ccrz__E_AccountGroup__c=agToUpsertMap.get(sapIdAgIdMap.get(sapId)).id;
                        accntsToUpdateForAGList.add(acnt);
                    }
                    failedAccountId= new List<String>();
                    Database.upsertResult[] srAccountList=Database.Upsert(accntsToUpdateForAGList,Account.SAP_Account_ID__c.getDescribe().getSObjectField(),false);
                    for(Database.upsertResult sa: srAccountList){
                       if(!sa.isSuccess()){
                           //Insert a record into error log
                           failedAccountId.add(sa.getId());
                       }
                   }
                   if(!failedAccountId.isEmpty()){
                      new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_AG_PL_Webservice','post','Accounts with Account group Upsert failed','{\n"message":"captured Partial Account Group Information",\n"statusCode:"200"\n"Status":"Success",\n"Data":null\n}',requestBody,'200',new MyException(string.join(failedAccountId,';'))));    
                   }
                }*/
                
                System.debug('Printing the pricelist Name Map'+priceListIDtoPriceListNameMap);
                //PriceList to Upsert that are obtained from JSON.
                if(!priceListUpsertMap.isEmpty()){
                    failedPriceListId=new List<String>();
                    for(String pLId: priceListUpsertMap.keySet()){
                        //ccrz__E_PriceList__c plToUpsert=new ccrz__E_PriceList__c(ccrz__PricelistId__c=pLId);
                        priceListUpsertMap.get(pLId).Name=priceListIDtoPriceListNameMap.get(pLId);
                        priceListUpsertMap.get(pLId).ccrz__Enabled__c=true;
                        priceListUpsertMap.get(pLId).ccrz__Storefront__c=System.Label.SCP_Store_Front_Name;
                        priceListUpsertMap.get(pLId).ccrz__StartDate__c=System.Today();
                        priceListUpsertMap.get(pLId).ccrz__EndDate__c=System.Today()+28470;
                        priceListUpsertMap.get(pLId).ccrz__CurrencyISOCode__c='USD';
                    }
                    Database.upsertResult[] srPriceList=Database.Upsert(priceListUpsertMap.Values(),ccrz__E_PriceList__c.ccrz__PricelistId__c.getDescribe().getSObjectField(),false);
                    for(Database.upsertResult srp: srPriceList){
                        if(!srp.isSuccess()){
                            failedPriceListId.add(srp.getId());
                        }
                    }
                   if(!failedPriceListId.isEmpty()){
                        new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_AG_PL_Webservice','post','Pricelist Upsert failed','{\n"message":"captured Partial Account Group Information",\n"statusCode:"200"\n"Status":"Success",\n"Data":null\n}',requestBody,'200',new MyException(string.join(failedPriceListId,';')))); 
                   }
                }
                
                //Query all the AG and AGPLS in System and compare the values of AGPLS and Update them accordingly.
                //if AGPL Unique ID is missing in the map we recieved from Mule and is present in the SAlesforce.
                // We need to set the isEnabled flag for the price list to false and change the end date to yesterdays date.
                Map<String,ccrz__E_AccountGroupPriceList__c> allAGPLSMap = new Map<String,ccrz__E_AccountGroupPriceList__c>();// Map to Store AGPLS present in ORG
                List<ccrz__E_AccountGroupPriceList__c> allAGPLS=[SELECT id
                                                                      , ccrz__AccountGroup__c
                                                                      , ccrz__Pricelist__c
                                                                      , ccrz__AccountGroupPriceListID__c
                                                                      , ccrz__Sequence__c
                                                                      , ccrz__Enable__c
                                                                      , ccrz__StartDate__c
                                                                      , ccrz__EndDate__c
                                                                      FROM ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__r.ccrz__AccountGroupID__c=:agToUpsertMap.keySet()]; //Need to check with Ravi for Limit Exceptions.
                if(!allAGPLS.isEmpty()){
                    for(ccrz__E_AccountGroupPriceList__c pls: allAGPLS){
                        if(!allAGPLSMap.ContainsKey(pls.ccrz__AccountGroupPriceListID__c)){
                            allAGPLSMap.put(pls.ccrz__AccountGroupPriceListID__c,pls);
                        }
                    }
                
                    if(!agplUpsertMap.isEmpty()){
                        //loop through Key set of the all AGPLS and also all agpls from Mule. IF AGPL is present in SF and not in Mule cahnge the status to disable.
                        for(String st:allAGPLSMap.keySet()){
                            if(!agplUpsertMap.ContainsKey(st)){
                                //Since Key is not present in Mule we will update the enabled flag to false. by getting from system
                                System.debug('Printing agpls to disable');
                                allAGPLSMap.get(st).ccrz__Enable__c=false;
                                allAGPLSMap.get(st).ccrz__EndDate__c=System.Today(); 
                                //agplsToUpsertList.add(allAGPLSMap.get(st));
                                if(!agplFinalListToUpdateMap.containsKey(st)){
                                    agplFinalListToUpdateMap.put(st,allAGPLSMap.get(st));
                                } 
                            }
                        }
                    }
                }
                
                if(!agplUpsertMap.isEmpty()){
                    //Now looping through the agplUpsertMap got from Mule to add them to final list to update.
                    for(String sKeys: agplUpsertMap.keySet()){
                        if(!agplFinalListToUpdateMap.containsKey(sKeys)){
                            agplFinalListToUpdateMap.put(sKeys,agplUpsertMap.get(sKeys));
                        }
                    }
                }
                
                if(!agplFinalListToUpdateMap.isEmpty()){
                    for(String agplKeys:agplFinalListToUpdateMap.keySet()){
                        if(agplIdToPriceListIdMap.ContainsKey(agplKeys)){
                            if(priceListUpsertMap.containsKey(agplIdToPriceListIdMap.get(agplKeys))){
                                agplFinalListToUpdateMap.get(agplKeys).ccrz__Pricelist__c=priceListUpsertMap.get(agplIdToPriceListIdMap.get(agplKeys)).id; 
                            }
                            
                            if(agToUpsertMap.containsKey(agplIdToAccountGroupIdMap.get(agplKeys))){
                                agplFinalListToUpdateMap.get(agplKeys).ccrz__AccountGroup__c=agToUpsertMap.get(agplIdToAccountGroupIdMap.get(agplKeys)).id;
                            }
                        }
                    }
                    agplsToUpsertList=agplFinalListToUpdateMap.Values();
                }
                System.debug('Printing all the AGPLS that we need to upsert using unique id'+agplsToUpsertList);
                //AGPL Update part starts.
                
                
                if(!agplsToUpsertList.isEmpty()){
                    failedAGPLId= new List<String>();
                   Database.upsertResult[] saveResult=Database.upsert(agplsToUpsertList,ccrz__E_AccountGroupPriceList__c.ccrz__AccountGroupPriceListID__c.getDescribe().getSObjectField(),false);
                    for(Database.upsertResult sr: saveResult){
                        if(!sr.isSuccess()){
                            //get id and insert in error Object 
                            failedAGPLId.add(sr.getId());
                        }
                    }
                    if(!failedAGPLId.isEmpty()){
                        new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_AG_PL_Webservice','post','Account Group Price list Upsert failed','{\n"message":"captured Partial Account Group Information",\n"statusCode:"200"\n"Status":"Success",\n"Data":null\n}',requestBody,'200',new MyException(string.join(failedAGPLId,';'))));    
                    }
                }
                
                if(failedGroupsId.isEmpty()&&failedAGPLId.isEmpty()){
                    response =getResponse(200,'captured Account Group Information',true);
                }else{
                    response =getResponse(200,'captured Partial Account Group Information',true);
                    new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.information('SCP_AG_PL_Webservice','post','','Account Group Price list infromation captured partially','{\n"message":"captured Partial Account Group Information",\n"statusCode:"200"\n"Status":"Success",\n"Data":null\n}',requestBody,'200'));
                }
                
        }catch(exception ex){
                System.debug('Printing Exception ex'+ex.getStackTraceString());
                //Insert a record into Error Object.
                response=getResponse(400,ex.getMessage(),false);
                new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_AG_PL_Webservice','post','Account Group Upsert failed','{\n"message":"+ex.getMessage()+",\n"statusCode:"400"\n"Status":"fail",\n"Data":null\n}',requestBody,'400',ex));
        }
    }

    Private Static RestResponse getResponse(Integer statusCode,String message,Boolean isSuccess){
        
        String jsonResponse='';
        RestResponse response = RestContext.response;
        response.addHeader('content-Type','application/json');
        response.statusCode=statusCode;
        if(isSuccess){
            jsonResponse='{\n"message":"'+message+'",\n"statusCode:"'+statusCode+'\n"Status":"Success",\n"Data":null\n}';
        }else if(!isSuccess){
            jsonResponse='{\n"message":"'+message+'",\n"statusCode:"'+statusCode+'\n"Status":"Fail",\n"Data":null\n}';
        }
        response.responseBody=blob.valueOf(jsonResponse);
        return response;
    }
    
    Public class MyException extends Exception{} 
}