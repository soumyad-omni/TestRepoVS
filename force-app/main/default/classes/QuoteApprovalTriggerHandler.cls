/**********************************************************************
Name:  QuoteApprovalTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for QuoteApprovalTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Venu                      ?          INITIAL DEVELOPMENT
***********************************************************************/
public class QuoteApprovalTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public static boolean approvalstatus = false;
    public static boolean isInsert = false;
    public static boolean isbatchupdate = false;
    public boolean isDisabled;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('QuoteApprovalTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        
        Set<Id> quoteIds = new Set<Id>();
        for(Quote_Approval__c qa: (List<Quote_Approval__c>)newItems){
            quoteIds.add(qa.Quote__c);
        }
        
        Map<Id, Quote_Approval__c> quote2QuoteApprovalMap = new Map<Id, Quote_Approval__c>();
        for(Quote_Approval__c qa: [Select Quote__c, Status__c from Quote_Approval__c where Quote__c IN :quoteIds AND Status__c = 'Waiting Approval']){
            If(!quote2QuoteApprovalMap.containsKey(qa.Quote__c)){
                quote2QuoteApprovalMap.put(qa.Quote__c, qa);
            }
        }
        
        List<Quote> quote2Update = new List<Quote>();
        for(Quote_Approval__c qa: (List<Quote_Approval__c>)newItems){
            if(!quote2QuoteApprovalMap.containsKey(qa.Quote__c) && qa.Status__c == 'Waiting Approval'){
                quote2Update.add(new Quote(Id = qa.Quote__c, IsWaitingApprovalPresent__c = true));
            }else if(!quote2QuoteApprovalMap.containsKey(qa.Quote__c) && qa.Status__c != 'Waiting Approval'){
                quote2Update.add(new Quote(Id = qa.Quote__c, IsWaitingApprovalPresent__c = false));
            }
        }
        
        if(quote2Update.size() > 0){
            QuoteTriggerHandler.updatefromqa = true;
            update quote2Update;
        }
        
        for(Quote_Approval__c qa: (List<Quote_Approval__c>)newItems){
            if(quote2QuoteApprovalMap.containsKey(qa.Quote__c) && qa.Status__c == 'New'){
                qa.addError('Quote Approval with Status \'Waiting Approval\' is already present on Quote.');
            }
        }
        //system.debug(newItems);
        // checkboxAutomation1(newItems);
        //queueSelector(newItems);
        
        //system.debug(newItems);
        checkboxAutomation1(newItems);
        setClinicalConsultant(newItems,quoteIds); //IBA-1678 
        //queueSelector(newItems);
        List<Quote_Approval__c> qapList1 = newItems;
        List<Quote_Approval__c> qapList2 = new List<Quote_Approval__c>();
        for(Quote_Approval__c qa:qapList1){
            if(qa.id!=NULL)
                if(!qapList2.contains(qa))
                qapList2.add(qa);
        }
        
        List<Quote_Approval__c> quoteAppRecList = newItems;
        //IBA-1592 START
        List<Quote> listQuotes = new List<Quote>();
        Set<Id> oppsIds = new Set<Id>();
        Map<ID, ID> idMapping = new Map<ID, ID>();   
        Map<ID, Opportunity> oppIdMapping = new Map<ID, Opportunity>();  
        List<Opportunity> listOpps = new List<Opportunity>();
        listQuotes = [Select Id,OpportunityId from Quote where Id IN: quoteIds];     
        
        if (listQuotes.size()>0) {
            for (Quote quoteRecord :listQuotes) {
                oppsIds.add(quoteRecord.OpportunityId);
                idMapping.put(quoteRecord.id,quoteRecord.OpportunityId);
            }    
        }
        listOpps = [SELECT Id, ownerId,CustomerType__c  FROM Opportunity WHERE Id IN: oppsIds];
        if (listOpps.size()>0) {
            for (Opportunity Opp1 :listOpps) {
                oppIdMapping.put(Opp1.id,Opp1);
            }    
        }
        for(Quote_Approval__c qa:quoteAppRecList){ 
            ID oppID = idMapping.get(qa.Quote__c);
            if(oppId != Null){  
                Opportunity oppRecord = oppIdMapping.get(oppId);
                if(oppRecord.ownerId !=NULL)
                    qa.Opportunity_Owner__c=oppRecord.ownerId;
                
                if(oppRecord.CustomerType__c=='New Customer') 
                    qa.New_Customer__c=true;
            }
        }  
        //IBA-1592 END 
    }   
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
     
        if(!isbatchupdate){
            Set<Id> quoteIds = new Set<Id>();
            Set<Id> quoteApprovalIds = new Set<Id>();
            for(Quote_Approval__c qa: (List<Quote_Approval__c>)newItems.values()){
                quoteIds.add(qa.Quote__c);
                quoteApprovalIds.add(qa.Id);
            }
            List<Quote> qtes = [select id,IsWaitingApprovalPresent__c from Quote where id=:quoteIds];//Added by Sravan on 28 AUG
            Map<Id, Boolean> quote2ISWaitingMap = new Map<Id, Boolean>();//Added by Sravan on 28 AUG
            Map<Id, Quote_Approval__c> quote2QuoteApprovalMap = new Map<Id, Quote_Approval__c>();
            for(Quote_Approval__c qa: [Select Quote__c, Status__c from Quote_Approval__c where Quote__c IN :quoteIds AND Status__c = 'Waiting Approval' AND ID Not IN :quoteApprovalIds]){
                If(!quote2QuoteApprovalMap.containsKey(qa.Quote__c)){
                    quote2QuoteApprovalMap.put(qa.Quote__c, qa);
                }
            }
            for(Quote q:qtes){//Added by Sravan on 28 AUG
                If(!quote2ISWaitingMap.containsKey(q.Id))//Added by Sravan on 28 AUG
                    quote2ISWaitingMap.put(q.Id,q.IsWaitingApprovalPresent__c);//Added by Sravan on 28 AUG
            }//Added by Sravan on 28 AUG
            List<Quote> quote2Update = new List<Quote>();
            for(Quote_Approval__c qa: (List<Quote_Approval__c>)newItems.values()){
                if(!quote2QuoteApprovalMap.containsKey(qa.Quote__c) && qa.Status__c == 'Waiting Approval'){
                    if(quote2ISWaitingMap.get(qa.Quote__c) != true)//Added by Sravan on 28 AUG
                        quote2Update.add(new Quote(Id = qa.Quote__c, IsWaitingApprovalPresent__c = true));
                }else if(!quote2QuoteApprovalMap.containsKey(qa.Quote__c) && qa.Status__c != 'Waiting Approval'){
                    if(quote2ISWaitingMap.get(qa.Quote__c) != false)//Added by Sravan on 28 AUG
                        quote2Update.add(new Quote(Id = qa.Quote__c, IsWaitingApprovalPresent__c = false));
                }
            }
            
            if(quote2Update.size() > 0){
                QuoteTriggerHandler.updatefromqa = true;
                update quote2Update;
            }
            
            for(Quote_Approval__c qa: (List<Quote_Approval__c>)newItems.values()){
                if(quote2QuoteApprovalMap.containsKey(qa.Quote__c) && qa.Status__c == 'New'){
                    qa.addError('Quote Approval with Status \'Waiting Approval\' is already present on Quote.');
                }
            }
            QuoteApprovalAssignToFuture.AssignToQueue(quoteApprovalIds);//SF-Bug-1055
            List<Quote_Approval__c> quoteAppRecList = newItems.values();
            checkboxAutomation1(quoteAppRecList);
            setClinicalConsultant(quoteAppRecList,quoteIds); //IBA-1678
            // QuoteApprovalProcessFields_Class obj = new QuoteApprovalProcessFields_Class();
            //obj.updateQuoteApprovalFields(quoteAppRecList);
            //Based On selected conditions Queues will be selected
            //queueSelector(newItems.values());
            // Method to Update Time Stamp fields in Quote Approval Object
            boolean checkcondition = false;
            List<Quote_Approval__c> qapList1 = newItems.values();
            List<Quote_Approval__c> qapList2 = new List<Quote_Approval__c>();
            for(Quote_Approval__c qa:qapList1){
                if(qa.id!=NULL)
                    if(!qapList2.contains(qa))
                    qapList2.add(qa);
            }
            List<Quote_Approval__c> qapList3 = newItems.values();
            List<Quote_Approval__c> qapList4 = new List<Quote_Approval__c>();
            for(Quote_Approval__c qa:qapList3){
                if(qa.id!=NULL)
                    if(!qapList4.contains(qa))
                    qapList4.add(qa);
            }
            if(checkcondition==false)
                if(qapList2==qapList4)
                checkcondition = false;
            
            List<Quote_Approval__c> qapList5 = newItems.values();
            List<Quote_Approval__c> qapList6 = new List<Quote_Approval__c>();
            for(Quote_Approval__c qa:qapList5){
                if(qa.id!=NULL)
                    if(!qapList6.contains(qa))
                    qapList6.add(qa);
            }
            if(checkcondition==false)
                if(qapList4==qapList6)
                checkcondition = false;
            
            
            List<Quote_Approval__c> lockList=new List<Quote_Approval__c>();
            for(Quote_Approval__c qa: quoteAppRecList){
                Quote_Approval__c qas=(Quote_Approval__c)oldItems.get(qa.Id);
                if(qas.Status__c!=qa.status__c)
                    lockList.add(qa);
            }
            if(lockList.size() > 0){
                updateTimestamp(newItems.values());
                quoteAssignToUpdate(lockList);
            }
        }
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
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
        
        isInsert = true;
        createChevronRecord(newItems.values());
    }     
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
       
        if(!isbatchupdate){
            boolean checkcondition = false;
            List<Quote_Approval__c> qapList1 = newItems.values();
            List<Quote_Approval__c> qapList2 = new List<Quote_Approval__c>();
            for(Quote_Approval__c qa:qapList1){
                if(qa.id!=NULL)
                    if(!qapList2.contains(qa))
                    qapList2.add(qa);
            }
            List<Quote_Approval__c> qapList3 = newItems.values();
            List<Quote_Approval__c> qapList4 = new List<Quote_Approval__c>();
            for(Quote_Approval__c qa:qapList3){
                if(qa.id!=NULL)
                    if(!qapList4.contains(qa))
                    qapList4.add(qa);
            }
            if(checkcondition==false)
                if(qapList2==qapList4)
                checkcondition = false;
            
            List<Quote_Approval__c> qapList5 = newItems.values();
            List<Quote_Approval__c> qapList6 = new List<Quote_Approval__c>();
            for(Quote_Approval__c qa:qapList5){
                if(qa.id!=NULL)
                    if(!qapList6.contains(qa))
                    qapList6.add(qa);
            }
            if(checkcondition==false)
                if(qapList4==qapList6)
                checkcondition = false;
            
            
            List<Quote_Approval__c> qaList=newItems.values();
            List<Quote_Approval__c> qaOldList=oldItems.values();    
            List<Quote_Approval__c> lockList=new List<Quote_Approval__c>();
            
            for(Quote_Approval__c qa: qaList){
                Quote_Approval__c qas=(Quote_Approval__c)oldItems.get(qa.Id);
                System.debug('QA STATUS'+qa.status__c);
                System.debug('Old QA STATUS'+qas.status__c);
                if(qas.Status__c!=qa.status__c)
                    lockList.add(qa);
            }
            if(lockList.size() > 0){// && isInsert == false){ //){
                //&& isInsert == false){
                quoteStatusUpdate(lockList);
                //quoteLock(lockList);
            }
            //Pabitra: IBA-1782
            Quote_Approval__c qAppr=qaList[0];
            if(qAppr.Assigned_To__c!=qaOldList[0].Assigned_To__c && (qAppr.Assigned_To__c==null && qaOldList[0].Assigned_To__c.contains('Booking'))){
                if (qAppr.Booking_Approval_Request_Type__c=='Pre-Signature Process' && 
                    (qAppr.Status__c=='Approved'||qAppr.Status__c=='Rejected')){
                        sendApprovalRejectionNotification(qAppr);  
                        //end Pabitra: IBA-1782        
                    }
            }
            
        }
    }
    //Pabitra: IBA-1782
    public static void  sendApprovalRejectionNotification(Quote_Approval__c qApvl){
        String templateName=null;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        if(qApvl.Status__c=='Approved')
            templateName='PreSig Quote Approved Template';
        else if(qApvl.Status__c=='Rejected')
            templateName='PreSig Quote Rejected Template';  
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: templateName];
        
        message.setTemplateID(emailTemplate.Id); 
        String subject=emailTemplate.Subject;
        
        String quoteNumber=qApvl.SAP_Quote_Number__c;
        if(quoteNumber!=null){
            subject=subject.replace('{!Quote_Approval__c.SAP_Quote_Number__c}',String.valueOf(qApvl.SAP_Quote_Number__c));
        }
        
        String plainBody = emailTemplate.Body;
        Account acct=[select id from Account where SAP_Account_ID__c=:qApvl.CSN__c];
        
        String link =  System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + qApvl.Id;
        plainBody = plainBody.replace('{!User.Name}',Userinfo.getName());
        // plainBody = plainBody.replace('{!ApprovalRequest.Comments}',qApvl.Quote_Approval_Comments__c); 
        plainBody = plainBody.replace('{!Quote_Approval__c.Link}', link);
        plainBody = plainBody.replace('{!Quote_Approval__c.Quote__c}', qApvl.Quote_Name_Text__c);
        plainBody = plainBody.replace('{!Quote_Approval__c.Account_Name__c}',qApvl.Account_Name__c);
        if(quoteNumber!=null){
            plainBody = plainBody.replace('{!Quote_Approval__c.SAP_Quote_Number__c}', String.valueOf(qApvl.SAP_Quote_Number__c));
        }
        plainBody = plainBody.replace('{!Quote_Approval__c.Name}', qApvl.Name);
        plainBody = plainBody.replace('{!Quote_Approval__c.Status__c}',qApvl.Status__c );
        //plainBody = plainBody.replace(' {!Quote_Approval__c.Comment__c}',qApvl.Comment__c );
        
        Territory2Model currTerriModel = [Select Id from Territory2Model where state = 'Active'];
        List<UserTerritory2Association> usr1 = [Select UserId from UserTerritory2Association where RoleInTerritory2 in ('Health Systems Executive', 'Client Success Executive', 'Sales Consultant', 'Account Owner') and Territory2Id in (Select Territory2Id from ObjectTerritory2Association where objectId = :acct.id and Territory2.Territory2ModelId = :currTerriModel.Id)];
        if(usr1.size()>0){
            List<String> usr = new List<String>();
            for (UserTerritory2Association uTA : usr1){
                if(usr != null){
                    usr.add(uTA.UserId);
                }
            }
            List<user> usrEmail = [select email from user where id in :usr];
            Set <user> usrSet = new Set<user>(); //Remove Duplicate
            usrSet.addAll(usrEmail);
            
            List<String> usrList = new List<String>();
            for (user u : usrSet){
                usrList.add(u.email);
            }
            if(Test.isRunningTest()){
                usrList.add('pabitra.tripathy@omnicell.com');
            }        
            message.setPlainTextBody(plainBody);
            message.setToAddresses(usrList);
            // message.setSenderDisplayName('from pabitra alert'); 
            message.setReplyTo('no-reply@omnicell.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false);
            message.setSubject(subject);
            //System.debug(usrList);
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        }
        
    }
    //end Pabitra: IBA-1782
    public void quoteAssignToUpdate(List<Quote_Approval__c> qaList){
        For(Quote_approval__c qa:qaList){
            if(qa.Status__c == 'Approved' || qa.Status__c == 'Rejected')
                qa.Assigned_To__c = '';
        }
    }
    
    //This method is to update Quote Status Based on Quote Approval Status
    public void quoteStatusUpdate(List<Quote_Approval__c> qaList){
        
        List<Quote> qList=new List<Quote>();
        List<Id> qtList=new List<Id>();
        Map<id,Quote> quoteObjMap=new Map<Id,Quote>();
        Map<id,String> quoteStatMap=new Map<Id,String>();//Added by Sravan on 28 AUG
        List<String> cRegionval = canadianRegionValues();
        for(Quote_Approval__c qa:qaList){
            if(!qtList.contains(qa.Quote__c))
                qtList.add(qa.Quote__c);
        }
        for(Quote qt:[SELECT Id, status,Region__c FROM Quote WHERE Id in: qtList]){
            quoteObjMap.put(qt.Id,qt);
            quoteStatMap.put(qt.id,qt.Status);//Added by Sravan on 28 AUG
        }
        for(Quote_Approval__c qa: qaList){
            Quote qt=quoteObjMap.get(qa.Quote__c);
            //IBA_1407 START
            Boolean IsCanadianRegion = false;
            if(cRegionval.contains(qt.Region__c)) {
                IsCanadianRegion = true;
            }
            //IBA-1407 END
            String recordtypename = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qa.recordtypeid).getdevelopername();
            if(qa.Status__c == 'Waiting Approval')
                qt.Status='E0004';
            if(qa.Status__c == 'Approved' && (qa.Requires_Deal_Desk_Approval__c==FALSE && qa.Requires_Legal_Approval__c==FALSE && qa.Requires_RX_Config_Approval__c==FALSE && qa.Requires_Sales_Finance_Approval__c==FALSE && qa.Requires_Tech_Svcs_Approval__c==FALSE)){
                qt.Status='E0018';
            }
            if((recordtypename=='NAA_Budgetary_Quote' || (recordtypename=='MA_Budgetary_Quote' && IsCanadianRegion == true)) && qa.Status__c == 'Approved' && (qa.Requires_Deal_Desk_Approval__c==TRUE || qa.Requires_Legal_Approval__c==TRUE || qa.Requires_RX_Config_Approval__c==TRUE || qa.Requires_Sales_Finance_Approval__c==TRUE || qa.Requires_Tech_Svcs_Approval__c== TRUE)){
                qt.Status='E0007';
            }
            if((recordtypename=='NAA_Supplement_Quote' || (recordtypename=='Ma_Supplement_Quote' && IsCanadianRegion == true)) && qa.Status__c == 'Approved' && (qa.Requires_Deal_Desk_Approval__c==TRUE || qa.Requires_Legal_Approval__c==TRUE || qa.Requires_RX_Config_Approval__c==TRUE || qa.Requires_Sales_Finance_Approval__c==TRUE || qa.Requires_Tech_Svcs_Approval__c== TRUE || qa.Standard_Config_Approval__c == TRUE)){
                qt.Status='E0009';
            }
            if(qa.Status__c == 'Approved' && (recordtypename == 'International_ADC_VBM_Quote' || recordtypename == 'PES_Inception_Order_PA_Quote')){
                qt.Status='E0007';
            }
            //Added for UAT-BUG-432 UK-Pilot by Abhilash on April 2 2019
            if(qa.Status__c == 'Approved' && recordtypename == 'International_ADC_VBM_Quote'){
                qt.Status='E0009';       
            }
            //Added by Venu Kukkapalli as part of new MA record types 
            if(qa.status__c == 'Approved' && recordtypename == 'Ma_Supplement_Quote'){
                qt.status ='E0009';
            }
            if(qa.status__c == 'Approved' && recordtypename == 'Ma_Budgetary_Quote'){
                qt.status ='E0007';
            }
            if(qa.Status__c == 'Rejected'){
                qt.Status='E0003';
            }
            if(qa.Status__c == 'Recall'){
                qt.Status='E0001';
            }
            //Below condition added for SF-BUG-587
            if(qa.Status__c == 'Approved' && recordtypename == 'Margin_Analysis_Other'){
                qt.Status='E0007';
            }
            //Added below code for SF-BUG-406 on MAR 12 by sravan START
            if(recordtypename == 'Ma_Budgetary_Quote' || recordtypename=='NAA_Budgetary_Quote'){
                qt.Supplement_or_budgetary__c = 'budgetary';
            }
            else if(recordtypename == 'Ma_Supplement_Quote' || recordtypename=='NAA_Supplement_Quote'){
                qt.Supplement_or_budgetary__c = 'supplement';
            }
            //Added above code for SF-BUG-406 on MAR 12 by sravan END
            if(!qList.contains(qt) && qt.Status != quoteStatMap.get(qt.Id)){
                qList.add(qt);
            }  
        }
        if(qList.size()>0){
             QuoteTriggerHandler.updatefromqa = true;
            QuoteTriggerHandler.isFirstTime =true; //IBA-2952
            update qList;   
        }
    }
    
    //This Method is to Lock the Quote Record When related Quote record in Approved/Waiting Approval Status
    /*public void quoteLock(List<Quote_Approval__c> qaList){
for(Quote_Approval__c qa: qaList){
if(qa.status__c=='Waiting Approval')
{
Id i=qa.Quote__c;
//Approval.Lock(i);
}
if(qa.status__c=='Approved' || qa.status__c=='Rejected')
{
Id i=qa.Quote__c;
Approval.unLock(i);
}
}       
}*/
    
    
    public void createChevronRecord(List<Quote_Approval__c> qa){
        List<Quote_Approval_chevron__c> qac = new List<Quote_Approval_chevron__c>();
        
        for(Quote_Approval__c q:qa){
            Quote_Approval_chevron__c qach = new Quote_Approval_chevron__c();
            qach.quote_approval__c = q.id;
            qac.add(qach);
        }
        insert qac;
    }
    // This method is to Automate checkboxes(Criteria to Route Approval) on Quote Approval Object 
    /*public void   checkboxAutomation(List<Quote_Approval__c> qaList){
Map<Id,Id> quoteMap=new Map<Id,Id>();
for(Quote_Approval__c qa:qaList){
// Initializing all the checkboxes to default
Boolean check= qa.Discounting__c;
if(qa.Status__c != 'Waiting Approval'){
qa.New_Customer_ContainConfigCabinet_Supply__c=FALSE;
qa.Contains_Configurable_Cabinets_Supply__c=FALSE;
qa.Contains_IV_XR2_PC_and_Upgrade__c=FALSE;
qa.LR_Buyout_CO_Rep_Line_It_CRX_IV_RII__c = FALSE;
qa.LR_Buyout_CO_RepLineIt_MaintExt_CRX_IV__c =FALSE;

qa.Discounting__c=TRUE;
qa.Contains_Connect_RX_Upgrade__c='';

qa.Discounting__c=check;
qa.Contains_IV_PC_Pakplus__c=FALSE;
}
quoteMap.put(qa.id,qa.Quote__c);
}
List<Quote_Line__c> qList=[SELECT Id,Quote__c,Product__c,Quote_Line_Item_Type__c  FROM Quote_Line__c WHERE Quote__c in : quoteMap.values() ];
List<Id> pIdList=new List<Id>();
for(Quote_Line__c ql: qList){
if(ql.Product__c!=NULL)
PIdList.add(ql.Product__c);
}
List<Product2> prodList=[SELECT ID,DW_Product_Line__c,Business_Line__c, DW_Product_Segment__c,DW_Product_Type__c FROM Product2 WHERE ID in: pIdList];      
Map<Id,Product2> pqlMap=new Map<Id,Product2>();
for(Product2 pr:prodList){
pqlMap.put(pr.Id,pr);
}
system.debug(prodList.size());
Map<Id, List<Quote_Line__c>> quotelineMap = new Map<Id, List<Quote_Line__c>>();
for(Quote_Line__c ql:[SELECT ID, Quote__c,Product__c,Quote_Line_Item_Type__c  FROM Quote_Line__c WHERE Quote__c in: quoteMap.values()]){
if(quotelineMap.containsKey(ql.quote__c)){
List<Quote_Line__c> qlList = quotelineMap.get(ql.Quote__c);
qlList.add(ql);
quotelineMap.put(ql.Quote__c, qlList);
}
else{
quotelineMap.put(ql.quote__c, new List<Quote_Line__c>{ql});
}
}

for(Quote_Approval__c qa:qaList){
if(quotelineMap.get(qa.Quote__c)!=NULL && qa.Status__c != 'Waiting Approval'){
for(Quote_Line__c ql:quotelineMap.get(qa.Quote__c)){
if(pqlMap.get(ql.Product__c)!=NULL){      
Product2 pr=pqlMap.get(ql.Product__c);
String recordtypename = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qa.recordtypeid).getdevelopername();

if(pr.Business_Line__c=='Medication Dispensing Cabinets' || pr.Business_Line__c=='Non-Acute Medication Dispensing' || (pr.Business_Line__c=='Omnicell Supply Management System' && pr.DW_Product_Type__c =='Frame') || pr.DW_Product_Line__c == 'Pharmacy Carousel' || pr.DW_Product_Line__c == 'Central Pharmacy Manager (CPM)' ){
if(recordtypename == 'NAA_Budgetary_Quote'){
qa.New_Customer_ContainConfigCabinet_Supply__c=TRUE;
}
if(recordtypename == 'NAA_Supplement_Quote'){
qa.Contains_Configurable_Cabinets_Supply__c=TRUE;
}
}
// commented following line by Sarabjeet Singh
//  if(pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Line__c=='XR2' || pr.DW_Product_Segment__c=='Performance Center' || ql.Quote_Line_Item_Type__c=='Upgrade' ){
// added following by Sarabjeet Singh
if(pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Line__c=='XR2' || pr.DW_Product_Segment__c=='Performance Center' || ql.Quote_Line_Item_Type__c=='Upgrade' || pr.Business_Line__c=='Products IV'){
qa.Contains_IV_XR2_PC_and_Upgrade__c=TRUE;
}
if(ql.Quote_Line_Item_Type__c == 'Upgrade' || ql.Quote_Line_Item_Type__c == 'Buy-out' || (ql.Quote_Line_Item_Type__c =='Upgrade' && pr.DW_Product_Line__c == 'Connect-Rx' ) || pr.DW_Product_Line__c=='Robotic IV Insourcing Solution (RIIS)' ){
if(recordtypename == 'NAA_Budgetary_Quote'){
qa.LR_Buyout_CO_Rep_Line_It_CRX_IV_RII__c = TRUE;
}
if(recordtypename == 'NAA_Supplement_Quote'){
qa.LR_Buyout_CO_RepLineIt_MaintExt_CRX_IV__c =TRUE;
}
}
if(ql.Quote_Line_Item_Type__c=='Upgrade' && pr.DW_Product_Line__c == 'Connect-Rx'){
if(recordtypename == 'NAA_Budgetary_Quote'){
qa.Discounting__c=TRUE;
qa.Contains_Connect_RX_Upgrade__c='Y';
}
}
// commented line by Sarabjeet Singh
//  if(pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Segment__c == 'Performance Center' || pr.DW_Product_Line__c == 'PakPlus-Rx Medication Packaging Service'){
// added following by Sarabjeet Singh
if(pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Segment__c == 'Performance Center' || pr.DW_Product_Line__c == 'PakPlus-Rx Medication Packaging Service' || pr.Business_Line__c=='Products IV'){
if(recordtypename == 'NAA_Supplement_Quote'){
qa.Contains_IV_PC_Pakplus__c=TRUE;
}
}
}   
}
}
}
}*/
    /*public void checkboxUpdatation(List<Quote_Approval__c> qaList){
Map<Id,Id> quoteMap=new Map<Id,Id>();
List<Id> PIdList = new List<Id>();
Map<Id,Quote> quoteObjeMap=new Map<Id,Quote>();
for(Quote_Approval__c qa:qaList){
quoteMap.put(qa.id,qa.Quote__c);
}
for(Quote qt: [SELECT Id,Accountid,OpportunityId,IDN_Price_List__c,Region__c,Order_Type__c FROM Quote WHERE Id in: quoteMap.values()]){
if(qt.Order_Type__c == 'ZQR')    
quoteObjeMap.put(qt.id, qt);
}
List<Quote_Line__c> qList=[SELECT Id,Quote__c,Product__c,Quote_Line_Item_Type__c  FROM Quote_Line__c WHERE Quote__c in : quoteObjeMap.keySet() ];
for(Quote_Line__c ql: qList){
if(ql.Product__c!=NULL)
PIdList.add(ql.Product__c);
}
List<Product2> prodList=[SELECT ID,DW_Product_Line__c,Business_Line__c, DW_Product_Segment__c,DW_Product_Type__c,DW_Product_Class__c, DW_Product_Family__c  FROM Product2 WHERE ID in: pIdList];      
Map<Id,Product2> pqlMap=new Map<Id,Product2>();
for(Product2 pr:prodList){
pqlMap.put(pr.Id,pr);
}
Map<Id, List<Quote_Line__c>> quotelineMap = new Map<Id, List<Quote_Line__c>>();
for(Quote_Line__c ql:qList){
if(quotelineMap.containsKey(ql.quote__c)){
List<Quote_Line__c> qlList = quotelineMap.get(ql.Quote__c);
qlList.add(ql);
quotelineMap.put(ql.Quote__c, qlList);
}
else{
quotelineMap.put(ql.quote__c, new List<Quote_Line__c>{ql});
}
}
for(Quote_Approval__c qa:qaList){
Quote qt=quoteObjeMap.get(qa.quote__c );
if(quotelineMap.get(qa.Quote__c)!=NULL){
for(Quote_Line__c ql:quotelineMap.get(qa.Quote__c)){
if(pqlMap.get(ql.Product__c)!=NULL){
Product2 pr=pqlMap.get(ql.Product__c);
if(pr.DW_Product_Line__c=='Professional Services') 
{
qa.Requires_Legal_Approval_For_Service__c=TRUE; 
}
}
}
}
}
}*/
    // This method is to Automate checkboxes(Criteria to Route Approval) on Quote Approval Object 
    public void checkboxAutomation1(List<Quote_Approval__c> qaList){
        Map<Id,Id> quoteMap=new Map<Id,Id>();
        Map<Id,Account> accountObjMap=new Map<Id,Account>();
        Map<Id,Opportunity> opportunityObjMap=new Map<Id,Opportunity>();
        Map<Id,Quote> quoteObjeMap=new Map<Id,Quote>();
        Map<Id,Id> accountMap=new Map<Id,Id>();
        Map<Id,Id> opportunityMap=new Map<Id,Id>();
        List<String> cRegionval = canadianRegionValues();
        List<String> prdCodeNames = getProductsCodeValues(); //IBA-1764
        for(Quote_Approval__c qa:qaList){
            // Initializing all the checkboxes to default
            Boolean check= qa.Discounting__c;
            if(qa.Status__c != 'Waiting Approval'){
                qa.Requires_RX_Config_Approval__c=false;
                qa.Requires_Tech_Svcs_Approval__c=false;
                qa.Requires_Deal_Desk_Approval__c=false;
                qa.Requires_Sales_Finance_Approval__c=false;
                qa.Requires_Legal_Approval__c=false;            
            } 
            quoteMap.put(qa.id,qa.Quote__c);
        }
        
        for(Quote qt: [SELECT Id,Accountid,OpportunityId,IDN_Price_List__c,Region__c,Order_Type__c FROM Quote WHERE Id in: quoteMap.values()]){
            if(!accountMap.containsKey(qt.Id))
                accountMap.put(qt.id,qt.AccountId);
            if(!opportunityMap.containsKey(qt.Id))
                opportunityMap.put(qt.id,qt.OpportunityId);
            if(!quoteObjeMap.containsKey(qt.id))
                quoteObjeMap.put(qt.id, qt);
        }
        For(Account acc:[SELECT Id, Facility_Type__c, Partner_Type__c FROM Account WHERE Id in: accountMap.values()]){
            for(Id id: accountMap.keyset()){
                if(accountMap.get(id)==acc.id && !accountObjMap.containsKey(Id)){
                    accountObjMap.put(id,acc);
                    break;
                }
            }
        }
        For(Opportunity opp:[SELECT Id, CustomerType__c FROM Opportunity WHERE Id in: opportunityMap.values()]){
            for(Id id: opportunityMap.keyset()){
                if(opportunityMap.get(id)==opp.id && !opportunityObjMap.containsKey(Id)){
                    opportunityObjMap.put(id,opp);
                    break;
                }
            }
        }
        //  System.debug('***'+ quoteMap.values() );
        // Integer countQT = [SELECT count()  FROM Quote_Line__c WHERE Quote__c in : quoteMap.values() ];
        // System.debug('***'+countQT);
        // System.debug('Limit'+Limits.getLimitQueryRows()+'used'+Limits.getQueryRows());
        List<Quote_Line__c> qList=[SELECT Id,Quote__c,Product__c,Quote_Line_Item_Type__c  FROM Quote_Line__c WHERE Quote__c in : quoteMap.values()];
        List<Id> pIdList=new List<Id>();
        for(Quote_Line__c ql: qList){
            if(ql.Product__c!=NULL)
                PIdList.add(ql.Product__c);
        }
        //IBA-1764 Query update
        List<Product2> prodList=[SELECT ID,name,DW_Product_Line__c,Business_Line__c, DW_Product_Segment__c,Product_Type__c,ProductCode,DW_Product_Type__c,DW_Product_Class__c, DW_Product_Family__c,Portfolio_Segment__c  FROM Product2 WHERE ID in: pIdList];      //IBA-3639 add Product_Type__c field
        Map<Id,Product2> pqlMap=new Map<Id,Product2>();
        for(Product2 pr:prodList){
            pqlMap.put(pr.Id,pr);
        }
        //system.debug(prodList.size());
        Map<Id, List<Quote_Line__c>> quotelineMap = new Map<Id, List<Quote_Line__c>>();
        for(Quote_Line__c ql:qList){
            if(quotelineMap.containsKey(ql.quote__c)){
                List<Quote_Line__c> qlList = quotelineMap.get(ql.Quote__c);
                qlList.add(ql);
                quotelineMap.put(ql.Quote__c, qlList);
            }
            else{
                quotelineMap.put(ql.quote__c, new List<Quote_Line__c>{ql});
            }
        }
        
        for(Quote_Approval__c qa:qaList){
            Account acc=accountObjMap.get(qa.Quote__c);
            Opportunity opp=opportunityObjMap.get(qa.Quote__c);
            Quote qt=quoteObjeMap.get(qa.quote__c );
            //IBA-1407 START
            Boolean IsCanadianRegion = false;
            if(cRegionval.contains(qt.Region__c)) {
                IsCanadianRegion = true;
            }
            //IBA-1407 END
            String recordtypename = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qa.recordtypeid).getdevelopername();           
            if(qa.Status__c != 'Waiting Approval'){
                /* if(qa.Discounting__c==TRUE && opp.CustomerType__c=='Existing Customer' && qt.IDN_Price_List__c!=NULL ){
qa.Requires_Sales_Finance_Approval__c=TRUE; // commented by sravan fro SF-BUG-591
}*/
                if((recordtypename=='NAA_Budgetary_Quote' || (recordtypename=='MA_Budgetary_Quote' && IsCanadianRegion == true)) && (qa.Discounting__c==TRUE || (acc.Partner_Type__c =='0001' || acc.Partner_Type__c =='0002' || acc.Partner_Type__c == '0003' || acc.Partner_Type__c == '0004' || acc.Partner_Type__c == '0005' || acc.Partner_Type__c == '0006' || acc.Partner_Type__c == '0009' || acc.Partner_Type__c == '0010'))){
                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                }
                if(recordtypename=='NAA_Supplement_Quote' || (recordtypename=='Ma_Supplement_Quote' && IsCanadianRegion == true)){
                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                }
                List<Hero_Products__c> heroProds = Hero_Products__c.getall().values();//IBA-3639 Start
                Set<String> heroProdCode = new Set<String>();
                for(Hero_Products__c hpd:heroProds){
                    heroProdCode.add(hpd.Name);
                }																										//IBA-3639 End
                boolean requireDealdesk=false;
                if(quotelineMap.get(qa.Quote__c)!=NULL){
                    for(Quote_Line__c ql:quotelineMap.get(qa.Quote__c)){
                        if(pqlMap.get(ql.Product__c)!=NULL){      
                            Product2 pr=pqlMap.get(ql.Product__c);
                            //All Budgetary Quote and IV Product solutions should be available for Deal desk approval
                            if(recordtypename=='NAA_Budgetary_Quote' || recordtypename=='MA_Budgetary_Quote'){
                                if(pr.Business_Line__c=='IV Product Solutions'){
                                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                                }
                            }
                            
                            if(recordtypename=='NAA_Budgetary_Quote' || (recordtypename=='MA_Budgetary_Quote' && IsCanadianRegion == true)){
                                // commented following line by Sarabjeet Singh
                                if(pr.Business_Line__c=='IV Product Solutions' && pr.DW_Product_Line__c!='Robotic IV Insourcing Solution (RIIS)'){ 
                                    // added following line by sarabjeet Singh bug # 119
                                    //  if((pr.Business_Line__c=='IV Product Solutions' && pr.DW_Product_Line__c!='Robotic IV Insourcing Solution (RIIS)' ) || (pr.Business_Line__c=='Products IV' && pr.DW_Product_Line__c!='Robotic IV Insourcing Solution (RIIS)') ){ 
                                    qa.Requires_Tech_Svcs_Approval__c=TRUE;
                                }
                                if(pr.DW_Product_Line__c=='Robotic IV Insourcing Solution (RIIS)') //Added by Sourav for SF-BUG-817
                                {
                                    qa.Requires_Tech_Svcs_Approval__c=TRUE;
                                    //qa.Requires_Legal_Approval__c=TRUE; as part of IBA-3633
                                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                                }
                                // commented following line by Sarabjeet Singh
                                //if(pr.Business_Line__c=='IV Product Solutions' && pr.DW_Product_Line__c=='Robotic IV Insourcing Solution (RIIS)'){
                                if(pr.DW_Product_Line__c=='Robotic IV Insourcing Solution (RIIS)' || pr.DW_Product_Line__c=='Performance Center' || pr.DW_Product_Line__c=='PakPlus-Rx Service' || pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Line__c=='Omnicell One'){ //soumyad added omni one SF-Bug-975
                                    // Added pr.Business_Line__c=='IV Product Solutions' to fix SF-BUG-340 By Haridas on 12-Jul-19
                                    // Added Performance Center and PakPlus-Rx Service product in upper condition to resolve SF-BUG-122 by Rajat
                                    // added following line by sarabjeet Singh bug # 119
                                    //    if( ( pr.Business_Line__c=='IV Product Solutions' && pr.DW_Product_Line__c=='Robotic IV Insourcing Solution (RIIS)' ) || ( pr.Business_Line__c=='Products IV' && pr.DW_Product_Line__c=='Robotic IV Insourcing Solution (RIIS)' ) ){
                                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                                }
                                //soumyad sf-bug-976 start
                                if(pr.DW_Product_Line__c=='Professional Services') 
                                {
                                    qa.Requires_Professional_Services__c=TRUE; //pavan - JIRA IBA-1204
                                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                                }
                                //soumyad sf-bug-976 end
                            }
                            if(recordtypename=='NAA_Supplement_Quote' || (recordtypename=='Ma_Supplement_Quote' && IsCanadianRegion == true)){
                                // commented following line by Sarabjeet Singh
                                if((pr.Business_Line__c=='IV Product Solutions' && pr.DW_Product_Line__c!='Robotic IV Insourcing Solution (RIIS)') || pr.DW_Product_Line__c=='XR2 System' 
                                   || pr.DW_Product_Class__c == 'Closed Loop' 
                                   || pr.DW_Product_Class__c == 'Interoporability' 
                                   || (pr.DW_Product_Line__c=='Omnicenter' && pr.DW_Product_Family__c == 'Software' && pr.DW_Product_Type__c == 'Multi-Tenancy Install')
                                   || (pr.DW_Product_Line__c == 'Central Pharmacy Manager (CPM)' && pr.DW_Product_Type__c == 'Interface' && (pr.DW_Product_Class__c == 'Interface' || pr.DW_Product_Class__c =='340B'))
                                   || ((pr.DW_Product_Line__c == 'Controlled Substance Manager (CSM)' && pr.DW_Product_Family__c == 'Software') && (pr.DW_Product_Type__c == 'Interface' || pr.DW_Product_Type__c == 'License') && pr.DW_Product_Class__c != 'International')
                                   || (pr.DW_Product_Line__c == 'Omnicenter' && pr.DW_Product_Family__c == 'Software' && pr.DW_Product_Type__c == 'Interface' && (pr.DW_Product_Class__c != 'International' || pr.DW_Product_Class__c != 'Interface'))
                                   || (pr.DW_Product_Line__c == 'Connect-Rx' && (pr.DW_Product_Family__c == 'Software' || pr.DW_Product_Family__c == 'Hardware') && (pr.DW_Product_Type__c == 'Server' || pr.DW_Product_Type__c == 'Software'))
                                   || pr.DW_Product_Class__c == 'Tech Service Quote Routing'
                                   || (pr.DW_Product_Line__c == 'OptiFlex Supply Systems' && pr.DW_Product_Family__c == 'Hardware' && pr.DW_Product_Type__c == 'Server' && pr.DW_Product_Class__c == 'Upgrade')
                                   || (pr.DW_Product_Line__c == 'Medication Packager' && pr.DW_Product_Family__c == 'Hardware' && pr.DW_Product_Type__c == 'Server' && pr.DW_Product_Class__c == 'Upgrade') ){
                                       // added following line by sarabjeet Singh bug # 119
                                       //if((pr.Business_Line__c=='IV Product Solutions' && pr.DW_Product_Line__c!='Robotic IV Insourcing Solution (RIIS)') || pr.DW_Product_Line__c=='XR2' || (pr.DW_Product_Class__c == 'Upgrade' && pr.DW_Product_Type__c == 'Server') ){
                                       qa.Requires_Tech_Svcs_Approval__c=TRUE;
                                   }
                                //if(pr.Business_Line__c=='Medication Dispensing Cabinets' || pr.Business_Line__c=='Non-Acute Medication Dispensing' || (pr.Business_Line__c=='Omnicell Supply Management System' && pr.DW_Product_Type__c =='Frame') || pr.DW_Product_Line__c == 'Pharmacy Carousel' || pr.DW_Product_Line__c == 'Central Pharmacy Manager (CPM)'){
                                if((pr.DW_Product_Line__c =='Automated Dispensing Cabinets' && pr.DW_Product_Type__c=='Frame') 
                                   || (pr.DW_Product_Line__c =='Supply System' && pr.DW_Product_Type__c=='Frame')
                                   || (pr.DW_Product_Line__c =='Optiflex Supply Systems' && pr.DW_Product_Type__c=='Frame')
                                   || (pr.DW_Product_Line__c =='Anesthesia Workstation (AWS)' && pr.DW_Product_Type__c=='Frame') 
                                   || (pr.DW_Product_Line__c =='Controlled Substance Manager (CSM)' && pr.DW_Product_Type__c=='Frame')
                                   || pr.DW_Product_Line__c =='Pharmacy Carousel'
                                   || pr.DW_Product_Line__c=='Central Pharmacy Manager (CPM)'){
                                       qa.Requires_RX_Config_Approval__c=TRUE;
                                   }
                                //commented following line by Sarabjeet Singh
                                //if(pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Segment__c == 'Performance Center' || pr.DW_Product_Line__c == 'PakPlus-Rx Medication Packaging Service'){
                                //added following by Sarabjeet Singh
                                // IBA-2614 - added 'XR2 System'
                                /*if(pr.Business_Line__c=='IV Product Solutions' || pr.DW_Product_Segment__c == 'Performance Center' || pr.DW_Product_Line__c == 'PakPlus-Rx Service' || pr.DW_Product_Segment__c == 'Omnicell One' || pr.DW_Product_Line__c=='XR2 System'){ //soumyad added omni one SF-Bug-975
                                    qa.Requires_Legal_Approval__c=TRUE;
                                }commented whole if part as part of IBA-3633*/ 
                                //soumyad sf-bug-976 start
                                if(pr.DW_Product_Line__c=='Professional Services') 
                                {
                                    qa.Requires_Professional_Services__c=TRUE;
                                    qa.Requires_Deal_Desk_Approval__c=TRUE;
                                    //qa.Requires_Legal_Approval__c=TRUE; commented as part of IBA-3633
                                    qa.Requires_Tech_Svcs_Approval__c=TRUE;  //pavan - JIRA IBA-1204
                                    
                                }
                                //soumyad sf-bug-976 end
                                
                            }
                            /*if(recordtypename=='NAA_Supplement_Quote' || recordtypename=='Ma_Supplement_Quote'){
                                if(pr.DW_Product_Line__c=='Professional Services') 
                                {
                                    if(qt.Order_Type__c == 'ZQR'){
                                        qa.Requires_Legal_Approval_For_Service__c=TRUE; 
                                    }
                                }
                            } commented this if block as part of IBA-3633*/
                            //IBA-1764 START
                            if(recordtypename=='MA_Budgetary_Quote' || recordtypename=='Ma_Supplement_Quote') {
                                if(prdCodeNames.contains(pr.name)) {
                                    qa.Requires_NAC_Manager_Approval__c = TRUE;
                                }
                            }
                            //IBA-1764 END
                            //IBA-2759
                            
                            if(recordtypename=='NAA_Supplement_Quote' && pr.Portfolio_Segment__c=='Core Machine'){
                                if(pr.DW_Product_Line__c== 'Autobond' || pr.DW_Product_Line__c== 'Autogen' || pr.DW_Product_Line__c== 'Deblistering Machine' || pr.DW_Product_Line__c== 'Gemini' ||
                                   pr.DW_Product_Line__c== 'Guided Packaging' || pr.DW_Product_Line__c== 'Label Conveyer Applicator' || pr.DW_Product_Line__c== 'MedLocker' || pr.DW_Product_Line__c== 'MTS-350' ||
                                   pr.DW_Product_Line__c== 'PillVue System' || pr.DW_Product_Line__c== 'Printing Solutions' || pr.DW_Product_Line__c== 'MTS-400' ||
                                   pr.DW_Product_Line__c== 'Sureseal Sealer' || pr.DW_Product_Line__c== 'Kirby Lester Pill Counter'){
                                       if(!requireDealdesk)
                                           qa.Requires_Deal_Desk_Approval__c=FALSE;
                                   }
                                if(pr.DW_Product_Line__c== 'Central Pharmacy Blister Packager' || pr.DW_Product_Line__c== 'MTS-500' || pr.DW_Product_Line__c== 'EasySeal' ||
                                   pr.DW_Product_Line__c=='Emar' || pr.DW_Product_Line__c=='Freight' || pr.DW_Product_Line__c=='Impulse' ||
                                   pr.DW_Product_Line__c=='SureBond' || pr.DW_Product_Line__c=='Shared'){
                                       qa.Requires_Deal_Desk_Approval__c=TRUE; 
                                       requireDealdesk=true;
                                   }  
                            }   //end IBA-2759
                            
                            if(heroProdCode.contains(pr.ProductCode)){//IBA-3639 Start
                                	qa.Requires_Deal_Desk_Approval__c = TRUE;
                                	qa.Requires_Tech_Svcs_Approval__c = TRUE;
                                    if(recordtypename=='NAA_Supplement_Quote'){
                                        	qa.Requires_Legal_Approval_For_Service__c = FALSE;
                                    } 
                            }//IBA-3639 End
                        }   
                    }
                }
            }
            if(qa.Only_Pricing_Changes_Made__c ==TRUE){
                qa.Requires_Deal_Desk_Approval__c=TRUE;
                qa.Requires_Legal_Approval__c=FALSE;
                qa.Requires_RX_Config_Approval__c=FALSE;
                //qa.Requires_Sales_Finance_Approval__c=FALSE;
                qa.Requires_Tech_Svcs_Approval__c=FALSE;
                
                // Soumyad sf-bug-720 & 649 start added to route the QAP to corrrect queues
                if(quotelineMap.get(qa.Quote__c)!=NULL){
                    for(Quote_Line__c ql:quotelineMap.get(qa.Quote__c)){
                        if(pqlMap.get(ql.Product__c)!=NULL){      
                            Product2 pr=pqlMap.get(ql.Product__c);                            
                            if(pr.Business_Line__c=='IV Product Solutions'){
                                //qa.Requires_Legal_Approval__c=TRUE; commented as part of IBA-3633
                                qa.Requires_Tech_Svcs_Approval__c=TRUE; // soumyad sf-bug-649
                            }
                        }   
                    }
                }
                // Soumyad sf-bug-720 & 649 end
            }
        }
    }
    
    /*public void queueSelector(List<Quote_Approval__c> qaList){
for(Quote_Approval__c qa:qaList){
if(qa.Only_Pricing_Changes_Made__c==FALSE){
qa.Requires_RX_Config_Approval__c=false;
qa.Requires_Tech_Svcs_Approval__c=false;
qa.Requires_Deal_Desk_Approval__c=false;
qa.Requires_Sales_Finance_Approval__c=false;
qa.Requires_Legal_Approval__c=false;
}
if(qa.New_Customer_ContainConfigCabinet_Supply__c==TRUE){
qa.Requires_RX_Config_Approval__c=true;
}
if(qa.Contains_IV_XR2_PC_and_Upgrade__c==true){
qa.Requires_Tech_Svcs_Approval__c=true;
}
if(qa.LR_Buyout_CO_Rep_Line_It_CRX_IV_RII__c==true||qa.Service_Support_Term_1yr_or_5_yrs__c==true||qa.Government_Facility__c==true||qa.Additional_Discounting_off_Price_List__c=='Y'||qa.Fail_GSA__c=='Y'||qa.Contains_Connect_RX_Upgrade__c=='Y'){
qa.Requires_Deal_Desk_Approval__c=true;
}
if(qa.Additional_Discount_apply_Exist_Customer__c=='Y'){
qa.Requires_Sales_Finance_Approval__c=true;
}

if(qa.Contains_Configurable_Cabinets_Supply__c==true){
qa.Requires_RX_Config_Approval__c=true;
}
if(qa.Contains_IV_XR2_PC_and_Upgrade__c==true){
qa.Requires_Tech_Svcs_Approval__c=true;
}
if(qa.Contains_IV_PC_Pakplus__c==true){
qa.Requires_Legal_Approval__c=true;
}
if(qa.Extg_Cust_Non_Discounted_500K_Sales_Vol__c==true||qa.New_Customer__c==true||qa.LR_Buyout_CO_RepLineIt_MaintExt_CRX_IV__c==true||qa.Additional_supplement_language_needed__c==true||qa.Service_Support_Term_1yr_or_5_yrs__c==true||qa.Missing_Master_Agreement_Number__c==true||qa.Fail_GSA__c=='Y'||qa.Contains_Zero_Dollar__c=='Y'||qa.Expiration_Date_Has_Surpassed__c=='Yes'){
qa.Requires_Deal_Desk_Approval__c=true;
}
if(qa.Additional_Discount_apply_Exist_Customer__c=='Y'){
String str=Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qa.recordtypeid).getname();
//system.debug(str);
if(str=='NAA Supplement Quote')
qa.Requires_Deal_Desk_Approval__c=true;
qa.Requires_Sales_Finance_Approval__c=true;
}        
}
}*/
    
    // Updating Time Stamp fields on Quote Approval Records from Process Instance History Object
    // Updated By- Venu Kukkapalli on 18/04/2019 to update MA Budgetary, Supplement Time Stamp fields
    
    public void updateTimestamp(List<Quote_Approval__c> qaList){
        for(Quote_Approval__c qt:qaList){
            //System.debug(Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qt.recordtypeid).getname());
            if(qt.Status__c == 'Approved' || qt.status__c=='Rejected' || qt.Status__c=='Waiting Approval'){
                if(qt.Status__c=='Waiting Approval'){
                    qt.Approval_Start_Time__c=datetime.now();
                    if(qt.Requires_RX_Config_Approval__c==true)
                        qt.RX_Configuration_Team_Started__c=datetime.now();
                    if(qt.Requires_Tech_Svcs_Approval__c==true)
                        qt.Tech_Services_Started__c=datetime.now();
                    if(qt.Requires_Sales_Finance_Approval__c==true || qt.Need_Finance_Team_Approval__c == TRUE)
                        qt.Sales_Finance_Started__c=datetime.now();
                    if(qt.Requires_Deal_Desk_Approval__c==true || Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qt.recordtypeid).getname()=='International ADC/VBM Quote' || Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosById().get(qt.recordtypeid).getname()=='PES Inception Order/PA Quote')
                    {}  // qt.Deal_Desk_Started__c=datetime.now();
                    if(qt.Requires_Legal_Approval__c || qt.Need_Legal_Team_Approval__c == TRUE)
                        qt.Legal_Started__c=datetime.now();
                    if(qt.Need_CSC_Approval__c==TRUE)
                        qt.CSC_Started__c=datetime.now();
                    if(qt.Need_Operations_Team_Approval__c==TRUE){
                        qt.Operations_Started__c=datetime.now();
                    }
                    //qt.Booking_Started__c=datetime.now();
                }
                Boolean deald=false;
                Boolean techd=false;
                Boolean rxd=false;
                Boolean sfd=false;
                Boolean ld=false;
                Boolean bd=false;
                Boolean ci=false;
                Boolean po=false;
                Boolean mb=false;
                Boolean ms=false;
                String Dealstr='Deal Desk '+qt.Quote_Region__c;
                String Techstr='Technical Services '+qt.Quote_Region__c;
                String Rxstr='RX Consultants '+qt.Quote_Region__c;
                String Salesstr='Sales Finance '+qt.Quote_Region__c;
                String Legalstr='Legal '+qt.Quote_Region__c;
                String Bookstr='Booking Team-'+qt.Quote_Region__c;
                String DealIntstr='International Deal Desk';
                String DealPESstr='PES Deal Desk';
                String BookIntstr='Booking Team - International';
                String BookPESstr='Booking Team - PES';
                String CSCIntstr='International CSC';
                String mbstr='MA Budgetary Queue';
                String msstr='MA Supplement Queue';
                
                for(ProcessInstanceStep PIS:[SELECT Actorid,Actor.userRole.Name,createdDate, OriginalActor.Name, OriginalActor.Title, StepStatus, comments,ProcessInstance.CreatedDate,
                                             ProcessInstance.CompletedDate,ProcessInstance.lastActorId,processinstance.status
                                             FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=:qt.id and stepStatus='Approved' order by createdDate desc]){
                                                 if((PIS.OriginalActor.name==Dealstr || PIs.OriginalActor.name==DealIntstr || PIS.OriginalActor.name==DealPESstr) && deald==false){
                                                     qt.Deal_Desk_Completed__c=PIS.createdDate; 
                                                     qt.Deal_Desk_Signed_Off_By__c=PIS.Actorid;
                                                     qt.Deal_Desk_Sign_off_Comment__c=PIS.Comments;
                                                     if(qt.Deal_Desk_Started__c == null)
                                                     {
                                                         qt.Deal_Desk_Started__c = qt.Deal_Desk_Completed__c;
                                                     }
                                                     deald=true;
                                                 }
                                                 if(PIS.OriginalActor.name==Techstr && techd==false){
                                                     qt.Tech_Services_Completed__c=PIS.createdDate; 
                                                     qt.Tech_Services_Signed_off_By__c=PIS.Actorid;
                                                     qt.Tech_Services_Sign_off_Comment__c=PIS.Comments;
                                                     techd=true;
                                                 }
                                                 if(PIS.OriginalActor.name==Rxstr && rxd==false){
                                                     qt.RX_Configuration_Team_Completed__c=PIS.createdDate;
                                                     qt.RX_Configuration_Team_Signed_off_By__c=PIS.Actorid;
                                                     qt.RX_Configuration_Team_Sign_off_Comment__c=pis.Comments;
                                                     rxd=true;
                                                 }
                                                 if((PIS.OriginalActor.name==Salesstr && sfd==false)||(PIS.OriginalActor.name=='PES Finance' && sfd==false && qt.Need_Finance_Team_Approval__c == TRUE)){
                                                     qt.Sales_Finance_Completed__c = PIS.createdDate; 
                                                     qt.Sales_Finance_Signed_off_By__c =PIS.Actorid;
                                                     qt.Sales_Finance_Sign_off_Comment__c =pis.Comments;
                                                     sfd=true;
                                                 }
                                                 if((PIS.OriginalActor.name==Legalstr && ld==false)|| (PIS.OriginalActor.name=='PES Legal' && ld==false && qt.Need_Legal_Team_Approval__c == TRUE)){
                                                     qt.Legal_Completed__c =PIS.createdDate;
                                                     qt.Legal_Signed_off_By__c =PIS.Actorid;
                                                     qt.Legal_Sign_off_Comment__c =pis.Comments;
                                                     ld=true;
                                                 }
                                                 if((PIS.OriginalActor.name==Bookstr||Pis.OriginalActor.name==BookIntstr||PIS.OriginalActor.Name==BookPESstr) && bd==false){
                                                     qt.Booking_Completed__c=PIS.createdDate;
                                                     qt.Booking_Signed_Off_By__c=PIS.ActorId;
                                                     qt.Booking_Sign_Off_Comment__c=PIS.Comments;
                                                     bd=true;
                                                 }
                                                 if(qt.Need_CSC_Approval__c==TRUE && PIS.OriginalActor.name == CSCIntstr && ci==false){ 
                                                     qt.CSC_Completed__c=PIS.createdDate;
                                                     qt.CSC_Signed_Off_By__c=PIS.ActorId;
                                                     qt.CSC_Sign_Off_Comment__c=PIS.Comments;
                                                     ci=true;
                                                 }
                                                 if(qt.Need_Operations_Team_Approval__c==TRUE && PIS.OriginalActor.name == 'PES Operations' && po==false){ 
                                                     qt.Operations_Completed__c=PIS.createdDate;
                                                     qt.Operations_Signed_Off_By__c=PIS.ActorId;
                                                     qt.Operations_Sign_Off_Comments__c=PIS.Comments;
                                                     po=true;
                                                 }
                                                 //system.debug(PIS.OriginalActor.name);
                                                 if(pis.OriginalActor.name == mbstr && mb==false){
                                                     qt.MA_Budgetary_Approved_By__c = PIS.actorId;
                                                     qt.MA_Budgetary_Sign_Off_Comment__c = Pis.comments;
                                                     mb=true;
                                                 }
                                                 if(pis.OriginalActor.name == msstr && ms==false){
                                                     qt.MA_Supplement_Sign_Off_By__c = pis.ActorId;
                                                     qt.MA_Supplement_Sign_Off_Comment__c = pis.Comments;
                                                     ms = true;
                                                 }
                                             }
            }
        }
    }
    public List<String> canadianRegionValues() {
        List<String> cRegionValues = new List<String>();
        List<Canadian_Region__c> cRegions = new List<Canadian_Region__c>();
        cRegions = [Select name from Canadian_Region__c];
        for(Canadian_Region__c cr: cRegions) {
            cRegionValues.add(cr.name);
        }
        return cRegionValues;
    }
    //IBA-1764
    public List<String> getProductsCodeValues() {
        List<String> productValues = new List<String>();
        List<NAC_Products__c> prdVal = new List<NAC_Products__c>();
        prdVal = [Select name from NAC_Products__c];
        for(NAC_Products__c cr: prdVal) {
            productValues.add(cr.name);
        }
        return productValues;
    }
    //IBA-1678
    public void setClinicalConsultant(List<Quote_Approval__c> qaList, Set<id> quoteids){ 
        List<Quote> listQuotes = [Select id,Consultant__c from Quote where id IN: quoteids];
        Map<id,Quote> map1 = new Map<id,Quote>();
        for(Quote q: listQuotes) {
            map1.put(q.id,q);
        }
        for(Quote_Approval__c qa: qaList) {
            Quote qrecord = map1.get(qa.Quote__c);
            if(qrecord.Consultant__c != Null) {
                qa.Clinical_Consultant__c = qrecord.Consultant__c;   
            }
        }
    }
}